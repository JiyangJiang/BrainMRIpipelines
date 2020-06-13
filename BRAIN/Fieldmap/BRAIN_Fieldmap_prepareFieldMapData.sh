#!/bin/bash

#
# DESCRIPTION
# -----------
# This script prepares the mag+phase NIfTI images converted from DICOM for generating the field maps
#
# USAGE
# -----
# <path to BRAIN_processing_pipeline>/Fieldmap/BRAIN_Fieldmap_prepareFieldMapData.sh DICOM_folder \
#																					 ID \
#																					 subjects_folder
#
# where DICOM_folder is the DICOM folder. dcm2nii/dcm2niix will output converted NIfTI images to
# this DICOM folder if it is passed as an argument to dcm2nii/dcm2niix. subjects_folder is path to
# the "Subjects" folder where each ID has a subfolder storing all processed results.
#
# Written by Dr. Jiyang Jiang, March 2018
#

prepareFieldMapData(){
	DICOM_folder=$1
	ID=$2
	subjects_folder=$3

	echo "BRAIN_Fieldmap_prepareFieldMapData.sh: Preparing mag+phase data for processing (ID = ${ID}) ..."

	if [ -d "${subjects_folder}/${ID}/Fieldmap" ]; then
		rm -fr ${subjects_folder}/${ID}/Fieldmap
	fi

	mkdir ${subjects_folder}/${ID}/Fieldmap

	cp ${DICOM_folder}/*_FIELD_MAP*.nii ${subjects_folder}/${ID}/Fieldmap/.

	mv ${subjects_folder}/${ID}/Fieldmap/*_FIELD_MAP*_e2.nii ${subjects_folder}/${ID}/Fieldmap/${ID}_fieldmap_e2.nii
	mv ${subjects_folder}/${ID}/Fieldmap/*_FIELD_MAP*.nii ${subjects_folder}/${ID}/Fieldmap/${ID}_fieldmap_e1.nii

}

prepareFieldMapData $1 $2 $3