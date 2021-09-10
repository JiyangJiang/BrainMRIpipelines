#!/bin/bash

# ---=== Finally note that, for quantitative group studies, a single unique set of 3-tissue response functions should be used for all subjects. 
# ---=== This can for example be achieved by averaging response functions (per tissue type) across all subjects in the study.
# Ref: https://mrtrix.readthedocs.io/en/3.0_rc2/fixel_based_analysis/ss_fibre_density_cross-section.html
# average_response */response.txt ../group_average_response.txt


# 3-tissue CSD modelling
ss3t_csd_beta1 -force dwi_denoised_unringed_preproc_unbiased_upsampled.mif response_wm.txt wmfod.mif response_gm.txt gm.mif response_csf.txt csf.mif -mask dwi_mask_upsampled.mif

# robust bias field correction with info from 3 compartments
mtnormalise -force wmfod.mif wmfod_norm.mif gm.mif gm_norm.mif csf.mif csf_norm.mif -mask dwi_mask_upsampled.mif


# OPTIONAL - visualisation
fod2dec wmfod_norm.mif decfod.mif -mask dwi_mask_upsampled.mif