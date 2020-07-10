#!/bin/bash

# $3 = the EPI vol (index starting from 0) you want to visually QC (e.g. 100)

cohortFolder=$1
qsub_flag=$2
epi_vol_forQC=$3




# +++++++++++++++++++++++++++++++++++ #
# generating native space fMRI slices #
# +++++++++++++++++++++++++++++++++++ #

[ -f "${cohortFolder}/SGE_commands/qc_func_slices.fslsub.1" ] && \
	rm -f ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.1

[ -f "${cohortFolder}/SGE_commands/qc_func_slices.fslsub.2" ] && \
	rm -f ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.2

[ -f "${cohortFolder}/SGE_commands/qc_func_slices.fslsub.3" ] && \
	rm -f ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.3

[ -f "${cohortFolder}/SGE_commands/qc_func_slices.fslsub.4" ] && \
	rm -f ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.4

while read subjectFolder
do
	subjID=$(basename ${subjectFolder})

	echo "$FSLDIR/bin/imcp ${subjectFolder}/${subjID}_func ${cohortFolder}/qc/func_native_slices" \
		>> ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.1

	# echo "$FSLDIR/bin/fslsplit ${cohortFolder}/qc/func_native_slices/${subjID}_func ${cohortFolder}/qc/func_native_slices/${subjID}_func_vol- -t" \
	# 	>> ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.2

	echo "$FSLDIR/bin/fslroi ${cohortFolder}/qc/func_native_slices/${subjID}_func ${cohortFolder}/qc/func_native_slices/${subjID}_func_vol${epi_vol_forQC} ${epi_vol_forQC} 1" \
		>> ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.2

done < ${cohortFolder}/studyFolder.list

# echo "cd ${cohortFolder}/qc/func_native_slices; $FSLDIR/bin/slicesdir \`$FSLDIR/bin/imglob *_func_vol-*\`" \
# 	>> ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.3

echo "cd ${cohortFolder}/qc/func_native_slices; $FSLDIR/bin/slicesdir \`$FSLDIR/bin/imglob *_func_vol${epi_vol_forQC}*\`" \
	>> ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.3

echo "cd ${cohortFolder}/qc/func_native_slices; $FSLDIR/bin/imrm *" \
	>> ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.4

if [ "${qsub_flag}" = "yesQsub" ]; then
	func_slices_qc_1_jid=`$FSLDIR/bin/fsl_sub -T 10 -N QC_func_slices_1 -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.1`
	func_slices_qc_2_jid=`$FSLDIR/bin/fsl_sub -T 10 -N QC_func_slices_2 -l ${cohortFolder}/SGE_commands/oe -j ${func_slices_qc_1_jid} -t ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.2`
	func_slices_qc_3_jid=`$FSLDIR/bin/fsl_sub -T 120 -N QC_func_slices_3 -l ${cohortFolder}/SGE_commands/oe -j ${func_slices_qc_2_jid} -t ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.3`
	func_slices_qc_4_jid=`$FSLDIR/bin/fsl_sub -T 120 -N QC_func_slices_4 -l ${cohortFolder}/SGE_commands/oe -j ${func_slices_qc_3_jid} -t ${cohortFolder}/SGE_commands/qc_func_slices.fslsub.4`
fi



# +++++++++++++++++++++++++++++++++ #
# generating native space T1 slices #
# +++++++++++++++++++++++++++++++++ #

[ -f "${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.1" ] && \
	rm -f ${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.1

[ -f "${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.2" ] && \
	rm -f ${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.2

[ -f "${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.3" ] && \
	rm -f ${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.3

while read subjectFolder
do
	subjID=$(basename ${subjectFolder})

	echo "$FSLDIR/bin/imcp ${subjectFolder}/${subjID}_anat_brain ${cohortFolder}/qc/anat_native_slices" \
		>> ${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.1

done < ${cohortFolder}/studyFolder.list

echo "cd ${cohortFolder}/qc/anat_native_slices; $FSLDIR/bin/slicesdir \`$FSLDIR/bin/imglob *_anat_brain*\`" \
	>> ${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.2

echo "cd ${cohortFolder}/qc/anat_native_slices; $FSLDIR/bin/imrm *" \
	>> ${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.3

if [ "${qsub_flag}" = "yesQsub" ]; then
	anat_slices_qc_1_jid=`$FSLDIR/bin/fsl_sub -T 10 -N QC_anat_slices_1 -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.1`
	anat_slices_qc_2_jid=`$FSLDIR/bin/fsl_sub -T 120 -N QC_anat_slices_2 -l ${cohortFolder}/SGE_commands/oe -j ${anat_slices_qc_1_jid} -t ${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.2`
	anat_slices_qc_3_jid=`$FSLDIR/bin/fsl_sub -T 120 -N QC_anat_slices_3 -l ${cohortFolder}/SGE_commands/oe -j ${anat_slices_qc_2_jid} -t ${cohortFolder}/SGE_commands/qc_anat_slices.fslsub.3`
fi