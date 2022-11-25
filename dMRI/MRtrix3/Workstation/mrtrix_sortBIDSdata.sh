#!/bin/bash

# DESCRIPTION :
# -----------------------------------------------------------------------------------------------------
# This script convert all nii/bvec/bval in BIDS folder to mif, and saved in derivatives/mrtrix/orig_mif.
#
#
# USAGE :
# -----------------------------------------------------------------------------------------------------
# $1 = path to BIDS folder
#
# -----------------------------------------------------------------------------------------------------
# Dr. Jiyang Jiang     January 22, 2019


sortBIDSdata(){

	BIDS_folder=$1

	cd ${BIDS_folder}

	if [ -d "derivatives/mrtrix/orig_mif" ]; then
		rm -fr derivatives/mrtrix/orig_mif
	fi

	mkdir -p derivatives/mrtrix/orig_mif



	for subject in `ls -d sub-*`
	do
		if [ -d "${subject}/dwi" ]; then
			cd ${subject}/dwi

			for dwi in `ls ${subject}*_dwi.nii*`
			do
				dwi_run_name=$(echo ${dwi} | awk -F '.' '{print $1}')

				mrconvert ${dwi} \
						  -fslgrad ${dwi_run_name}.bvec ${dwi_run_name}.bval \
						  -json_import ${dwi_run_name}.json \
						  ${BIDS_folder}/derivatives/mrtrix/orig_mif/${dwi_run_name}.mif
			done

			cd ${BIDS_folder}
		else
			echo "WARNING : No dwi folder for ${subject}."
		fi
	done
}

sortBIDSdata $1