#!/bin/bash

merge_map(){
	cohortFolder=$1

	if [ -d "${cohortFolder}/seed_based" ]; then
		rm -fr ${cohortFolder}/seed_based
	fi

	mkdir ${cohortFolder}/seed_based

	str=""
	while read studyFolder
	do
		corrCoeffMap=${studyFolder}/seed-based/SCA_result.nii.gz
		str="${str}${corrCoeffMap} "
	done < ${cohortFolder}/studyFolder.list

	echo "Merging individual corrCoeffMap to cohortFolder/seed_based/ind_corrCoeffMap_4D ..."
	fslmerge -t ${cohortFolder}/seed_based/ind_corrCoeffMap_4D ${str}
}

merge_map $1