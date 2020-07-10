#!/bin/bash

rand(){

	cohortFolder=$1
	desmtx_dir_and_rootname=$2

	randomise -i ${cohortFolder}/seed_based/ind_corrCoeffMap_4D \
			  -o ${cohortFolder}/seed_based/rand_out \
			  -d ${desmtx_dir_and_rootname}.mat \
			  -t ${desmtx_dir_and_rootname}.con \
			  -m ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask \
			  -n 5000 \
			  -T


}

rand $1 $2