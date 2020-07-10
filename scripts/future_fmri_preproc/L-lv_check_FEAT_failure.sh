#!/bin/bash

# if using cluster parallel processing, wait until all finish
# and check if any failed FEAT.
# -----------------------------------------------------------

check_FEAT_failure(){
	sge_acc=$1
	cohortFolder=$2
	cleanup_mode=$3

	sge_batch_jobs_left=$(qstat -u "${sge_acc}" | grep "${sge_acc}" | wc -l)

	# wait until jobs finishes
	while [ ${sge_batch_jobs_left} -ne 0 ]
	do
		echo "Still existing ${sge_batch_jobs_left} jobs, check again in 5 mins ..."
		sleep 5m
		sge_batch_jobs_left=$(qstat -u "${sge_acc}" | grep "${sge_acc}" | wc -l)
	done

	# check failure
	if [ -d ${cohortFolder}/failed_FEAT ]; then
		rm -fr ${cohortFolder}/failed_FEAT
	fi
	mkdir ${cohortFolder}/failed_FEAT

	while read studyDIR
	do
		if [ ! -f "${studyDIR}/$(basename ${studyDIR})_func.feat/filtered_func_data.nii.gz" ]; then
			echo "$(basename ${studyDIR}) failed."
			echo "moving to failed_FEAT folder."
			mv ${studyDIR} ${cohortFolder}/failed_FEAT
		fi
	done < ${cohortFolder}/studyFolder.list

	# re-do Ini_genLists.sh
	echo "Re-generating the lists."
	$(dirname $(which $0))/Ini_genLists.sh ${cohortFolder} \
										   ${cleanup_mode}

	echo "Finished checking FEAT failures."
}

check_FEAT_failure $1 $2 $3