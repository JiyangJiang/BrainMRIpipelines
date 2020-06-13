#!/bin/bash


########## usage function ##########
usage()
{
cat << EOF

DESCRIPTION: This script sen TUTORIAL_DATA and FSF_OUTPUT_FORMAT

USAGE:
			--Pdir|-p        <project directory>          project directory
			--Sdir|-s        <SUBJECTS_DIR>               SUBJECTS_DIR
			--Ofmt|-o        <output format>              output format (default = nii.gz)
			--help|-h                                     display this message

EOF
}


######### passing arguments ###########
if [ "$#" = "0" ]; then
	usage
	exit 0
fi

while [[ $# > 0 ]]; do
	key=$1
	shift

	case ${key} in
		
		--Pdir|-p)
			Pdir=$1
			shift
			;;

		--Sdir|-s)
			Sdir=$1
			shift
			;;

		--Ofmt|-o)
			Ofmt=$1
			shift
			;;

		--help|-h)
			usage
			exit 0
			;;

		*)
			echo
			echo "ERROR: unknown flag ${key}."
			echo
			usage
			exit 1
			;;
	esac
done


####### checking whether arguments are null ########
if [ -z ${Pdir:+a} ]; then
	echo
	echo "ERROR: Pdir (--Pdir|-p) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${Sdir:+a} ]; then
	echo
	echo "ERROR: Sdir (--Sdir|-s) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${Ofmt:+a} ]; then
	Ofmt="nii.gz"
fi


##### set env ######
export PROJECT_DIR=${Pdir}
export SUBJECTS_DIR=${Sdir}
export FSF_OUTPUT_FORMAT=${Ofmt}