#!/bin/bash

icaFolder="/home/jiyang/Work/fMRI/test/dataset2/test20180917/fMRI_1.ica"

usage()
{
cat << EOF

DESCRIPTION : This script calls FSL FIX.

USAGE : --ica|-i      <subject_ICA_folder>      subject ICA folder.
		--fixdir|-f   <FIX_directory>           FIX installation directory.
        --Tdata|-t    <RData_name>              FIX built-in training data (default=Standard.RData).
        --thr|-r      <threshold>               threshold (typically 5-20, default=20).
        --Hpass|-h    <high_pass>               highpass threshold (default=100).

EOF
}

# ---=== pass arguments ===--- #
OPTIND=1

if [ "$#" = "0" ]; then
	usage
	exit 0
fi

while [[ $# > 0 ]]; do
	key=$1
	shift
	
	case ${key} in
		--ica|-i)
			icaFolder=$1
			shift
			;;
		
		--fixdir|-f)
			fixdir=$1
			shift
			;;

		--Tdata|-t)
			trainingData=$1
			shift
			;;
			
		--thr|-r)
			thr=$1
			shift
			;;
			
		--Hpass|-h)
			Hpass=$1
			shift
			;;
			
		*)
			echo
			echo "unknown flag : ${key}"
			echo
			usage
			echo
			exit 1
			;;
	esac
done	
# ---=== check arguments ===--- #
if [ -z ${icaFolder+x} ]; then
	echo
	echo "ERROR : icaFolder (--ica|-i) was not appropriately set."
	echo
	usage
	exit 1
fi

if [ -z ${fixdir+x} ]; then
	echo
	echo "WARNING : fixdir is not set."
	echo "          this will be set to"
	echo "          /data_pub/Software/FSL/fsl-5.0.11/fix1.066/training_files"
	echo "          which is ok if running on GRID."
	echo
	fixdir="/data_pub/Software/FSL/fsl-5.0.11/fix1.066/training_files"
fi

if [ -z ${trainingData+x} ]; then
	echo
	echo "WARNING : traningData (--Tdata|-t) was not set."
	echo "          Stardard.RData will be used as default."
	echo
	trainingData="Standard.RData"
fi

if [ -z ${thr+x} ]; then
	echo
	echo "WARNING : thr (--thr|-r) was not set."
	echo "          Default thr (20) will be used."
	echo
	thr=20
fi

if [ -z ${Hpass+x} ]; then
	echo
	echo "WARNING : Hpass (--Hpass|-h) was not set."
	echo "          A default Hpass=100 will be used."
	echo
	Hpass=100
fi
	


# ---=== run FIX ===--- #
fix ${icaFolder} \
	${fixdir}/training_files/${trainingData} \
	${thr} \
	-m \
	-h ${Hpass}
