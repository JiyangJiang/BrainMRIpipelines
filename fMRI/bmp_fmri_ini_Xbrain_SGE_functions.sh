#!/bin/bash

Xbrain(){

	local Sfolder=$1

	# if struc is gzip'ed
	struc_gz=`basename $(ls ${Sfolder}/struc.nii*) | awk -F'.nii' '{print $2}'`
	[ "${struc_gz}" = ".gz" ] && gunzip ${Sfolder}/struc.nii.gz

	# temp folder to contain intermediate output: c1/2/3, rc1/2/3, seg8mat
	if [ ! -d "${Sfolder}/temp" ]; then
		mkdir ${Sfolder}/temp
	fi

	matlab -nodisplay \
	   -nosplash \
	   -r \
	   "BMP_PATH = getenv ('BMP_PATH');\
	    BMP_SPM_PATH = getenv ('BMP_SPM_PATH');\
	   	addpath ('${BMP_PATH}/fMRI');\
	    [c1,c2,c3,rc1,rc2,rc3,seg8mat] = bmp_fmri_ini_Xbrain_SPMsegment('${Sfolder}/struc.nii','${BMP_SPM_PATH}');\
	    bmp_fmri_ini_Xbrain_SPMnbtrN ('${Sfolder}/struc.nii',c1,c2,c3,'${Sfolder}/struc_brain','maskout');\
	    movefile (c1, '${Sfolder}/temp');\
	    movefile (c2, '${Sfolder}/temp');\
	    movefile (c3, '${Sfolder}/temp');\
	    movefile (rc1, '${Sfolder}/temp');\
	    movefile (rc2, '${Sfolder}/temp');\
	    movefile (rc3, '${Sfolder}/temp');\
	    movefile (seg8mat, '${Sfolder}/temp');\
	    exit"

}

f_xbrain $1