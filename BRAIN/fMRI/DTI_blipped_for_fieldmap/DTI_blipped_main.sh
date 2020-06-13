#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

DTI_blipped_main(){
	subjects_folder=$1
	ID=$2
	DICOM_folder=$3

	curr_folder=$(dirname $0)

	${curr_folder}/DTI_blipped_prepareImgs.sh ${DICOM_folder} \
											  ${ID} \
											  ${subjects_folder}

	${curr_folder}/DTI_blipped_topup.sh ${subjects_folder} \
										${ID}


	echo "DTI_blipped_main.sh: Distortion correction using blipped DTI completed."
}

DTI_blipped_main $1 $2 $3