#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

BRAIN_DWI_preproc_folder=$(dirname "$0")


# ========== usage function =========== #
usage ()
{
cat << EOF
DESCRIPTION: This script will run the topup using blip up and blip down b0

USAGE:
			--UDb0|-u       <path_to_blippedB0>            blip-up and blip-down b0s merged into one 4D vol
			--Ptxt|-p       <path_to_acqparamsTXT>         acqparams.txt
			--Odir|-o       <output_directory>             output directory
			--Iden|-id      <ID>                           ID
			--help|-h                                      display this message
EOF
}


# ============ passing parameters ============ #
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

		--UDb0|-u)
			UDb0="$1"
			shift
			;;

		--Ptxt|-p)
			acqparams="$1"
			shift
			;;

		--Odir|-o)
			Odir="$1"
			shift
			;;

		--Iden|-id)
			ID="$1"
			shift
			;;

		--help|-h)
			usage
			exit 0
			;;

		*)
			echo "ERROR: Unrecognised flag $1."
			echo
			usage
			exit 1
			;;

	esac
done


# ============ check if arguments are null ============= #
if [ -z ${UDb0+a} ]; then
	echo "ERROR: UDb0 (blip-up and blip-down b0s) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${acqparams+a} ]; then
	echo "ERROR: Ptxt (acqparams.txt file) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${Odir+a} ]; then
	echo "ERROR: Odir (output directory) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${ID+a} ]; then
	echo "ERROR: ID is not properly set."
	echo
	usage
	exit 1
fi


# ============ check #slices is even or odd =============== #
# --------------------------------------------------------- #
# b02b0.cnf only works for even # of slices
# delete one slice if it is odd.
# Ref: https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;c0f0d3a8.1512
# ---------------------------------------------------------------------
${BRAIN_DWI_preproc_folder}/BRAIN_DWI_checkOddEvenSlices.sh --img ${UDb0}

UDb0_folder=$(dirname "${UDb0}")
UDb0_filename=`echo $(basename "${UDb0}") | awk -F'.' '{print $1}'`
if [ -f "${UDb0_folder}/${UDb0_filename}_even.nii.gz" ]; then
	UDb0_even="${UDb0_folder}/${UDb0_filename}_even.nii.gz"
else
	UDb0_even=UDb0
fi

# =============== #
#    run topup    #
# =============== #
echo -n "Running topup ..."

topup --imain=${UDb0_even} \
	  --datain=${acqparams} \
	  --config=b02b0.cnf \
	  --out=${Odir}/${ID}_Mdwi_Bdwi_b0_topup \
	  --iout=${Odir}/${ID}_Mdwi_Bdwi_b0_topup_unwarped4D

echo "   Done"