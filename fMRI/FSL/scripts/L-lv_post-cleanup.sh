#!/bin/bash

# $1 = path to cohort folder
#
# $2 = 'aroma' or 'fix'
#
# $3 = 'forceNoFSLanat' only use when fsl_anat has already
#      been run. Any non-empty string othewise.
#
# $4 = TR in seconds
#
# $5 = high pass threshold in seconds
#
# $6 = 'yesRegWMts' or any other string if not regressing WM signal
#
# $7 = 'yesRegCSFts' or any other string if not regressing CSF signal
#
# $8 = "yesReg6motionParams" or any other string if not regressing
#      6 motion parameters
#
# $9 = 'yesReg24motionParams' or any other string if not regressing
#       24 motion parameters
#
# ${10} = 'yesRegMotionOutlier' or any other string if not regressing
#         motion outliers.
#
# ${11} = fsl_motion_outliers metrics to define outliers ('refrms', 
#         'dvars', 'refmse', 'fd', 'fdrms'). 'refrms', 'dvars' and 
#         'refmse' RECOMMENDED. Any string if not regressing motion
#         outliers.
#
# ${12} = number of first N volumes to be removed from fMRI data 
#         to reach magnetic equibilium. This should be consistent
#         with FEAT GUI setup.
#
# ${13} = isotropic resampling scale.
#
# ${14} = 'par_cluster' if running on cluster, or the number
#      of CPU cores to use if running on workstation.
#      Note that 'par_cluster' will only generate sge script
#      without qsub.
#
# ${15} = path to CNS
#
# ${16} = path to SPM12



cohortFolder=$1
cleanup_mode=$2

forceSkipFSLanat_flag=$3

tr=$4
Hpass_thr_in_sec=$5

regWMts_flag=$6
regCSFts_flag=$7
reg6motionParams_flag=$8
reg24motionParams_flag=$9
regMotionOutlier_flag=$10
fsl_motion_outliers_metric=${11}
N_vols_to_remove=${12}

iso_resample_scale=${13}

Ncpus=${14}

CNSpath=${15}
SPM12path=${16}



curr_dir=$(dirname $(which $0))

# fsl_anat
echo "$(basename $(which $0)) : fsl_anat ..."
${curr_dir}/L-lv_fslanat.sh ${cohortFolder} \
							${forceSkipFSLanat_flag} \
							${Ncpus}

# temporal filtering (high pass)
echo "$(basename $(which $0)) : temporal filtering (high pass) ..."
${curr_dir}/L-lv_Tfilt.sh ${cohortFolder} \
						  ${cleanup_mode} \
						  ${tr} \
						  ${Hpass_thr_in_sec} \
						  ${Ncpus}

# generate confounds
# if [ "${regWMts_flag}" = "yesRegWMts" ] || \
# 	[ "${regCSFts_flag}" = "yesRegCSFts" ]; then

	echo "$(basename $(which $0)) : generating WM/CSF timeseries ..."
	${curr_dir}/L-lv_genWMCSFts.sh ${cohortFolder} \
								   ${cleanup_mode} \
								   ${Ncpus} \
								   ${CNSpath} \
								   ${SPM12path}

# fi

# if [ "${reg6motionParams_flag}" = "yesReg6motionParams" ]; then

	echo "$(basename $(which $0)) : generating 6 motion parameters ..."
	${curr_dir}/L-lv_gen6motionParam.sh ${cohortFolder} \
										 ${cleanup_mode} \
										 noQsub

# fi


# if [ "${reg24motionParams_flag}" = "yesReg24motionParams" ]; then

	echo "$(basename $(which $0)) : generating 24 motion parameters ..."
	${curr_dir}/L-lv_gen24motionParam.sh ${cohortFolder} \
										 ${cleanup_mode} \
										 ${Ncpus}

# fi

# if [ "${regMotionOutlier_flag}" = "yesRegMotionOutlier" ]; then

	echo "$(basename $(which $0)) : generating motion outliers confound table ..."
	${curr_dir}/L-lv_fsl_motion_outliers.sh ${cohortFolder} \
											${fsl_motion_outliers_metric} \
											${N_vols_to_remove} \
											${Ncpus}

# fi

# nuisance regression
if [ "${regWMts_flag}" = "yesRegWMts" ] || \
	[ "${regCSFts_flag}" = "yesRegCSFts" ] || \
	 [ "${reg6motionParams_flag}" = "yesReg6motionParams" ] || \
	  [ "${reg24motionParams_flag}" = "yesReg24motionParams" ] || \
	   [ "${regMotionOutlier_flag}" = "yesRegMotionOutlier" ]; then

	  	echo "$(basename $(which $0)) : nuisance regression ..."
	  	${curr_dir}/L-lv_nuisance_regression.sh ${cohortFolder} \
	  											${cleanup_mode} \
	  											${regWMts_flag} \
	  											${regCSFts_flag} \
	  											${reg6motionParams_flag} \
	  											${reg24motionParams_flag} \
	  											${regMotionOutlier_flag} \
	  											${fsl_motion_outliers_metric} \
	  											${Ncpus}

fi

# normalise to MNI
echo "$(basename $(which $0)) : normalising to MNI ..."
${curr_dir}/L-lv_normaliseFunc2MNI.sh ${cohortFolder} \
									  ${cleanup_mode} \
									  ${iso_resample_scale} \
									  ${Ncpus}


# generate GM covariate map
echo "$(basename $(which $0)) : generating GM covariate map. This will take some time ..."
# ${curr_dir}/L-lv_genGMcovMap.sh ${cohortFolder} \
# 								${cleanup_mode} \
# 								${iso_resample_scale} \
# 								${Ncpus}
${curr_dir}/L-lv_genGMcovMap_fsl.sh ${cohortFolder} \
									${cleanup_mode} \
									${iso_resample_scale} \
									6 \
									yesQsub
