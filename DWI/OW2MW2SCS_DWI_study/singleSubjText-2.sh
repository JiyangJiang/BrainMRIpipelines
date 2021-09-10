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
mrgrid -force dwi_den_unr_preproc_unbiased.mif regrid dwi_denoised_unringed_preproc_unbiased_upsampled.mif -voxel 1.5
mrgrid -force dwi_mask.mif regrid - -template dwi_denoised_unringed_preproc_unbiased_upsampled.mif -interp linear -datatype bit | maskfilter - median dwi_mask_upsampled.mif



# ---=== Finally note that, for quantitative group studies, a single unique set of 3-tissue response functions should be used for all subjects. 
# ---=== This can for example be achieved by averaging response functions (per tissue type) across all subjects in the study.
# Ref: https://mrtrix.readthedocs.io/en/3.0_rc2/fixel_based_analysis/ss_fibre_density_cross-section.html


# 3-tissue CSD modelling
ss3t_csd_beta1 dwi_denoised_unringed_preproc_unbiased_upsampled.mif response_wm.txt wmfod.mif response_gm.txt gm.mif response_csf.txt csf.mif -mask dwi_mask_upsampled.mif

# robust bias field correction with info from 3 compartments
mtnormalise wmfod.mif wmfod_norm.mif gm.mif gm_norm.mif csf.mif csf_norm.mif -mask dwi_mask_upsampled.mif


# OPTIONAL - visualisation
fod2dec wmfod_norm.mif decfod.mif -mask dwi_mask_upsampled.mif