#!/bin/bash

# fsl_sub only

cohortFolder=$1
cleanup_mode=$2
qsub_flag=$3


[ -f "${cohortFolder}/SGE_commands/gen6motParam.fslsub" ] && \
	rm -f ${cohortFolder}/SGE_commands/gen6motParam.fslsub

while read studyFolder
do
	subjID=$(basename ${studyFolder})

	case ${cleanup_mode} in
	aroma)
		mc_folder=${cohortFolder}/${subjID}/${subjID}_func.feat/mc
		;;
	fix)
		mc_folder=${cohortFolder}/${subjID}/${subjID}_func.ica/mc
		;;
	esac

	echo "cp ${mc_folder}/prefiltered_func_data_mcf.par ${cohortFolder}/confounds/motion_params/${subjID}.6motion.params" \
		>> ${cohortFolder}/SGE_commands/gen6motParam.fslsub
done < ${cohortFolder}/studyFolder.list

[ "${qsub_flag}" = "yesQsub" ] && \
	fsl_sub -T 5 -N gen6motparam -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/gen6motParam.fslsub