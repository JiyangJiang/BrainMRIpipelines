#!/bin/bash

# temporal SD of preprocessed fMRI

cohortFolder=$1
cleanup_mode=$2
qsub_flag=$3

[ -f "${cohortFolder}/SGE_commands/qc_func_Tstd.fslsub.1" ] && \
	rm -f ${cohortFolder}/SGE_commands/qc_func_Tstd.fslsub.1

while read subjectFolder
do
	subjID=$(basename ${subjectFolder})

	case ${cleanup_mode} in
		fix)
			finalEPI="${cohortFolder}/${subjID}/${subjID}_func.ica/post-FIX/final_cleanedup_func_std_space"
			;;
		aroma)
			finalEPI="${cohortFolder}/${subjID}/${subjID}_func.feat/post-ICA_AROMA/final_cleanedup_func_std_space"
			;;
	esac

	echo "$FSLDIR/bin/fslmaths ${finalEPI} -Tstd ${cohortFolder}/qc/func_mni_Tstd/${subjID}_func_mni_Tstd" \
		>> ${cohortFolder}/SGE_commands/qc_func_Tstd.fslsub.1

done < ${cohortFolder}/studyFolder.list

echo "cd ${cohortFolder}/qc/func_mni_Tstd; slicesdir \`$FSLDIR/bin/imglob *_func_mni_Tstd*\`" \
	> ${cohortFolder}/SGE_commands/qc_func_Tstd.fslsub.2

echo "cd ${cohortFolder}/qc/func_mni_Tstd; imrm *" \
	> ${cohortFolder}/SGE_commands/qc_func_Tstd.fslsub.3

if [ "${qsub_flag}" = "yesQsub" ]; then
	Tstd_1_jid=`$FSLDIR/bin/fsl_sub -T 10 -N Tstd_1 -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/qc_func_Tstd.fslsub.1`
	Tstd_2_jid=`$FSLDIR/bin/fsl_sub -T 120 -N Tstd_2 -l ${cohortFolder}/SGE_commands/oe -j ${Tstd_1_jid} -t ${cohortFolder}/SGE_commands/qc_func_Tstd.fslsub.2`
	Tstd_3_jid=`$FSLDIR/bin/fsl_sub -T 120 -N Tstd_3 -l ${cohortFolder}/SGE_commands/oe -j ${Tstd_2_jid} -t ${cohortFolder}/SGE_commands/qc_func_Tstd.fslsub.3`
fi