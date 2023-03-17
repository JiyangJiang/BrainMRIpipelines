#!/bin/bash

Xbrain(){

	local SPM12_path=$1
	local anat=$2

	anat_folder=$(dirname ${anat})
	anat_filename=`echo $(basename ${anat}) | awk -F'.nii' '{print $1}'`
	anat_gz=`echo $(basename ${anat}) | awk -F'.nii' '{print $2}'`

	# if anat is gzip'ed
	[ "${anat_gz}" = ".gz" ] && \
		gunzip ${anat} && \
		anat="${anat_folder}/${anat_filename}.nii"

	# temp folder to contain intermediate output: c1/2/3, rc1/2/3, seg8mat
	if [ ! -d "${anat_folder}/temp" ]; then
		mkdir ${anat_folder}/temp
	fi

	matlab -nodisplay \
	   	   -nosplash \
		   -r \
		   "BMP_PATH = getenv ('BMP_PATH');\
		   	addpath ('${BMP_PATH}/fMRI');\
		    [c1,c2,c3,rc1,rc2,rc3,seg8mat] = bmp_fmri_ini_Xbrain_SPMsegment('${anat}','${SPM12_path}');\
		    bmp_fmri_ini_Xbrain_SPMnbtrN ('${anat}',c1,c2,c3,'${anat_folder}/${anat_filename}_brain');\
		    movefile (c1, '${anat_folder}/temp');\
		    movefile (c2, '${anat_folder}/temp');\
		    movefile (c3, '${anat_folder}/temp');\
		    movefile (rc1, '${anat_folder}/temp');\
		    movefile (rc2, '${anat_folder}/temp');\
		    movefile (rc3, '${anat_folder}/temp');\
		    movefile (seg8mat, '${anat_folder}/temp');\
		    exit"

}

f_xbrain(){
		local studyFolder=$1
		local anat_filename=$2
		local SPM12_path=$3
		local overwrite_f=$4

		anat=`ls ${studyFolder}/${anat_filename}.nii*`

		if [ -f "${studyFolder}/${anat_filename}_brain.nii.gz" ] \
			&& [ "${overwrite_f}" = "skip" ]; then

			echo
			echo "${anat_filename}_brain exists, skipping ..."
			echo
		
		elif [ -f "${studyFolder}/${anat_filename}_brain.nii.gz" ] \
			&& [ "${overwrite_f}" = "overwrite" ]; then

			echo
			echo "${anat_filename} exists, but overwriting ..."
			echo

			Xbrain ${SPM12_path} ${anat}

		elif [ ! -f "${studyFolder}/${anat_filename}_brain.nii.gz" ]; then

			echo
			echo "Non-brain tissue removal on ${anat_filename} ..."
			echo

			Xbrain ${SPM12_path} ${anat}

		fi
}

f_xbrain $1 $2 $3 $4