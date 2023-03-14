#!/bin/bash

# NOTICE
#
# 1) need to check if dwi acquisition was axial. This affects
#    2.3 unringing.
# 2) need to look into whether acqparam.txt needs to be changed.
# 3) need to check if num of vols is 127 and consistent across subjects.
# 4) need to make sure dwi data are from multiple shells - affecting
#    --data_is_shelled option in edddy.

# One folder for each subject ID (sub-1234):
#
# 	sub-1234/t1w.nii.gz
# 	sub-1234/dwi.nii.gz
# 	sub-1234/bvec
# 	sub-1234/bval
#
# Study folder contains all subject ID folders

# change according to requirement
# ===============================
studyFolder=/g/data/ey6/Jiyang/myTmp
scriptFolder=/software/wmh-myelin-pet
numDwiVols=127
subjID=sub-941_S_7046
# ===============================

cd $studyFolder


# convert nii to mif
# ------------------
mrconvert 	$subjID/dwi.nii.gz $subjID/dwi.mif -fslgrad $subjID/bvec $subjID/bval --force

# extract B0
# ----------------
dwiextract $subjID/dwi.mif $subjID/b0_4D.mif -bzero -force
mrconvert  $subjID/b0_4D.mif $subjID/b0_4D.nii.gz -force
mcflirt -in $subjID/b0_4D -out $subjID/b0_4Dmcflirt
fslmaths $subjID/b0_4Dmcflirt -Tmean $subjID/b0

# denoising
# -----------------
dwidenoise $subjID/dwi.mif $subjID/dwi_den.mif -noise $subjID/noise.mif --force

# unringing
# -----------------
mrdegibbs $subjID/dwi_den.mif $subjID/dwi_denUnr.mif -axes 0,1 --force

# t1w non-brain tissue removal (Ref : https://github.com/pnlbwh/pnlpipe-containers)
# -----------------
module load singularity

singularity run \
--bind /g/data/ey6/Jiyang/my_software/freesurfer/7.3.2/license.txt:/home/pnlbwh/freesurfer-7.1.0/license.txt \
--bind /g/data/ey6/Jiyang/my_software/misc/IITmean_b0_256.nii.gz:/home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder/IITmean_b0_256.nii.gz \
--bind $studyFolder/$subjID:/home/pnlbwh/myData \
/g/data/ey6/Jiyang/my_singularity_images/pnlpipe.sif \
nifti_atlas -t /home/pnlbwh/myData/t1w.nii.gz -o /home/pnlbwh/myData/t1Mask --train /home/pnlbwh/pnlpipe/soft_dir/trainingDataT1AHCC-8141805/trainingDataT1Masks-hdr.csv -n 10
# singularity container does not work!!


for_each -nthreads $nthr sub-* : mv IN/t1Mask_mask.nii.gz IN/t1w_brainmask.nii.gz
for_each -nthreads $nthr sub-* : fslmaths IN/t1w -mas IN/t1w_brainmask IN/t1w_brain

# synthesize reverse PE B0
# -----------------
echo "synB0-DISCO ..."
cp /software/freesurfer/7.3.2/license.txt ./FreeSurfer_license.txt

# from Json file : BandwidthPerPixelPhaseEncode: 15.674
cat << EOT > acqparams.txt
0 1 0 0.064
0 1 0 0.00
EOT

for i in sub-*
do
[ -d 'INPUTS' ]  && rm -fr INPUTS
[ -d 'OUTPUTS' ] && rm -fr OUTPUTS
mkdir -p INPUTS OUTPUTS 
cp $i/b0.nii.gz acqparams.txt INPUTS
cp $i/t1w_brain.nii.gz INPUTS/T1.nii.gz
docker run --rm \
-v ${studyFolder}/INPUTS/:/INPUTS/ \
-v ${studyFolder}/OUTPUTS/:/OUTPUTS/ \
-v ${studyFolder}/FreeSurfer_license.txt:/extra/freesurfer/license.txt \
--user $(id -u):$(id -g) \
leonyichencai/synb0-disco \
--stripped \
--notopup							# Ref : https://github.com/MASILab/Synb0-DISCO
									#
									# 1) Synb0-DISCO requires INPUTS and OUTPUTS
									#    folder in the current directory.
									#
									# 2) not doing topup because the topup setting in
									#    synb0-DISCO generate field coeff maps
									#    that will cause eddy_cuda to fail.

[ -d "$i/synB0discoOutput" ] && rm -fr $i/synB0discoOutput
mv OUTPUTS $i/synB0discoOutput
done
rm -fr INPUTS OUTPUTS

# topup
# -----------------
for_each -nthreads $nthr sub-* : fslmerge -t IN/synB0discoOutput/b0_all \
											IN/b0 \
											IN/synB0discoOutput/b0_u # b0_u is the synthesized undistorted b0.
																	 # Note here the original b0 is used.
																	 # In Synb0-DISCO topup, smoothed b0 is used,
																	 # ie., b0_d_smooth (line 63 of https://github.com/MASILab/Synb0-DISCO/blob/master/src/pipeline.sh).

for_each -nthreads $nthr sub-* : topup 	--imain=IN/synB0discoOutput/b0_all \
										--datain=acqparams.txt \
										--config=$scriptFolder/dwi/b02b0_noSubsamp.cnf \
										--iout=IN/synB0discoOutput/b0_all_topup \
										--out=IN/synB0discoOutput/topup 	# Here b02b0.cnf is modified to not subsample
																			# because otherwise num of slices needs to be
																			# even.

# B0 brain extraction
# -----------------
for_each -nthreads $nthr sub-* : fslmaths IN/synB0discoOutput/b0_all_topup -Tmean IN/synB0discoOutput/b0_all_topup_Tmean
for_each -nthreads $nthr sub-* : bet IN/synB0discoOutput/b0_all_topup_Tmean IN/synB0discoOutput/b0_all_topup_Tmean_brain -m -R 	# B0 brain extraction
																																# using FSL BET

# for_each -nthreads $nthr sub-* : python ${scriptFolder}/dwi/dipyBrainExtraction.py 	IN/synB0discoOutput/b0_all_topup_Tmean.nii.gz IN/synB0discoOutput b0_all_topup_Tmean # b0 brain extraction using dipy

# for_each -nthreads $nthr sub-* : \
# docker run --rm \
# -v /software/freesurfer/7.3.2/license.txt:/home/pnlbwh/freesurfer-7.1.0/license.txt \
# -v ${studyFolder}/IN:/home/pnlbwh/myData \
# -v /software/miscellaneous/pnlpipe/IITmean_b0_256.nii.gz:/home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder/IITmean_b0_256.nii.gz \
# -v /software/miscellaneous/pnlpipe/trainingDataT2Masks:/home/pnlbwh/pnlpipe/soft_dir/trainingDataT2Masks \
# tbillah/pnlpipe \
# "cd /home/pnlbwh/pnlpipe/soft_dir/trainingDataT2Masks;./mktrainingcsv.sh /home/pnlbwh/pnlpipe/soft_dir/trainingDataT2Masks;cd /home/pnlbwh/myData;nifti_atlas -t /home/pnlbwh/myData/synB0discoOutput/b0_all_topup_Tmean.nii.gz -o /home/pnlbwh/myData/synB0discoOutput/b0_all_topup_Tmean --train /home/pnlbwh/pnlpipe/soft_dir/trainingDataT2Masks/trainingDataT2Masks-hdr.csv" # skull stripping for corrected B0 for eddy

# prepare for eddy
# -----------------
indx=""
for ((i=1; i<=$numDwiVols; i+=1)); do indx="$indx 1"; done
echo $indx > index.txt

for_each -nthreads $nthr sub-* : mrconvert IN/dwi_denUnr.mif IN/dwi_denUnr.nii.gz -export_grad_fsl IN/bvec IN/bval -force
for_each -nthreads $nthr sub-* : mkdir -p IN/eddy
