#!/bin/bash

# USAGE
# ==================================================================
#
# if simple group ICA
#
# 	$1 : path to cohort folder.
#
# 	$2 : dimensionality for the group ICA.
#
#	$3 : isotropic resampling scale.
#
#
# if meta ICA
#
# 	$1 : path to cohort folder.
#
# 	$2 : number of individual ICAs.
#
# 	$3 : dimensionality of meta ICA.
#
# 	$4 : isotropic resampling scale.
#
# =================================================================

curr_dir=$(dirname $(which $0))

if [ _$4 = _ ]; then

	# simple group ICA
	${curr_dir}/NW_fslnets_slicesSummary_simpleGrpICA.sh $1 $2 $3

else

	# meta ICA
	${curr_dir}/NW_fslnets_slicesSummary_metaICA.sh $1 $2 $3 $4

fi