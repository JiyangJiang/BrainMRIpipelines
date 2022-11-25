#!/bin/bash

mrconvert -force -fslgrad eddy/eddy.eddy_rotated_bvecs bval eddy/eddy.nii.gz dwi_den_unr_preproc.mif

# bias correction
dwibiascorrect ants -force dwi_den_unr_preproc.mif dwi_den_unr_preproc_unbiased.mif -bias bias.mif

# brain mask
dwi2mask -force dwi_den_unr_preproc_unbiased.mif dwi_mask.mif

# response function estimation
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Ref:
# https://community.mrtrix.org/t/lmaxes-specified-does-not-match-number-of-tissues/500
# https://3tissue.github.io/doc/single-subject.html
dwi2response dhollander -force dwi_den_unr_preproc_unbiased.mif response_wm.txt response_gm.txt response_csf.txt -voxels response_voxels.mif 

# upsampling
mrgrid -force dwi_den_unr_preproc_unbiased.mif regrid dwi_denoised_unringed_preproc_unbiased_upsampled.mif -voxel 1.25
# mrgrid -force dwi_mask.mif regrid - -template dwi_denoised_unringed_preproc_unbiased_upsampled.mif -interp linear -datatype bit | maskfilter - median dwi_mask_upsampled.mif
dwi2mask -force dwi_denoised_unringed_preproc_unbiased_upsampled.mif dwi_mask_upsampled.mif


