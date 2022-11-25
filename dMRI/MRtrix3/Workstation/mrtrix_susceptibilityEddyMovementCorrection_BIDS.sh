#!/bin/bash

# DESCRIPTION
# ------------------------------------------------------------------------------------------------------------
# This script calls FSL's eddy to correct for susceptibility induced off-resonance field, eddy current-induced
# distortion, and subject's movement. This script calls fsl_newEddyCorrection.sh or dwidenoise
#
# NOTE that eddy option can only no_invPE
#
# USAGE
# ------------------------------------------------------------------------------------------------------------
# $1 = path to BIDS folder
#
# $2 = 'eddy' or 'dwipreproc'
#
# $3 = parallel mode ('sin' or 'Mcore')
#
# if $2 = 'eddy'
#
#    $4 = path to acqparams.txt, or 'easy_acq_updown', or 'easy_acq_leftright'
#
#    $5 = 'yesTopup' or 'noTopup'
#
#    $6 = second level model (--slm) option. 'none' if high quality data with 60+ directions sampled on the whole sphere
#                                            'linear' if fewer direction or without sampling on the whole sphere
#
#    $7 = '1' or '2' - which line of the lines in acqparams.txt is relevant for data passed into eddy.
#
#    $8 = eddy command - 'eddy', 'eddy_openmp', or 'eddy_cuda'
#
# if $2 = 'dwipreproc'
#
#	 $4 = -rpe_* option (either 'none'   for -rpe_none, 
#                               'pair'   for -rpe_pari, 
#                               'all'    for -rpe_all,
#                               'header' for -rpe_header)
#
#    $5 = second level model (--slm) option. 'none' if high quality data with 60+ directions sampled on the whole sphere
#                                            'linear' if fewer direction or without sampling on the whole sphere
#
#    $6 = other options for dwipreproc, within double quote, e.g. "-pe_dir AP -se_epi b0_pair.mif"
#
# ------------------------------------------------------------------------------------------------------------
# 
# Dr. Jiyang Jiang         January 29, 2019
#
# ------------------------------------------------------------------------------------------------------------


correction(){

	BIDS_folder=$1
	tool=$2
	par_mode=$3

	cd ${BIDS_folder}/derivatives/mrtrix

	if [ -d "preproc" ]; then
		rm -fr preproc
	fi
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/preproc



	case ${tool} in

		eddy)

			acqparamsTXT=$4
			topup_flag=$5
			slm_option=$6
			line_index=$7
			eddy_command=$8
			
			if [ -d "unring/nii" ]; then
				rm -fr unring/nii
			fi
			mkdir -p ${BIDS_folder}/derivatives/mrtrix/unring/nii

			for unr_mif in `ls unring/*_unr.mif`
			do

				# convert mif to nii/bvec/bval
				unr_mif_filename=$(echo $(basename ${unr_mif}) | awk -F '.' '{print $1}')
				mrconvert -export_grad_fsl unring/nii/${unr_mif_filename}.bvec \
										   unring/nii/${unr_mif_filename}.bval \
						  ${unr_mif} \
						  unring/nii/${unr_mif_filename}.nii.gz


				# folder to save eddy output
				if [ -d "${BIDS_folder}/derivatives/mrtrix/preproc/$(echo ${unr_mif_filename} | awk -F '_' '{print $1}')_eddy" ]; then
					rm -fr ${BIDS_folder}/derivatives/mrtrix/preproc/$(echo ${unr_mif_filename} | awk -F '_' '{print $1}')_eddy
				fi
				mkdir -p ${BIDS_folder}/derivatives/mrtrix/preproc/$(echo ${unr_mif_filename} | awk -F '_' '{print $1}')_eddy


				# call fsl_newEddyCorrection.sh to run FSL's eddy
				case ${par_mode} in

					sin)

						$(dirname $(dirname $(which $0)))/FSL/fsl_newEddyCorrection.sh unring/nii/${unr_mif_filename}.nii.gz \
																					   no_invPE \
																					   ${acqparamsTXT} \
																					   unring/nii/${unr_mif_filename}.bvec \
																					   unring/nii/${unr_mif_filename}.bval \
																					   ${BIDS_folder}/derivatives/mrtrix/preproc/$(echo ${unr_mif_filename} | awk -F '_' '{print $1}')_eddy \
																					   ${topup_flag} \
																					   ${slm_option} \
																					   ${line_index} \
																					   ${eddy_command} \
																					   > ${BIDS_folder}/derivatives/mrtrix/preproc/$(echo ${unr_mif_filename} | awk -F '_' '{print $1}')_eddy/log
						;;

					Mcore)

						$(dirname $(dirname $(which $0)))/FSL/fsl_newEddyCorrection.sh unring/nii/${unr_mif_filename}.nii.gz \
																					   no_invPE \
																					   ${acqparamsTXT} \
																					   unring/nii/${unr_mif_filename}.bvec \
																					   unring/nii/${unr_mif_filename}.bval \
																					   ${BIDS_folder}/derivatives/mrtrix/preproc/$(echo ${unr_mif_filename} | awk -F '_' '{print $1}')_eddy \
																					   ${topup_flag} \
																					   ${slm_option} \
																					   ${line_index} \
																					   ${eddy_command} \
																					   > ${BIDS_folder}/derivatives/mrtrix/preproc/$(echo ${unr_mif_filename} | awk -F '_' '{print $1}')_eddy/log \
																					   &
						;;
				esac


				# check - not exceeding number of cores
				unameOut="$(uname -s)"
				case "${unameOut}" in
				    Linux*)
						machine=Linux
						# at most number of CPU cores
						[ $(jobs | wc -l) -ge $(python -c "print ($(nproc)/2)") ] && wait
						;;

				    Darwin*)
						machine=Mac
						# at most number of CPU cores
						[ $(jobs | wc -l) -ge $(python -c "print ($(sysctl -n hw.physicalcpu)/2)") ] && wait
						;;

				    CYGWIN*)    machine=Cygwin;;
				    MINGW*)     machine=MinGw;;
				    *)          machine="UNKNOWN:${unameOut}"
				esac


				# mrconvert nii.gz to mif
				rotated_bvec=${BIDS_folder}/derivatives/mrtrix/preproc/$(echo ${unr_mif_filename} | awk -F '_' '{print $1}')_eddy/eddy/eddy_corrected.eddy_rotated_bvecs
				eddyCorr_dwi=${BIDS_folder}/derivatives/mrtrix/preproc/$(echo ${unr_mif_filename} | awk -F '_' '{print $1}')_eddy/eddy/eddy_corrected.nii.gz
				orig_bval=unring/nii/${unr_mif_filename}.bval
				
				mrconvert -fslgrad ${rotated_bvec} ${orig_bval} \
						  ${eddyCorr_dwi} \
						  ${BIDS_folder}/derivatives/mrtrix/preproc/${unr_mif_filename}_preproc.mif
			done
			;;

		dwipreproc)

			rpe_option=$4
			slm_option=$5
			other_dwipreproc_option=$6

			for unr_mif in `ls unring/*_unr.mif`
			do
				unr_mif_filename=$(echo $(basename ${unr_mif}) | awk -F '.' '{print $1}')

				# call dwipreproc
				case ${par_mode} in

					sin)

						dwipreproc ${unr_mif} \
								   ${BIDS_folder}/derivatives/mrtrix/preproc/${unr_mif_filename}_preproc.mif \
								   -rpe_${rpe_option} \
								   -eddy_options " --slm=${slm_option}" \
								   ${other_dwipreproc_option}
						;;

					Mcore)

						dwipreproc ${unr_mif} \
								   ${BIDS_folder}/derivatives/mrtrix/preproc/${unr_mif_filename}_preproc.mif \
								   -rpe_${rpe_option} \
								   -eddy_options " --slm=${slm_option}" \
								   ${other_dwipreproc_option} \
								   &
						;;

				esac


				# check - not exceeding number of cores
				unameOut="$(uname -s)"
				case "${unameOut}" in
				    Linux*)
						machine=Linux
						# at most number of CPU cores
						[ $(jobs | wc -l) -ge $(python -c "print ($(nproc)/2)") ] && wait
						;;

				    Darwin*)
						machine=Mac
						# at most number of CPU cores
						[ $(jobs | wc -l) -ge $(python -c "print ($(sysctl -n hw.physicalcpu)/2)") ] && wait
						;;

				    CYGWIN*)    machine=Cygwin;;
				    MINGW*)     machine=MinGw;;
				    *)          machine="UNKNOWN:${unameOut}"
				esac

			done
			;;
	esac
}

correction $1 $2 $3 $4 $5 "$6" $7 $8
































































