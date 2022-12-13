#!/bin/bash

cohortFolder=$1
cleanup_mode=$2

regWMts_flag=$3
regCSFts_flag=$4
reg6motionParams_flag=$5
reg24motionParams_flag=$6
regMotionOutlier_flag=$7

fsl_motion_outliers_metric=$8

Ncpus=$9





while read studyFolder
do
	subjID=$(basename ${studyFolder})

	case ${cleanup_mode} in
		aroma)
			workingDir=${studyFolder}/${subjID}_func.feat
			postcleanup_folder=${workingDir}/post-ICA_AROMA
			;;
		fix)
			workingDir=${studyFolder}/${subjID}_func.ica
			postcleanup_folder=${workingDir}/post-FIX
			;;
	esac

	str=""

	if [ "${regWMts_flag}" = "yesRegWMts" ]; then
		str="${str} ${cohortFolder}/confounds/WMmeants/${subjID}_wm_timeseries.txt"
	fi

	if [ "${regCSFts_flag}" = "yesRegCSFts" ]; then
		str="${str} ${cohortFolder}/confounds/CSFmeants/${subjID}_csf_timeseries.txt"
	fi

	if [ "${reg6motionParams_flag}" = "yesReg6motionParams" ]; then
		str="${str} ${cohortFolder}/confounds/motion_params/${subjID}.6motion.params"
	fi

	if [ "${reg24motionParams_flag}" = "yesReg24motionParams" ]; then
		str="${str} ${cohortFolder}/confounds/motion_params/${subjID}.24motion.params"
	fi

	if [ "${regMotionOutlier_flag}" = "yesRegMotionOutlier" ] && \
		[ -f "${cohortFolder}/confounds/motion_params/${subjID}.fsl_motion_outliers.${fsl_motion_outliers_metric}.outliers.confound" ]; then
		str="${str} ${cohortFolder}/confounds/motion_params/${subjID}.fsl_motion_outliers.${fsl_motion_outliers_metric}.outliers.confound"
	fi

	re='^[0-9]+$'

	if [[ ${Ncpus} =~ $re ]]; then

		paste ${str} > ${cohortFolder}/confounds/${subjID}_nuisance_regressors.txt

		fsl_glm -i ${postcleanup_folder}/Tfiltered_cleanedup_func \
				-d ${cohortFolder}/confounds/${subjID}_nuisance_regressors.txt \
				--demean \
				--out_res=${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func \
				&

		[ $(jobs | wc -l) -gt ${Ncpus} ] && wait

	elif [ "${Ncpus}" = "par_cluster" ]; then

		cat << EOF > ${cohortFolder}/SGE_commands/${subjID}_L-lv_nuisanceReg.sge
#!/bin/bash

#$ -N sub${subjID}_nuisanceReg
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q standard.q
#$ -l h_vmem=4G
#$ -o ${cohortFolder}/SGE_commands/oe/${subjID}_nuisanceReg.out
#$ -e ${cohortFolder}/SGE_commands/oe/${subjID}_nuisanceReg.err

module load fsl/5.0.11

paste ${str} > ${cohortFolder}/confounds/${subjID}_nuisance_regressors.txt

fsl_glm -i ${postcleanup_folder}/Tfiltered_cleanedup_func -d ${cohortFolder}/confounds/${subjID}_nuisance_regressors.txt --demean --out_res=${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func

# 2019 May 27 : add mean back to residual
fslmaths ${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func -add ${postcleanup_folder}/cleanedup_func_Tmean ${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func
EOF
	fi

done < ${cohortFolder}/studyFolder.list

wait

# 2019 May 27 : add mean back to residual
while read studyFolder
do
	subjID=$(basename ${studyFolder})

	case ${cleanup_mode} in
		aroma)
			workingDir=${studyFolder}/${subjID}_func.feat
			postcleanup_folder=${workingDir}/post-ICA_AROMA
			;;
		fix)
			workingDir=${studyFolder}/${subjID}_func.ica
			postcleanup_folder=${workingDir}/post-FIX
			;;
	esac

	re='^[0-9]+$'

	if [[ ${Ncpus} =~ $re ]]; then
		fslmaths ${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func \
				 -add ${postcleanup_folder}/cleanedup_func_Tmean \
				 ${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func \
				 &

		[ $(jobs | wc -l) -gt ${Ncpus} ] && wait
	fi

done < ${cohortFolder}/studyFolder.list

wait