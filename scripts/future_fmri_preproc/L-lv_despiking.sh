#!/bin/bash

cohortFolder=$1

[ -f "${cohortFolder}/SGE_commands/despike.fslsub" ] && \
	rm -f ${cohortFolder}/SGE_commands/despike.fslsub

while read studyFolder
do
	subjID=$(basename ${studyFolder})

	func_img=`ls ${studyFolder}/${subjID}_func.nii*`

	echo "cd ${studyFolder};3dDespike -ignore 10 -localedit -NEW -prefix ${studyFolder}/func_despike ${func_img};mv ${func_img} $(dirname ${func_img})/beforeDespiking_$(basename ${func_img});3dAFNItoNIFTI -prefix ${studyFolder}/${subjID}_func ${studyFolder}/func_despike+orig" \
		>> ${cohortFolder}/SGE_commands/despike.fslsub
done < ${cohortFolder}/studyFolder.list

fsl_sub -T 30 -N despike -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/despike.fslsub
