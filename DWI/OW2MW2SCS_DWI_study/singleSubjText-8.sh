#!/bin/bash

# 14. Warp FOD images to template space
# +++++++++++++++++++++++++++++++++++++
# Note that here we warp FOD images into template space without FOD reorientation. Reorientation will be performed in a separate subsequent step:
mrtransform -force wmfod_norm.mif -warp subject2template_warp.mif -reorient_fod no fod_in_template_space.mif

# 15. Segment FOD images to estimate fixels and their apparent fibre density (FD)
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Here we segment each FOD lobe to identify the number and orientation of fixels in each voxel. 
# The output also contains the apparent fibre density (AFD) value per fixel estimated as the FOD lobe integral 
# (see here for details on FOD segmentation). Note that in the following steps we will use a more generic shortened 
# acronym - Fibre Density (FD) instead of AFD, since the following steps can also apply for other measures of fibre density 
# (see the note below). The terminology is also consistent with our recent work:
fod2fixel -force fod_in_template_space.mif -mask ../template/voxel_mask.mif fixel_in_template_space -afd fd.mif