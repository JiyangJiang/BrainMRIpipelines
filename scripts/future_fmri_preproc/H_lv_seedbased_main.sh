#!/bin/bash

# $1 : cohort folder
#
# $2 : cleanup mode (aroma or fix)
#
# $3 : path to MNI space seed image
#
# $4 : sin or par_Mcore (par_cluster has not been implemented)
#
# $5 : maximal number of cores for multi-core parallel
#
# $6 : directory and root filename of the design matrix

seedbased(){

	cohortFolder=$1
	cleanup_mode=$2
	MNI_seed=$3
	proc_mode=$4
	max_Ncores=$5
	desmtx_dir_and_rootname=$6

	curr_dir=$(dirname $(which $0))

	# generate seed-based correlation coefficient map for each individual
	${curr_dir}/H_lv_seedbased_gen_cohort_corrCoeffMap.sh ${cohortFolder} \
														  ${cleanup_mode} \
														  ${MNI_seed} \
														  ${proc_mode} \
														  ${max_Ncores}

	# merge all individual correlation coefficient maps into one 4D image
	${curr_dir}/H_lv_seedbased_merge_ind_corrCoeffMap.sh ${cohortFolder}

	# randomise
	${curr_dir}/H_lv_seedbased_randomise.sh ${cohortFolder} \
											${desmtx_dir_and_rootname}

}

seedbased $1 $2 $3 $4 $5 $6