#!/bin/bash

# 11. Register all subject FOD images to the FOD template
mrregister -force wmfod_norm.mif -mask1 dwi_mask_upsampled.mif ../template/wmfod_template.mif -nl_warp subject2template_warp.mif template2subject_warp.mif

# 12. Compute the intersection of all subject masks in template space
mrtransform -force dwi_mask_upsampled.mif -warp subject2template_warp.mif -interp nearest dwi_mask_in_template_space.mif