#!/bin/bash

# https://github.com/MASILab/Synb0-DISCO/blob/master/src/pipeline.sh

TOPUP=1

# for arg in "$@"
# do
#     case $arg in
#         -i|--notopup)
#         TOPUP=0
#     esac
# done


# # Set path for executable
# export PATH=$PATH:/extra
disco_path=/g/data/ey6/Jiyang/my_software/Synb0-DISCO
export PATH=${disco_path}/data_processing:$PATH
# # Set up freesurfer
# export FREESURFER_HOME=/extra/freesurfer
# source $FREESURFER_HOME/SetUpFreeSurfer.sh


# # Set up FSL
# . /extra/fsl/etc/fslconf/fsl.sh
# export PATH=$PATH:/extra/fsl/bin
# export FSLDIR=/extra/fsl

# # Set up ANTS
# export ANTSPATH=/extra/ANTS/bin/ants/bin/
# export PATH=$PATH:$ANTSPATH:/extra/ANTS/ANTs/Scripts

# # Set up pytorch
# source /extra/pytorch/bin/activate

module load intel-mkl/2020.3.304 python3/3.9.2 cuda/11.2.2 cudnn/8.1.1-cuda11 openmpi/4.1.0 magma/2.6.0 fftw3/3.3.8 pytorch/1.9.0

# Prepare input
prepare_input.sh    INPUTS/b0.nii.gz \
                    INPUTS/T1.nii.gz \
                    INPUTS/T1_mask.nii.gz \
                    ${disco_path}/atlases/mni_icbm152_t1_tal_nlin_asym_09c.nii.gz \
                    ${disco_path}/atlases/mni_icbm152_t1_tal_nlin_asym_09c_2_5.nii.gz \
                    OUTPUTS

# Run inference
NUM_FOLDS=5
for i in $(seq 1 $NUM_FOLDS);
  do echo Performing inference on FOLD: "$i"
  python3 ${disco_path}/src/inference.py \
            OUTPUTS/T1_norm_lin_atlas_2_5.nii.gz \
            OUTPUTS/b0_d_lin_atlas_2_5.nii.gz \
            OUTPUTS/b0_u_lin_atlas_2_5_FOLD_"$i".nii.gz \
            ${disco_path}/src/train_lin/num_fold_"$i"_total_folds_"$NUM_FOLDS"_seed_1_num_epochs_100_lr_0.0001_betas_\(0.9\,\ 0.999\)_weight_decay_1e-05_num_epoch_*.pth
done

# Take mean
echo Taking ensemble average
fslmerge -t OUTPUTS/b0_u_lin_atlas_2_5_merged.nii.gz OUTPUTS/b0_u_lin_atlas_2_5_FOLD_*.nii.gz
fslmaths OUTPUTS/b0_u_lin_atlas_2_5_merged.nii.gz -Tmean OUTPUTS/b0_u_lin_atlas_2_5.nii.gz

# Apply inverse xform to undistorted b0
echo Applying inverse xform to undistorted b0
antsApplyTransforms -d 3 -i OUTPUTS/b0_u_lin_atlas_2_5.nii.gz \
                    -r INPUTS/b0.nii.gz \
                    -n BSpline \
                    -t [OUTPUTS/epi_reg_d_ANTS.txt,1] \
                    -t [OUTPUTS/ANTS0GenericAffine.mat,1] \
                    -o OUTPUTS/b0_u.nii.gz

# Smooth image
echo Applying slight smoothing to distorted b0
fslmaths INPUTS/b0.nii.gz -s 1.15 OUTPUTS/b0_d_smooth.nii.gz

if [[ $TOPUP -eq 1 ]]; then
    # Merge results and run through topup
    echo Running topup
    fslmerge -t OUTPUTS/b0_all.nii.gz OUTPUTS/b0_d_smooth.nii.gz OUTPUTS/b0_u.nii.gz
    topup -v --imain=OUTPUTS/b0_all.nii.gz \
            --datain=INPUTS/acqparams.txt \
            --config=b02b0.cnf \
            --iout=OUTPUTS/b0_all_topup.nii.gz \
            --out=OUTPUTS/topup \
            --subsamp=1,1,1,1,1,1,1,1,1 \
            --miter=10,10,10,10,10,20,20,30,30 \
            --lambda=0.00033,0.000067,0.0000067,0.000001,0.00000033,0.000000033,0.0000000033,0.000000000033,0.00000000000067 \
            --scale=0
fi


# Done
echo FINISHED!!!