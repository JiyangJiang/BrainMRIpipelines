#!/bin/bash

# note that this is in subjectFolder order (i.e. input.list order)
# when doing dual regression in DARTEL space, different order is
# used. the correct GM cov map is created by 
# H-lv_spm_metaICA_alterCovFileAndGMcovMap4spmOrder.sh

cohortFolder=$1
resample_flag=$2
iso_resample_scale=$3

[ -f "${cohortFolder}/confounds/GMcovMap/spm.smwc1.list" ] && \
	rm -f ${cohortFolder}/confounds/GMcovMap/spm.smwc1.list

list=""

while read studyFolder
do
	subjID=$(basename ${studyFolder})
	ind_gm=`ls ${cohortFolder}/spm/grp*/smwc1${subjID}_anat.nii`
	echo "${list} ${ind_gm}" >> ${cohortFolder}/confounds/GMcovMap/spm.smwc1.list
done < ${cohortFolder}/studyFolder.list

fslmerge -t ${cohortFolder}/confounds/GMcovMap/spm_smwc1_gmCovMap \
		 $(cat ${cohortFolder}/confounds/GMcovMap/spm.smwc1.list | tr '\n' ' ')


flirt -in ${cohortFolder}/confounds/GMcovMap/spm_smwc1_gmCovMap \
	  -ref ${cohortFolder}/confounds/GMcovMap/spm_smwc1_gmCovMap \
	  -applyisoxfm ${iso_resample_scale} \
	  -init ${cohortFolder}/groupICA/resampled_MNI/eye.mat \
	  -out ${cohortFolder}/confounds/GMcovMap/spm_smwc1_gmCovMap_${iso_resample_scale}mm