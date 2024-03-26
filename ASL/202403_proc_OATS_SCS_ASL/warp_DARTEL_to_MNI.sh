#!/bin/bash

invwarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --warp=${BMP_PATH}/ASL/202403_proc_OATS_SCS_ASL/MNI2DARTEL_flowMap_65to75 --out=${BMP_PATH}/ASL/202403_proc_OATS_SCS_ASL/DARTEL2MNI_flowMap_65to75



applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=my_structural --warp=my_nonlinear_transf --out=my_warped_structural