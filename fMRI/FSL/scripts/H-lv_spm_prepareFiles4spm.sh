#!/bin/bash

cohortFolder=$1
cleanup_mode=$2

while read studyFolder
do
	subjID=$(basename ${studyFolder})

	# spm/coreg_epi_anat
	case ${cleanup_mode} in
		fix)
			cp ${studyFolder}/${subjID}_func.ica/post-FIX/nuisanceReg_Tfiltered_cleanedup_func.nii.gz \
				${cohortFolder}/spm/coreg_epi_anat/${subjID}_preproc_func_indSpace.nii.gz

			cp ${studyFolder}/${subjID}_func.ica/example_func.nii.gz \
				${cohortFolder}/spm/coreg_epi_anat/${subjID}_example_func.nii.gz
			;;
		aroma)
			cp ${studyFolder}/${subjID}_func.feat/post-ICA_AROMA/nuisanceReg_Tfiltered_cleanedup_func.nii.gz \
				 ${cohortFolder}/spm/coreg_epi_anat/${subjID}_preproc_func_indSpace.nii.gz

			cp ${studyFolder}/${subjID}_func.feat/example_func.nii.gz \
				${cohortFolder}/spm/coreg_epi_anat/${subjID}_example_func.nii.gz
			;;
	esac

done < ${cohortFolder}/studyFolder.list


# spm/coreg_epi_anat
cp ${cohortFolder}/*/*_anat.nii* ${cohortFolder}/spm/coreg_epi_anat/.


if [ -f "${cohortFolder}/studyFolder.list.grp1" ] && \
	[ -f "${cohortFolder}/studyFolder.list.grp2" ]; then

	while read studyFolder
	do
		subjID=$(basename ${studyFolder})

		# spm/grp1
		cp ${studyFolder}/${subjID}_anat.nii* \
			${cohortFolder}/spm/grp1/.

	done < ${cohortFolder}/studyFolder.list.grp1





	while read studyFolder
	do
		subjID=$(basename ${studyFolder})

		# spm/grp2
		cp ${studyFolder}/${subjID}_anat.nii* \
			${cohortFolder}/spm/grp2/.

	done < ${cohortFolder}/studyFolder.list.grp2

else

	echo "WARNING : no studyFolder.list.grp? "
fi

gunzip -f ${cohortFolder}/spm/*/*.gz