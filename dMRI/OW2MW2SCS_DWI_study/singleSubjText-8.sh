#!/bin/bash

[ -d "fixel_in_template_space_NOT_REORIENTED" ] && rm -fr fixel_in_template_space_NOT_REORIENTED

# 14. Warp FOD images to template space
# +++++++++++++++++++++++++++++++++++++
# Note that here we warp FOD images into template space without FOD reorientation. Reorientation will be performed in a separate subsequent step:
mrtransform -force wmfod_norm.mif -warp subject2template_warp.mif -reorient_fod no fod_in_template_space_NOT_REORIENTED.mif

# 15. Segment FOD images to estimate fixels and their apparent fibre density (FD)
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Here we segment each FOD lobe to identify the number and orientation of fixels in each voxel. 
# The output also contains the apparent fibre density (AFD) value per fixel estimated as the FOD lobe integral 
# (see here for details on FOD segmentation). Note that in the following steps we will use a more generic shortened 
# acronym - Fibre Density (FD) instead of AFD, since the following steps can also apply for other measures of fibre density 
# (see the note below). The terminology is also consistent with our recent work:
fod2fixel -force -mask ../template/mask_intersection.mif fod_in_template_space_NOT_REORIENTED.mif fixel_in_template_space_NOT_REORIENTED -afd fd.mif

# The following are based on
# Ref: https://mrtrix.readthedocs.io/en/latest/fixel_based_analysis/mt_fibre_density_cross-section.html

# 15. Reorient fixels
fixelreorient -force fixel_in_template_space_NOT_REORIENTED subject2template_warp.mif fixel_in_template_space

# 16. Assign subject fixels to template fixels
fixelcorrespondence -force fixel_in_template_space/fd.mif ../template/fixel_mask ../template/fd $(basename $PWD).mif

# 17. Compute the fibre cross-section (FC) metric
warp2metric -force subject2template_warp.mif -fc ../template/fixel_mask ../template/fc $(basename $PWD).mif