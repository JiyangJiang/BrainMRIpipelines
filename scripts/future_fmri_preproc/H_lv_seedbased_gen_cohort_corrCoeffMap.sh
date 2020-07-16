#!/bin/bash

cohort_SCA(){

	cohortFolder=$1
	cleanup_type=$2
	MNI_seed=$3
	proc_mod=$4
	max_Ncores=$5

	curr_dir=$(dirname $(which $0))

	while read studyFolder
	do
		ID=$(basename ${studyFolder})

		case ${proc_mod} in
			sin)

				${curr_dir}/H_lv_seedbased_gen_ind_corrCoeffMap.sh ${cohortFolder} \
															 	   ${ID} \
																   ${cleanup_type} \
															 	   ${MNI_seed}

				;;

			par_Mcore)

				${curr_dir}/H_lv_seedbased_gen_ind_corrCoeffMap.sh ${cohortFolder} \
															 	   ${ID} \
																   ${cleanup_type} \
															 	   ${MNI_seed} &

				[ $(jobs | wc -l) -ge ${max_Ncores} ] && wait
				;;

			par_cluster)

				# ---=== NOT IMPLEMENTED YET ===---#

				;;
		esac

	done < ${cohortFolder}/studyFolder.list


	# wait the previous step to finish
	[ $(jobs | wc -l) -gt "0" ] && wait
}

cohort_SCA $1 $2 $3 $4 $5