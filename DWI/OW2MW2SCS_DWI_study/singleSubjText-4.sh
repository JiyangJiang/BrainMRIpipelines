#!/bin/bash

# 3-tissue CSD modelling
ss3t_csd_beta1 -force dwi_denoised_unringed_preproc_unbiased_upsampled.mif ../grp_avg_response_wm.txt wmfod.mif ../grp_avg_response_gm.txt gm.mif ../grp_avg_response_csf.txt csf.mif -mask dwi_mask_upsampled.mif

# robust bias field correction with info from 3 compartments
mtnormalise -force wmfod.mif wmfod_norm.mif gm.mif gm_norm.mif csf.mif csf_norm.mif -mask dwi_mask_upsampled.mif


# OPTIONAL - visualisation
fod2dec -force wmfod_norm.mif decfod.mif -mask dwi_mask_upsampled.mif
# mrview decfod.mif -odf.load_sh wmfod_norm.mif
