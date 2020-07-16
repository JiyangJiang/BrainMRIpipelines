#!/bin/bash

# =================================
# $1 = path to cohort folder
#
# $2 = dimentionality
#
# $3 = min display range (optional)
# =================================

vis_grpICs(){
	
	cohortFolder=$1
	dim=$2

	# optional
	# -----------------
	# min display range
	# default=10

	minRange=$3

	if [ -z ${minRange} ]; then
		minRange=10
	fi


	melodic_IC=${cohortFolder}/groupICA/d${dim}/melodic_IC

	fsleyes -std \
			${melodic_IC} \
			--useNegativeCmap \
			--cmap red-yellow \
			--negativeCmap blue-lightblue \
			--displayRange ${minRange} $(fslstats ${melodic_IC} -R | awk '{print $2}') \
			--name melodic_IC \
			&
}

vis_grpICs $1 $2 $3