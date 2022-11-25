#!/bin/bash


# ---=== GROUP LEVEL ===---



work_dir=/home/jiyang/Work/dwi_test
cd ${work_dir}

# Compute the intersection of all warped masks:
mrmath -force [0-9]*/dwi_mask_in_template_space.mif min template/mask_intersection.mif

# 13. Compute a white matter template analysis fixel mask
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Compute a template AFD peaks fixel image:
fod2fixel -force template/wmfod_template.mif -mask template/mask_intersection.mif template/fixel_temp -peak peaks.mif

# Ref: https://mrtrix.readthedocs.io/en/latest/fixel_based_analysis/mt_fibre_density_cross-section.html (Step 12)
# fod2fixel -mask template/mask_intersection.mif -fmls_peak_value 0.06 template/wmfod_template.mif template/fixel_mask



# 10 Nov 2021
# Based on ref https://mrtrix.readthedocs.io/en/latest/fixel_based_analysis/mt_fibre_density_cross-section.html,
# the following steps are not needed.
#

# # VISUALISATION REQUIRED : Next view the peaks file using the fixel plot tool in mrview and identify an appropriate 
# #                          threshold that removes peaks from grey matter, yet does not introduce any ‘holes’ in your 
# #                          white matter.
# #
# # mrview template/wmfod_template.mif => Tools => Fixel plot => open fixel image => select 'template/fixel_temp/peaks.mif'

# # Threshold the peaks fixel image:
thr1=0.20
mrthreshold -force template/fixel_temp/peaks.mif -abs ${thr1} template/fixel_temp/mask.mif

# Generate an analysis voxel mask from the fixel mask. The median filter in this step should remove spurious voxels outside 
# the brain, and fill in the holes in deep white matter where you have small peaks due to 3-fibre crossings:
fixel2voxel -force template/fixel_temp/mask.mif max - | mrfilter - median template/voxel_mask.mif
# rm -rf template/fixel_temp

# Recompute the fixel mask using the analysis voxel mask. Using the mask allows us to use a lower AFD threshold than possible 
# in the steps above, to ensure we have included fixels with low AFD inside white matter (e.g. areas with fibre crossings):
rm -f template/fixel_mask/*
thr2=0.15
fod2fixel -force template/wmfod_template.mif -mask template/voxel_mask.mif -fmls_peak_value ${thr2} template/fixel_mask

# We recommend having no more than 500,000 fixels in the analysis fixel mask (you can check this by 
# mrinfo -size ../template/fixel/mask.mif 
# and looking at the size of the image along the 1st dimension), 
# otherwise downstream statistical analysis (using fixelcfestats) will run out of RAM). 
# A mask with 500,000 fixels will require a PC with 128GB of RAM for the statistical analysis step. 
# To reduce the number of fixels, try changing the thresholds in this step, or reduce the extent of upsampling in step 7.

