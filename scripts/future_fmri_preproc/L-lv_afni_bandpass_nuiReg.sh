#!/bin/bash

# --------------------------------------- #
# This script conducts bandpass           #
# after nuisance regression before        #
# spatial normalisation.                  #
# --------------------------------------- #


cohortFolder=$1
cleanup_mode=$2

# echo "$(basename $0) : running, this will take some time ..."

[ -f ${cohortFolder}/SGE_commands/bandpassA ] && rm -f ${cohortFolder}/SGE_commands/bandpassA
[ -f ${cohortFolder}/SGE_commands/bandpassB ] && rm -f ${cohortFolder}/SGE_commands/bandpassB
[ -f ${cohortFolder}/SGE_commands/bandpassC ] && rm -f ${cohortFolder}/SGE_commands/bandpassC
[ -f ${cohortFolder}/SGE_commands/bandpassD ] && rm -f ${cohortFolder}/SGE_commands/bandpassD
[ -f ${cohortFolder}/SGE_commands/bandpassE ] && rm -f ${cohortFolder}/SGE_commands/bandpassE

while read studyFolder
do
	subjID=$(basename ${studyFolder})

	case ${cleanup_mode} in
		aroma)
			postcleanup_folder=${studyFolder}/${subjID}_func.feat/post-ICA_AROMA
			;;
		fix)
			postcleanup_folder=${studyFolder}/${subjID}_func.ica/post-FIX
			;;
	esac

	nuiReg_func=${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func.nii.gz
	nuiReg_func_bandpass=${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func_bandpass.nii.gz
	nuiReg_func_noBandpass=${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func_noBandpass.nii.gz

	if [ ! -f "${nuiReg_func_noBandpass}" ]; then

		# echo "Not bandpassed before."

		echo "cp ${nuiReg_func} ${nuiReg_func_noBandpass};fslmaths ${nuiReg_func} -Tmean $(remove_ext ${nuiReg_func})_Tmean" \
			>> ${cohortFolder}/SGE_commands/bandpassA

		# echo "3dBandpass -prefix ${postcleanup_folder}/bandpass -automask -blur 6 -despike 0.009 0.08 ${nuiReg_func}" \
		# 	>> ${cohortFolder}/SGE_commands/bandpassB
		echo "3dBandpass -prefix ${postcleanup_folder}/bandpass -automask 0.009 0.08 ${nuiReg_func}" \
			>> ${cohortFolder}/SGE_commands/bandpassB

		echo "3dAFNItoNIFTI -prefix ${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func ${postcleanup_folder}/bandpass+orig" \
			>> ${cohortFolder}/SGE_commands/bandpassC

		echo "gzip -f ${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func.nii;cp ${nuiReg_func} ${nuiReg_func_bandpass}" \
			>> ${cohortFolder}/SGE_commands/bandpassD

		echo "rm -f ${postcleanup_folder}/bandpass+orig.*;fslmaths ${nuiReg_func} -add $(remove_ext ${nuiReg_func})_Tmean ${nuiReg_func}" \
			>> ${cohortFolder}/SGE_commands/bandpassE
	else

		# echo "already bandpassed. redoing with non-bandpassed image."

		echo "cp ${nuiReg_func_noBandpass} ${nuiReg_func};fslmaths ${nuiReg_func} -Tmean $(remove_ext ${nuiReg_func})_Tmean" \
			>> ${cohortFolder}/SGE_commands/bandpassA

		# echo "3dBandpass -prefix ${postcleanup_folder}/bandpass -automask -blur 6 -despike 0.009 0.08 ${nuiReg_func}" \
		# 	>> ${cohortFolder}/SGE_commands/bandpassB
		echo "3dBandpass -prefix ${postcleanup_folder}/bandpass -automask 0.009 0.08 ${nuiReg_func}" \
			>> ${cohortFolder}/SGE_commands/bandpassB

		echo "3dAFNItoNIFTI -prefix ${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func ${postcleanup_folder}/bandpass+orig" \
			>> ${cohortFolder}/SGE_commands/bandpassC

		echo "gzip -f ${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func.nii;cp ${nuiReg_func} ${nuiReg_func_bandpass}" \
			>> ${cohortFolder}/SGE_commands/bandpassD

		echo "rm -f ${postcleanup_folder}/bandpass+orig.*;fslmaths ${nuiReg_func} -add $(remove_ext ${nuiReg_func})_Tmean ${nuiReg_func}" \
			>> ${cohortFolder}/SGE_commands/bandpassE
	fi

done < ${cohortFolder}/studyFolder.list

bandpassA_jid=`fsl_sub -T 5 -N bandpassA -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/bandpassA`
bandpassB_jid=`fsl_sub -T 30 -N bandpassB -l ${cohortFolder}/SGE_commands/oe -j ${bandpassA_jid} -t ${cohortFolder}/SGE_commands/bandpassB`
bandpassC_jid=`fsl_sub -T 15 -N bandpassC -l ${cohortFolder}/SGE_commands/oe -j ${bandpassB_jid} -t ${cohortFolder}/SGE_commands/bandpassC`
bandpassD_jid=`fsl_sub -T 5 -N bandpassD -l ${cohortFolder}/SGE_commands/oe -j ${bandpassC_jid} -t ${cohortFolder}/SGE_commands/bandpassD`
bandpassE_jid=`fsl_sub -T 5 -N bandpassE -l ${cohortFolder}/SGE_commands/oe -j ${bandpassD_jid} -t ${cohortFolder}/SGE_commands/bandpassE`

echo ${bandpassE_jid}