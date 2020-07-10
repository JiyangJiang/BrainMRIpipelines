#!/bin/bash

#                EXPLANATIONS OF THE STRUCTURE OF GROUP-ICA OUTPUT
# -----------------------------------------------------------------------------------
#
# melodic_oIC.nii.gz - original ICs before transforming to voxel-wise z-stats,
#                      i.e. before scaling by the residual noise std deviation.
#
# melodic_IC.nii.gz - un-thresholded, un-normalised z-stats map.
#
# In order to threshold ICs using mixture-model-based thresholding, we will need
# probability maps (probmap_*.nii.gz) and z-stats maps (thresh_zstat*.nii.gz) in
# the "stats" folder. Since in H-lv_grpICA_dualReg_grpComp.sh we set the threshold
# to be mmthresh=0, thresh_zstat*.nii.gz are not really thresholded. In this script,
# we will threshold probmap_*.nii.gz with user-defined probability threshold 
# (melodic default = 0.5), and using the resultant mask to mask thresh_zstat*.nii.gz.
#
# Note that probmap_*.nii.gz are (1-p) images.
#
#
#
# UPDATE (March 19, 2019) : H-lv_grpICA_dualReg_grpComp.sh is modified to threshold
#                           at level of 0.5 within the invoking of 'melodic', as 
#                           using this script to threshold will introduce error in
#                           the following dual regression step.
#
# ===================================================================================
#
# USAGE:
#
# $1 : path to cohort folder.
#
# $2 : ICA dimensionality. 'auto' if automatically determining number of ICs using PCA.
#
# $3 : probability threshold. Note that this will be (1-P) threshold because the
#      probmap_*.nii.gz are (1-p) maps. Therefore, set to 0.95 if you want to threshold
#      at probabability level of 0.05. '0.5' is MELODIC default to get an equal balance
#      between false positives and false negatives.


thr_ICs(){

	cohortFolder=$1
	dimensionality=$2
	threshold=$3
	
	stats_folder=${cohortFolder}/groupICA/d${dimensionality}/stats

	# thresholded z-stat maps output folder = stats/thr_zstats
	# thresh_zstat*.nii.gz in stats folder will always be
	# untouched, and therefore always unthresholded.
	if [ -d "${stats_folder}/thr_zstats" ]; then
		rm -fr ${stats_folder}/thr_zstats
	fi

	mkdir ${stats_folder}/thr_zstats


	# empty image for output
	fslmaths ${stats_folder}/thresh_zstat1 \
			 -mul 0 \
			 ${cohortFolder}/groupICA/d${dimensionality}/melodic_IC_MM


	# number of ICs
	N_ICs=$(ls -1 ${stats_folder}/probmap_*.nii.gz | wc -l)

	# threshold z-stats maps with probability threshold
	for index in $(seq 1 ${N_ICs})
	do
		# index=$(basename $i | awk -F'_' '{print $2}' | awk -F'.' '{print $1}')
		echo "$(basename $0) : Thresholding IC${index} with mixture modelling (${N_ICs} ICs in totoal) ..."

		fslmaths ${stats_folder}/probmap_${index} \
				 -thr ${threshold} \
				 -bin \
				 -mul ${stats_folder}/thresh_zstat${index} \
				 ${stats_folder}/thr_zstats/thresh_zstat${index}

	 	# merging thresholded z-stats (of each IC) into one 4D image
	 	if [ ${index} = "1" ]; then
	 		fslmaths ${stats_folder}/thr_zstats/thresh_zstat${index} \
	 				 ${cohortFolder}/groupICA/d${dimensionality}/melodic_IC_MM
	 	else
			fslmerge -t ${cohortFolder}/groupICA/d${dimensionality}/melodic_IC_MM \
					 ${cohortFolder}/groupICA/d${dimensionality}/melodic_IC_MM \
					 ${stats_folder}/thr_zstats/thresh_zstat${index}
		fi
	done



}

thr_ICs $1 $2 $3