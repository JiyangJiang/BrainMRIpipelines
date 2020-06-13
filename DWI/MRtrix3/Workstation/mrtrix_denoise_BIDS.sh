#!/bin/bash

# DESCRIPTION :
# -----------------------------------------------------------------------------------------------------
# This script does denoise for all mif in derivatives/mrtrix/orig_mif. denoised mif and noise are saved
# in derivatives/mrtrix/denoise.
#
#
# USAGE :
# -----------------------------------------------------------------------------------------------------
# $1 = path to BIDS folder
# $2 = parallel computing mode ('sin','Mcore')
#
# -----------------------------------------------------------------------------------------------------
# Dr. Jiyang Jiang     January 22, 2019

denoise(){

	BIDS_folder=$1
	par_mode=$2

	cd ${BIDS_folder}

	if [ -d "derivatives/mrtrix/denoise" ]; then
		rm -fr derivatives/mrtrix/denoise
	fi

	mkdir -p ${BIDS_folder}/derivatives/mrtrix/denoise

	cd derivatives/mrtrix


	case ${par_mode} in

		sin)

			for mif in `ls orig_mif/*.mif`
			do
				mif_filename=$(echo $(basename ${mif}) | awk -F '.' '{print $1}')

				dwidenoise ${mif} \
						   denoise/${mif_filename}_den.mif \
						   -noise denoise/${mif_filename}_noi.mif
			done
			;;

		Mcore)

			for mif in `ls orig_mif/*.mif`
			do
				mif_filename=$(echo $(basename ${mif}) | awk -F '.' '{print $1}')

				dwidenoise ${mif} \
						   denoise/${mif_filename}_den.mif \
						   -noise denoise/${mif_filename}_noi.mif \
						   &

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

denoise $1 $2