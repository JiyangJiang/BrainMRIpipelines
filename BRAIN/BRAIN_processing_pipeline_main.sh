#!/bin/bash

BRAIN_processing_pipeline(){

	studyFolder=$1
	ID=$2
	DICOM_folder=$3

	subjects_folder=${studyFolder}/subjects

	if [ ! -d "${subjects_folder}" ]; then
		mkdir ${subjects_folder}
	fi

	if [ -d "${subjects_folder}/${ID}" ]; then
		rm -fr ${subjects_folder}/${ID}
	fi	
	mkdir ${subjects_folder}/${ID}

	curr_folder=$(dirname $0)

	# Fieldmap from scanner
	${curr_folder}/Fieldmap/BRAIN_Fieldmap_main.sh ${DICOM_folder} \
												   ${ID} \
												   ${subjects_folder}


	# Fieldmap from blipped fMRI
	${curr_folder}/fMRI/fMRI_blipped_for_fieldmap/fMRI_blipped_main.sh ${subjects_folder} \
																  	   ${ID} \
																       ${DICOM_folder}


	# Fieldmap from blipped DTI
	${curr_folder}/fMRI/DTI_blipped_for_fieldmap/DTI_blipped_main.sh ${subjects_folder} \
																     ${ID} \
																     ${DICOM_folder}

}

BRAIN_processing_pipeline $1 $2 $3