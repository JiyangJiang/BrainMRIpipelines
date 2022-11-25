#!/bin/bash

# DESCRIPTION
# -----------------------------------------------------------------------------------------------------
#
# This script runs dwi2mask to generate mask for denoised, unringed, preprocessed, and unbiased dwi
#
#
# USAGE
# -----------------------------------------------------------------------------------------------------
#
# $1 = path to BIDS project folder
#
# $2 = parallel mode ('sin' or 'Mcore')
#
# -----------------------------------------------------------------------------------------------------
#
# Dr. Jiyang Jiang          January 29, 2019
#
# -----------------------------------------------------------------------------------------------------



dwiMask(){
	BIDS_folder=$1
	par_mode=$2

	cd ${BIDS_folder}/derivatives/mrtrix

	if [ -d "${BIDS_folder}/derivatives/mrtrix/dwi_mask" ]; then
		rm -fr ${BIDS_folder}/derivatives/mrtrix/dwi_mask
	fi
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/dwi_mask

	for unbiased_mif in `ls biascorrect/*_unr_preproc_unbiased.mif`
	do
		unbiased_mif_filename=$(echo $(basename ${unbiased_mif}) | awk -F '.' '{print $1}')

		case ${par_mode} in

			sin)

				dwi2mask ${unbiased_mif} \
						 ${BIDS_folder}/derivatives/mrtrix/dwi_mask/mask_${unbiased_mif_filename}.mif

				;;

			Mcore)

				dwi2mask ${unbiased_mif} \
						 ${BIDS_folder}/derivatives/mrtrix/dwi_mask/mask_${unbiased_mif_filename}.mif \
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
}

dwiMask $1 $2