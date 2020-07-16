#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

######################################################################
##              This script is from FSL email list                  ##
## https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=FSL;4a642346.1809 ##
##                                                                  ##
## The author reported TR was reset to 1. it is ok to modify the    ##
## nifti header to the correct TR.                                  ##
######################################################################
#
# =========================================================================
# DESCRIPTION : This script is supposed to be used after FEAT preprocessing
#               and ICA-AROMA (or FIX) cleanup. It conducts highpass 
#               temporal filtering, regresses out the mean 
#               timeseries from WM and CSF. The results should be ready 
#               for group ICA analyses.
# =========================================================================
#
# ===================================  USAGE  =====================================
# $1 :  exclusive mode flag. Sometimes, you may want to try yesWMCSFregts and 
#       noWMCSFregts. This flag lets you re-generate final_cleanedup_func_std_space
#       without the need for re-running AROMA or FIX.
#       'pipeline' - depending on 'yesWMCSFregts' or 'noWMCSFregts' passed from
#                    the previous step (see L-lv_cleanup.sh).
#       'exclusive' - re-generating final_cleanedup_func_std_space with the new
#                     'yesWMCSFregts' or 'noWMCSFregts' without redoing the previous
#                     AROMA or FIX cleanup.
#
# $2 : cleanup mode ('fix' or 'aroma')
#
# $3 : if $1='pipeline' - working directory (e.g., subj.feat or subj.ica)
#      if $1='exclusive' - cohort folder
#
# $4 : if $1='pipeline' - full path to anat image
#      if $1='exclusive' - any string
#
# $5 : highpass threshold (in seconds)
#
# $6 : specify whether directly passing TR (tr)
#      or deriving TR from original fMRI (epi).
#      NOTE: 'exclusive' mode will always use 'epi'.
#
# $7 : if directly passing TR (tr), $5 = TR (in seconds).
#      if deriving TR from original fMRI image (epi), $5 = path to orig fMRI image
#      any string if $1=executive.
#
# $8 : 'noFSLanat' if fsl_anat is to be skipped (already run).
#      'yesFSLanat' if fsl_anat is needed.
#      Note that fsl_anat is necessary if yesWMCSFregts.
#      Update 2019.03.14 : Now, even though 'noWMCSFregts' and/or 'noFSLanat', 
#                          fsl_anat will be implemented for voxel-wise GM covariate maps.
#                          Also see argument $13.
#
# $9 : 'noWMCSFregts' if skipping regressing out the mean time series in WM and CSF
#                     regions.
#      'yesWMCSFregts' if not skipping.
#
# $10 : 'no24motionregts' if skipping regressing out the 24 motion parameters.
#       'yes24motionregts' if regressing out the 24 motion parameters.
#
# $11 : 'noMotionOutlierConfoundReg' if skipping regressing out motion outliers using
#                                    fsl_motion_outliers.
#       'yesMotionOutlierConfoundReg_*' if regressing out motion outliers using
#                                       fsl_motion_outliers. The string after the
#                                       underscore is the metric used to define
#                                       motion outliers ('refrms', 'dvars' and 'refmse' RECOMMENDED)
#
# $12 : number of first N volumes to be removed from fMRI data to reach magnetic equibilium.
#
# $13 : 'yesTfilt' if conducting temporal filtering (high pass). Note that we call
#       FIX with temporal filtering (high pass) (see L-lv_fsl_fix_cleanup.sh).
#       Therefore, only AROMA cleanup neends to run temporal filtering at this step.
#       'noTfilt' if not conducting temporal filtering.
#
# $14 : isotropic resampling scale. downsample (resample) to XX mm (e.g. passing
#       '4' will downsample to 4 mm isotropic after warping to MNI).
#
# $15 : if $1=exclusive, 'forceNoFSLanat' to force skipping fsl_anat. This is only
#                        available in 'exclusive' mode, and assumes that fsl_anat
#                        has previously been done. This will force overwriting
#                        argument $8.
#       if $1=pipeline,  no use
#
# $16 : if $1=exclusive, number of jobs to submit once (multi-core parallel)
#       if $1=pipeline,  no use
#
# =================================================================================
#
# =================================== NOTES =======================================
# - Temporal filtering
#   The primer "Introduction to fMRI and functional connectivity" suggested doing
#   temporal filtering before ICA, whereas the publications from FSL group tend
#   to do it after ICA.
# =================================================================================

post_cleanup(){

	# Arguments
	# ---------
	mode=$1
	workingDir=$2
	anat=$3
	Hpass_thr=$4
	which_tr=$5
	tr_param=$6
	FSLanat_flag=$7
	WMCSF_flag=$8
	mot24reg_flag=$9
	motOutlierReg_flag=${10}
	Tfilt_flag=${11}
	iso_resample_scale=${12}
	forceSkipFSLanat_flag=${13}


	# Some preparations
	# -----------------
	anat_filename=`echo $(basename "${anat}") | awk -F'.' '{print $1}'`
	fsl_anat_dir="$(dirname "${anat}")/${anat_filename}.anat"

	case ${mode} in

		aroma)
			mkdir -p ${workingDir}/post-ICA_AROMA
			mkdir -p ${workingDir}/post-ICA_AROMA/nuisance_masks
			postcleanup_folder="${workingDir}/post-ICA_AROMA"
			cleanedup_func="${workingDir}/ICA_AROMA/denoised_func_data_nonaggr"
			;;

		fix)
			mkdir -p ${workingDir}/post-FIX
			mkdir -p ${workingDir}/post-FIX/nuisance_masks
			postcleanup_folder="${workingDir}/post-FIX"
			cleanedup_func="${workingDir}/filtered_func_data"
			;;
	esac


	Tfiltered_cleanedup_func="${postcleanup_folder}/Tfiltered_cleanedup_func"

	Tfiltered_cleanedup_func_filename=Tfiltered_cleanedup_func



	# ============================   Start processing   ================================= #

	# -------------------------
	# do fsl_anat to anat image
	# -------------------------
	if [ ! -z ${forceSkipFSLanat_flag+x} ] && \
		[ "${forceSkipFSLanat_flag}" = "forceNoFSLanat" ]; then
			echo "force skipping fsl_anat"
	else
		if [ -d "${fsl_anat_dir}" ]; then
			rm -fr ${fsl_anat_dir}
		fi
		# need to stop auto-cropping. Otherwise the dimension is changed
		# and the transformation matrices in "reg" folder will be unusable.
		fsl_anat --nocrop \
				 -i ${anat}
	fi

	# case ${FSLanat_flag} in

	# 	yesFSLanat)
	# 		echo "Doing fsl_anat to the anat image. This will take a while ..."

	# 		if [ -d "${fsl_anat_dir}" ]; then
	# 			rm -fr ${fsl_anat_dir}
	# 		fi

	# 		# need to stop auto-cropping. Otherwise the dimension is changed
	# 		# and the transformation matrices in "reg" folder will be unusable.
	# 		fsl_anat --nocrop \
	# 				 -i ${anat}

	# 		;;

	# 	noFSLanat)
	# 		echo "fsl_anat is skipped."
	# 		;;
	# esac



	# -------------------------------------
	# whether conducting temporal filtering
	# (highpass)
	# -------------------------------------

	case ${Tfilt_flag} in

		yesTfilt)


			# Get mean of denoised functional data (to be added to the residuals below)
			# -------------------------------------------------------------------------
			fslmaths ${cleanedup_func} \
					 -Tmean \
					 ${postcleanup_folder}/cleanedup_func_Tmean

	
			# apply highpass filter and add the Tmean back into data
			# ------------------------------------------------------
			case ${which_tr} in
				tr)
					tr=${tr_param}
					;;
				epi)
					tr=`fslval ${tr_param} pixdim4`
					;;
			esac

			fwhm=`python -c "print (${Hpass_thr}/${tr})"`
			sigma=`python -c "print (${fwhm}/2)"`

			# FIX has done highpass, only AROMA needs highpass
			case ${mode} in

				aroma)
					fslmaths ${cleanedup_func} \
							 -bptf ${sigma} -1 \
							 -add ${postcleanup_folder}/cleanedup_func_Tmean \
							 ${Tfiltered_cleanedup_func}
					;;

				fix)
					fslmaths ${cleanedup_func} \
							 ${Tfiltered_cleanedup_func}
					;;

			esac

			;;


		noTfilt)

			# not doing temporal filtering
			fslmaths ${cleanedup_func} \
					 ${Tfiltered_cleanedup_func}
			;;

	esac




	# -------------------------------------------------------------
	# Whether regress out the mean timeseries of WM and CSF regions
	# -------------------------------------------------------------

	case ${WMCSF_flag} in

		yesWMCSFregts)

			echo "yesWMCSFregts is set. Generating WM/CSF mean time series ..."

			${curr_dir}/L-lv_genIndWMCSFconfounds.sh ${fsl_anat_dir} \
													 ${workingDir} \
													 ${postcleanup_folder}

			paste ${postcleanup_folder}/nuisance_masks/wm_in_func_bin_timeseries \
				  ${postcleanup_folder}/nuisance_masks/csf_in_func_bin_timeseries \
				  > ${postcleanup_folder}/nuisance_masks/nuisance_timeseries

			;;


		noWMCSFregts)

			echo "noWMCSFregts is set. Not generating WM and CSF mean timeseries."

			# fslmaths ${postcleanup_folder}/Tfiltered_cleanedup_func \
			# 		 ${postcleanup_folder}/wmcsfTSreg_Tfiltered_cleanedup_func
			;;

	esac


	# ---------------------------------------------------------------------
	#          Whether regressing out 24 motion parameters
	# ---------------------------------------------------------------------
	case ${mot24reg_flag} in

		yes24motionregts)

			echo "yes24motionregts is set. Including 24 motion parameters to nuisance regressors."

			case ${WMCSF_flag} in

				yesWMCSFregts)

					mv ${postcleanup_folder}/nuisance_masks/nuisance_timeseries \
						${postcleanup_folder}/nuisance_masks/nuisance_timeseries_WMCSF

					paste ${postcleanup_folder}/nuisance_masks/nuisance_timeseries_WMCSF \
						  ${workingDir}/mc/24motion_param.dat \
						  > ${postcleanup_folder}/nuisance_masks/nuisance_timeseries

					;;

				noWMCSFregts)

					cp ${workingDir}/mc/24motion_param.dat \
					   ${postcleanup_folder}/nuisance_masks/nuisance_timeseries

					;;

			esac


			;;

		no24motionregts)

			# nothing needs to be done.

			;;

	esac


	# Whether regress out motion outliers from fsl_motion_outliers
	case ${motOutlierReg_flag} in

		noMotionOutlierConfoundReg)

			# do nothing

			;;

		yesMotionOutlierConfoundReg_*)
			
			motionOutlier_metric=$(echo ${motOutlierReg_flag} | cut -d '_' -f 2)

			L-lv

	# --------------------------------------------------------------------
	#                 regress out nuisance variables
	# --------------------------------------------------------------------
	if [ "${WMCSF_flag}" = "yesWMCSFregts" ] || \
		[ "${mot24reg_flag}" = "yes24motionregts" ]; then

		echo "Regressing out nuisance variables ..."

		fsl_glm -i ${postcleanup_folder}/Tfiltered_cleanedup_func \
				-d ${postcleanup_folder}/nuisance_masks/nuisance_timeseries \
				--demean \
				--out_res=${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func

		final_preproc_data_indSpace=${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func.nii.gz

	else

		final_preproc_data_indSpace=${postcleanup_folder}/Tfiltered_cleanedup_func.nii.gz

	fi


	# ---------------------------------------------------------------------
	# transform final_denoised_filtered_func to standard space (MNI152_2mm)
	# and apply isotropic resampling.
	# ---------------------------------------------------------------------
	echo "Normalising preprocessed fMRI data to MNI space, and resampling ..."

	flirt -in ${final_preproc_data_indSpace} \
	      -applyisoxfm ${iso_resample_scale} \
	      -init ${workingDir}/reg/example_func2standard.mat \
	      -ref ${workingDir}/reg/standard.nii.gz \
      	  -out ${postcleanup_folder}/final_cleanedup_func_std_space


    # --------------------------------------------------------------------
    #            Preparing GM covariate map in MNI space
    # --------------------------------------------------------------------
    echo "Normalising GM pve map (ie. GM covariate map) to MNI space, and resampling ..."
    
    # mkdir -p ${workingDir}/GMcovMap_MNIspace

	# pve1 - FAST to SPM
	flirt -in ${fsl_anat_dir}/T1_fast_pve_1.nii.gz \
		  -applyxfm \
		  -init ${workingDir}/reg/fast2spm.mat \
		  -ref ${workingDir}/reg/highres.nii.gz \
		  -out ${fsl_anat_dir}/T1_fast_pve_1_fast2spm
	# pve1 - SPM T1 to MNI
	flirt -in ${fsl_anat_dir}/T1_fast_pve_1_fast2spm \
		  -applyisoxfm ${iso_resample_scale} \
		  -init ${workingDir}/reg/highres2standard.mat \
		  -ref ${workingDir}/reg/standard.nii.gz \
		  -out $(dirname $(dirname ${workingDir}))/GMcovMap/$(basename $(dirname ${workingDIR}))_gmCovMap_MNI_${iso_resample_scale}mm

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
	# data should be ready to pass to MELODIC for group ICA analysis #
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
	echo


}

main(){

	curr_dir=$(dirname $(which $0))

	case $1 in

		pipeline)

			post_cleanup $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13}

			;;

		exclusive)

			case $9 in
				yesWMCSFregts)
					FSLanat_flag=yesFSLanat
					;;
				noWMCSFregts)
					FSLanat_flag=noFSLanat
					;;
			esac

			# whether 24 motion params
			case ${10} in
				yes24motionregts)
					echo "here"
					# generate 24 motion parameters for all subjects
					${curr_dir}/L-lv_gen24motionParam.sh ${3} ${2}
					;;
				no24motionregts)
					;;
			esac

			# Whether regress out motion outliers from fsl_motion_outliers
			case ${11} in

				noMotionOutlierConfoundReg)

					# do nothing

					;;

				yesMotionOutlierConfoundReg_*)
					
					motionOutlier_metric=$(echo ${motOutlierReg_flag} | cut -d '_' -f 2)

					${curr_dir}/L-lv_fsl_motion_outliers.sh ${3} \
															${motionOutlier_metric} \
															${12}

					;;


			while read studyFolder
			do

				case $2 in
				aroma)
					workingDir=${studyFolder}/$(basename ${studyFolder})_func.feat
					;;
				fix)
					workingDir=${studyFolder}/$(basename ${studyFolder})_func.ica
					;;
				esac

				post_cleanup $2 \
							 ${workingDir} \
							 ${studyFolder}/$(basename ${studyFolder})_anat \
							 $5 \
							 epi \
							 ${studyFolder}/$(basename ${studyFolder})_func \
							 ${FSLanat_flag} \
							 $9 \
							 ${10} \
							 ${11} \
							 ${12} \
							 ${13} \
							 ${14} \
							 &

				[ $(jobs | wc -l) -gt ${15} ] && wait
				
			done < ${3}/studyFolder.list
	esac
}

main $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16}