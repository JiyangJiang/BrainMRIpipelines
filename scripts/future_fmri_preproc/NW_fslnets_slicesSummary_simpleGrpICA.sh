#!/bin/bash

# ============================================================
# DESCRIPTION
# ============================================================
#
# This script generates slices summary for simple group ICA
# results (melodic_IC.nii.gz).
#
#
# USAGE
# ============================================================
#
# $1 : path to cohort folder.
#
# $2 : dimensionality for the group ICA.
#
# $3 : isotropic resampling scale.
#
# ============================================================

cohortFolder=$1
Ndim=$2
iso_resample_scale=$3

melodic_IC=${cohortFolder}/groupICA/d${Ndim}/melodic_IC.nii.gz

slices_summary ${melodic_IC} \
			   3.2 \
			   ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${iso_resample_scale}mm \
			   ${cohortFolder}/groupICA/d${Ndim}/melodic_IC.sum \
			   -1 \
			   -d

echo "$(basename $(which $0)) : slice summary in ${cohortFolder}/groupICA/d${Ndim}/melodic_IC.sum"

