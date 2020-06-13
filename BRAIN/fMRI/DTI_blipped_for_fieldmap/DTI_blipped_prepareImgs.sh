#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

DTI_blipped_prepareImgs(){
	DICOM_folder=$1
	ID=$2
	subjects_folder=$3

	echo "DTI_blipped_prepareImgs.sh: Preparing blipped pairs for field map."

	if [ ! -d "${subjects_folder}/${ID}/fMRI" ]; then
		mkdir ${subjects_folder}/${ID}/fMRI
	fi

	if [ -d "${subjects_folder}/${ID}/fMRI/DTI_blipped_for_fieldmap" ]; then
		rm -fr ${subjects_folder}/${ID}/fMRI/DTI_blipped_for_fieldmap
	fi

	mkdir ${subjects_folder}/${ID}/fMRI/DTI_blipped_for_fieldmap

	wd=${subjects_folder}/${ID}/fMRI/DTI_blipped_for_fieldmap

	cp ${DICOM_folder}/${ID}_*_DTI_Blipped_FOR_FMRI*.nii \
		${wd}

	mv ${wd}/${ID}_*_DTI_Blipped_FOR_FMRI*.nii \
		${wd}/${ID}_blipped_DTI_raw.nii

	fslroi ${wd}/${ID}_blipped_DTI_raw.nii \
		   ${wd}/${ID}_blipped_DTI_raw_1stVol \
		   0 1

	cp ${DICOM_folder}/${ID}_*_MB_rs*.nii \
		${wd}/${ID}_fMRI_raw.nii

	fslroi ${wd}/${ID}_fMRI_raw.nii \
		   ${wd}/${ID}_fMRI_raw_5thVol \
		   4 1

	fslmerge -t ${wd}/${ID}_blipped_pairs \
				${wd}/${ID}_fMRI_raw_5thVol \
				${wd}/${ID}_blipped_DTI_raw_1stVol

	}

DTI_blipped_prepareImgs $1 $2 $3