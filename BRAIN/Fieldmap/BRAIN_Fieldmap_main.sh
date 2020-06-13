#!/bin/bash

#
# DESCRIPTION
# -----------
# This is the main function to process BRAIN fieldmaps
#
#
# USAGE
# -----
# <path to BRAIN_processing_pipeline>/Fieldmap/BRAIN_Fieldmap_main.sh DICOM_folder \
#																	  ID \
#																	  subjects_folder
#
# where DICOM_folder is the DICOM folder. dcm2nii/dcm2niix will output converted NIfTI images to
# this DICOM folder if it is passed as an argument to dcm2nii/dcm2niix. subjects_folder is path to
# the "Subjects" folder where each ID has a subfolder storing all processed results.
#
# Written by Dr. Jiyang Jiang, March 2018
#

Fieldmap_main(){

	DICOM_folder=$1
	ID=$2
	subjects_folder=$3
	
	fieldmapScriptsFolder=$(dirname $0)

	${fieldmapScriptsFolder}/BRAIN_Fieldmap_prepareFieldMapData.sh ${DICOM_folder} \
																	${ID} \
																	${subjects_folder}

	${fieldmapScriptsFolder}/BRAIN_Fieldmap_generateFieldmap.sh ${ID} \
																${subjects_folder}/${ID}/Fieldmap

	echo "BRAIN_Fieldmap_main.sh: Field map processing completed."
}

Fieldmap_main $1 $2 $3