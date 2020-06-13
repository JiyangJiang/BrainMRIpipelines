#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

fMRI_blipped_main(){
	subjects_folder=$1
	ID=$2
	DICOM_folder=$3

	curr_folder=$(dirname $0)

	${curr_folder}/fMRI_blipped_prepareNIfTIimgs.sh ${DICOM_folder} \
													${ID} \
													${subjects_folder}

	${curr_folder}/fMRI_blipped_topup.sh ${subjects_folder} \
										 ${ID}


	echo "fMRI_blipped_main.sh: Distortion correction using blipped fMRI completed."
}

fMRI_blipped_main $1 $2 $3