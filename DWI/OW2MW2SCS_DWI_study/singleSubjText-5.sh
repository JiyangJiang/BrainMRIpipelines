#!/bin/bash

# ---=== GROUP LEVEL ===---

work_dir=/home/jiyang/Work/dwi_test
cd ${work_dir}

mkdir -p template/fod_input template/mask_input

# !!! --> need to determine a subset for constructing template
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
for i in [0-9]*;do ln -sr $i/wmfod_norm.mif          template/fod_input/${i}.mif  ;done
for j in [0-9]*;do ln -sr $j/dwi_mask_upsampled.mif  template/mask_input/${j}.mif ;done

population_template -force -nthreads 44 template/fod_input -mask_dir template/mask_input template/wmfod_template.mif -voxel_size 1.25