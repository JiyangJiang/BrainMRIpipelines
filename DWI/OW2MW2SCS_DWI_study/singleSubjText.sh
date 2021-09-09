#!/bin/bash

path2FSlicense=/g/data/ey6/Jiyang/my_software/freesurfer/7.1.0/license.txt
path2SYNb0_pipeline=/g/data/ey6/Jiyang/OW2_MW2_SCS_DWI_MRtrix3/to_use/scripts

# extract b0
fslroi dwi b0 0 1

mrconvert dwi.nii.gz dwi_raw.mif -fslgrad bvec bval --force

# 2.2 denoising
# ++++++++++++++++++++++++++
dwidenoise dwi_raw.mif dwi_den.mif -noise noise.mif  --force
# mrcalc dwi_raw.mif dwi_den.mif -subtract residual.mif

# 2.3 unringing
# ++++++++++++++++++++++++++
mrdegibbs dwi_den.mif dwi_den_unr.mif -axes 0,1  --force # acquisition was axial
# mrcalc dwi_den.mif dwi_den_unr.mif –subtract residualUnringed.mif

# susceptibility distortion correction
# ++++++++++++++++++++++++++++++++++++

# 1. remove skull

# source /srv/scratch/cheba/NiL/Software/miniconda3/etc/profile.d/conda.sh
# conda activate pnlpipe3

# nifti_atlas -t T1.nii.gz \
# 			--train /srv/scratch/cheba/NiL/Software/trainingDataT1AHCC-8141805/trainingDataT1Masks-hdr.csv \
# 			-o T1_brain

# optiBET.sh -i T1.nii.gz
# Somehow, the synb0_disco scripts do not accept predefined mask,
# giving error 'Not enough classes detected to init KMeans'
# from FSL FAST. So let the scripts generate mask using bet.

# 2. create acqparams.txt
echo "0 1 0 0.05" > acqparams.txt
echo "0 1 0 0.00" >> acqparams.txt

# 3. susceptibility distortion correction with Synb0-DISCO (works on Gadi)
cp $path2FSlicense .
# mv T1_optiBET_brain_mask.nii.gz T1_mask.nii.gz
mkdir INPUTS OUTPUTS
mv b0.nii.gz T1.nii.gz acqparams.txt INPUTS/.

# 4. Run Synb0-DISCO - using pipeline.sh, instead of docker on Gadi.
# sudo docker run --rm \
# -v $(pwd)/INPUTS/:/INPUTS/ \
# -v $(pwd)/OUTPUTS/:/OUTPUTS/ \
# -v $(pwd)/license.txt:/extra/freesurfer/license.txt \
# --user $(id -u):$(id -g) \
# hansencb/synb0 \
# --notopup
${path2SYNb0_pipeline}/synb0-disco_pipeline.sh

# 4. eddy
module load openmpi/4.1.1
mkdir eddy
mrconvert -force -export_grad_fsl eddy/dwi_den_unr.bvec eddy/dwi_den_unr.bval dwi_den_unr.mif eddy/dwi_den_unr.nii.gz

# b0 mask
fslmaths OUTPUTS/b0_all_topup -Tmean OUTPUTS/b0_all_topup_Tmean
bet OUTPUTS/b0_all_topup_Tmean.nii.gz eddy/b0_all_topup_Tmean_brain -m -f 0.3

indx=""
for ((i=1; i<=$(fslval dwi dim4); i+=1)); do indx="${indx} 1"; done
echo $indx > index.txt

eddy_openmp --imain=eddy/dwi_den_unr \
			--mask=eddy/b0_all_topup_Tmean_brain \
			--acqp=INPUTS/acqparams.txt \
			--index=index.txt \
			--bvecs=eddy/dwi_den_unr.bvec \
			--bvals=eddy/dwi_den_unr.bval \
			--topup=OUTPUTS/topup \
			--out=eddy/eddy \
			--slm=linear \
			--repol \
			--niter=8 \
			--fwhm=10,8,4,2,0,0,0,0 \
			--ol_type=sw \
			--mporder=8 \
			--s2v_niter=8 \
			--verbose > eddy/eddy.log
		


