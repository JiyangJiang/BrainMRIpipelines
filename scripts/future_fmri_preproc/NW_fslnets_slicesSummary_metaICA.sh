#!/bin/bash

# ============================================================
# DESCRIPTION
# ============================================================
#
# This script generates slices summary for meta ICA
# results (melodic_IC.nii.gz).
#
#
# USAGE
# ============================================================
#
# $1 : path to cohort folder.
#
# $2 : number of individual ICAs.
#
# $3 : dimensionality of meta ICA.
#
# $4 : isotropic resampling scale.
#
# ============================================================

cohortFolder=$1
N_indICA=$2
N_dim_metaICA=$3
iso_resample_scale=$4

for i in `ls -d ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_*/metaICA/d${N_dim_metaICA}`
do
	melodic_IC_noiseRm=${i}/melodic_IC.nii.gz

	echo
	echo "$(basename $(which $0)) : !!! Note that melodic_IC.nii.gz is used for slices summary !!!"
	echo

	slices_summary ${melodic_IC_noiseRm} \
				   3.2 \
				   ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${iso_resample_scale}mm \
				   ${i}/melodic_IC_noiseRemoved.sum \
				   -1 \
				   -d

	echo "$(basename $(which $0)) : slice summary in ${i}/melodic_IC_noiseRemoved.sum"
done

