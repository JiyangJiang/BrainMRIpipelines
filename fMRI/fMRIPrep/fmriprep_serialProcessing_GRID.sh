#!/bin/bash

BIDS_dir=/data2/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS
OUTPUT_dir=/data2/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS/derivatives/fmriprep-v1.5.2
WORK_dir=/data2/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS/derivatives/fmriprep-v1.5.2/work

mkdir -p ${OUTPUT_dir}/log
rm -f ${OUTPUT_dir}/log/*

for i in `ls -d ${BIDS_dir}/sub-*`
do
	sub_pptID=$(basename $i)
	pptID=$(echo ${sub_pptID} | awk -F '-' '{print $2}')

	echo "Running ${sub_pptID} ..."

	fmriprep-docker /data2/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS \
	                /data2/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS/derivatives/fmriprep-v1.5.2 \
	                participant \
	                --fs-license-file /data2/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS/code/fs_license.txt \
	                --participant_label ${pptID} \
	                --work-dir /work \
	                --skip_bids_validation \
	                --ignore {fieldmaps,slicetiming} \
	                --output-spaces MNI152NLin6Asym:res-2 MNI152NLin2009cAsym \
	                > ${OUTPUT_dir}/log/${sub_pptID}_fmriprep.log

done
