#!/bin/bash

# DESCRIPTION :
# -----------------------------------------------------------------------------------------------------
# This script does unringing for all mif in derivatives/mrtrix/denoise. unring'ed mif will be saved
# in derivatives/mrtrix/unring.
#
#
# USAGE :
# -----------------------------------------------------------------------------------------------------
# $1 = path to BIDS folder
#
# $2 = axes  0,1 : acquired axial slices
#            0,2 : acquired coronal slices
#            1,2 : acquired sagittal slices
#
# $3 = parallel computing mode ('sin','Mcore')
#
# -----------------------------------------------------------------------------------------------------
# Dr. Jiyang Jiang     January 22, 2019

unring(){
	
	BIDS_folder=$1
	axes=$2
	par_mode=$3

	cd ${BIDS_folder}

	if [ -d "derivatives/mrtrix/unring" ]; then
		rm -fr derivatives/mrtrix/unring
	fi

	mkdir -p ${BIDS_folder}/derivatives/mrtrix/unring

	cd derivatives/mrtrix

	case ${par_mode} in

		sin)

			for den_mif in `ls denoise/*_den.mif`
			do
				den_mif_filename=$(echo $(basename ${den_mif}) | awk -F '.' '{print $1}')

				mrdegibbs ${den_mif} \
						  unring/${den_mif_filename}_unr.mif \
						  -axes ${axes}
			done

			;;

		Mcore)

			for den_mif in `ls denoise/*_den.mif`
			do

				den_mif_filename=$(echo $(basename ${den_mif}) | awk -F '.' '{print $1}')

				mrdegibbs ${den_mif} \
						  unring/${den_mif_filename}_unr.mif \
						  -axes ${axes} \
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

unring $1 $2 $3