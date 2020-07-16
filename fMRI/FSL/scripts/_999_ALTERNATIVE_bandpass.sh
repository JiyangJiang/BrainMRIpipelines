#!/bin/bash

cohortFolder=$1
cleanup_mode=$2
iso_resample_scale=$3

curr_dir=$(dirname $(which $0))

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# Default = bandpass after nuisance regression,and before spatial normalisation #
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# bandpass
bp_id=`${curr_dir}/L-lv_afni_bandpass_nuiReg.sh ${cohortFolder} ${cleanup_mode}`

# spatial normalisation
${curr_dir}/L-lv_normaliseFunc2MNI.sh ${cohortFolder} \
									  ${cleanup_mode} \
									  ${iso_resample_scale} \
									  par_cluster

while read studyFolder
do
	subjID=$(basename ${studyFolder})
	qsub -hold_jid ${bp_id} ${cohortFolder}/SGE_commands/${subjID}_L-lv_normaliseFunc2MNI.sge
done < ${cohortFolder}/studyFolder.list



# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# Alternative = bandpass after spatial normalisation, and before group ICA #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# # create brain mask complient to iso_resample_scale
# flirt -in ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask \
# 		-ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask \
# 			  -applyisoxfm ${iso_resample_scale} \
# 			  -init ${cohortFolder}/groupICA/resampled_MNI/eye.mat \
# 			  -out ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${iso_resample_scale}mm

# # bandpass
# ${curr_dir}/L-lv_afni_bandpass_mni.sh ${cohortFolder} ${iso_resample_scale}