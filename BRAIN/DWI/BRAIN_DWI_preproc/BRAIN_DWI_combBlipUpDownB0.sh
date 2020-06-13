#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

# ========== Usage function ============= #
usage()
{
cat << EOF
	
DESCRIPTION: This script extracts the first volume (assuming this is b=0) from the main DWI and oppositely 
blipped DWI, respectively, and merge them together into one NIfTI (2 volumes, 1st volume is from main DWI 
and 2nd from blipped DWI). The acqparams.txt file is also created by this script.

USAGE:       
			 --Mdwi|-m <path_to_mainDWI>            The main DWI data
			 --Bdwi|-b <path_to_blipDWI>            The blipped DWI data
			 --Iden|-id                             ID
			 --Odir|-o <output_directory>           The path to output directory
			 --help|-h                              Display this message

EOF
}

# ========= Passing arguments ========== #
OPTIND=1

if [ "$#" -eq "0" ]; then
	usage
	exit 0
fi

while [[ $# > 0 ]]
do
	key="$1"
	shift

	case ${key} in

		--Mdwi|-m)
			Mdwi="$1"
			shift
			;;

		--Bdwi|-b)
			Bdwi="$1"
			shift
			;;

		--Iden|-id)
			ID="$1"
			shift
			;;

		--Odir|-o)
			Odir="$1"
			shift
			;;

		--help|-h)
			usage
			exit 0
			;;

		*)
			usage
			exit 1
			;;
	esac
done


# ========= Chech if arguments are null ========= #
if [ -z ${Mdwi:+abc} ]; then
	echo
	echo "ERROR: main DWI data is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${Bdwi:+abc} ]; then
	echo
	echo "ERROR: blipped DWI data is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${Odir:+abc} ]; then
	echo
	echo "ERROR: output directory is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${ID:+abc} ]; then
	echo
	echo "ERROR: ID is not properly set."
	echo
	usage
	exit 1
fi

# ======================================= #
# Now do the job: separate and merge b0's #
# ======================================= #

# merge b0's
echo -n "Merging blip up and down b0s ..."

fslroi ${Mdwi} ${Odir}/${ID}_Mdwi_b0 0 1
fslroi ${Bdwi} ${Odir}/${ID}_Bdwi_b0 0 1

fslmerge -t ${Odir}/${ID}_Mdwi_Bdwi_b0 \
			${Odir}/${ID}_Mdwi_b0 \
			${Odir}/${ID}_Bdwi_b0

echo "   Done"

# create acqparams.txt
echo -n "Making acqparams.txt ..."
echo "0 -1 0 0.11154" > ${Odir}/acqparams.txt
echo "0 1 0 0.11154" >> ${Odir}/acqparams.txt
echo "   Done"