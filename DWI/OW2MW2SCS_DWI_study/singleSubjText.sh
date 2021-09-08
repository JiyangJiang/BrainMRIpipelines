#!/bin/bash

path2FSlicense=/Users/z3402744/Work/test2/100181/license.txt

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

optiBET.sh -i T1.nii.gz

# 2. create acqparams.txt
echo "0 1 0 0.05" > acqparams.txt
echo "0 1 0 0.00" >> acqparams.txt

# 3. susceptibility distortion correction with Synb0-DISCO
cp $path2FSlicense .
mv T1_optiBET_brain_mask.nii.gz T1_mask.nii.gz

sudo docker run --rm \
-v $(pwd):/INPUTS/ \
-v $(pwd):/OUTPUTS/ \
-v $(pwd)/license.txt:/extra/freesurfer/license.txt \
--user $(id -u):$(id -g) \
hansencb/synb0



