#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

BRAIN_DWI_folder=$(dirname "$0")


# ============= #
# display usage #
# ============= #
usage()
{
cat << EOF

DESCRIPTION: BRAIN processing pipeline - DWI preprocessing

USAGE:
		--Mdwi|-m           <path_to_mainDWI>                   Main DWI

		--Bdwi|-b           <path_to_blippedDWI>                Blipped DWI

		--Iden|-i           <ID>                                ID

		--Odir|-o           <path_to_output_directory>	        Output directory

		--Startover|-s                                          Delete everything (if existing) in output directory (either --Startover or --Appending must be set)

		--Appending|-a                                          Append to existing output (either --Startover or --Appending must be set)

		--help|-h                                               Display this message

EOF
}

# ================= #
# passing variables #
# ================= #
OPTIND=1

# initialise AP (whether appending) and SO (whether startover)
AP="N"
SO="N"

# if only call this script without any argument, then display usage
if [ "$#" -eq "0" ]; then
	usage
	exit 0
fi

# if argument is not empty, then assign arguments
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

		--Iden|-i)

			ID="$1"
			shift
			;;

		--Odir|-o)
			Odir="$1"
			shift
			;;

		--Startover|-s)
			SO="Y"
			AP="N"
			shift
			;;

		--Appending|-a)
			AP="Y"
			SO="N"
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


# ========================= #
# check if variable is null #
# ========================= #
if [ -z ${Mdwi:+abc} ]; then
	echo "ERROR: --Mdwi|-m is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${Bdwi:+abc} ]; then
	echo "ERROR: --Bdwi|-b is not properly set"
	echo
	usage
	exit 1
fi

if [ -z ${ID:+abc} ]; then
	echo "ERROR: ID is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${Odir+abc} ]; then
	echo "ERROR: --Odir|-o is not properly set"
	echo
	usage
	exit 1
fi

if [ "${AP}" = "N" ] && [ "${SO}" = "N" ]; then
	echo
	echo "ERROR: either --Startover|-s or --Appending|-a needs to be set."
	echo
	usage
	exit 1
elif [ "${AP}" = "Y" ] && [ "${SO}" = "Y" ]; then
	echo
	echo "ERROR: --Startover|-s and --Appending|-a cannot be set simultaneously."
	echo
	usage
	exit 1
fi


# ====================== #
# Appending or Startover #
# ====================== #
if [ "${AP}" = "Y" ]; then
	echo
	echo "\"Appending\" is specified, keeping contents in output directory."
	echo
	if [ ! -d "${Odir}" ]; then
		echo "${Odir} does not exist. Creating ..."
	fi

elif [ "${SO}" = "Y" ]; then
	echo
	echo "\"Startover\" is specified, removing contents in output directory."
	echo
	if [ -d "${Odir}" ]; then
		rm -f ${Odir}/*
	else
		echo "${Odir} does not exist. Creating ..."
		mkdir ${Odir}
	fi
fi


# ========================== #
# copy Mdwi and Bdwi to Odir #
# ========================== #
echo -n "Copying Mdwi and Bdwi to Odir ..."

# "#" meaning stripping a block matching the pattern specified
# by the following, e.g. ##*. meaning stripping two blocks following
# the pattern of "*."
if [ "${Mdwi##*.}" = "gz" ]; then
	cp ${Mdwi} ${Odir}/${ID}_Mdwi.nii.gz
elif [ "${Mdwi##*.}" = "nii" ]; then
	cp ${Mdwi} ${Odir}/${ID}_Mdwi.nii
	gzip -f ${Odir}/${ID}_Mdwi.nii
fi

if [ "${Bdwi##*.}" = "gz" ]; then
	cp ${Bdwi} ${Odir}/${ID}_Bdwi.nii.gz
elif [ "${Bdwi##*.}" = "nii" ]; then
	cp ${Bdwi} ${Odir}/${ID}_Bdwi.nii
	gzip -f ${Odir}/${ID}_Bdwi.nii
fi

# copy Mdwi's bvec and bval
Mdwi_folder=$(dirname "${Mdwi}")
Mdwi_filename=`echo $(basename "${Mdwi}") | awk -F'.' '{print $1}'`
cp ${Mdwi_folder}/${Mdwi_filename}.bvec ${Odir}/${ID}_Mdwi_bvec.bvec
cp ${Mdwi_folder}/${Mdwi_filename}.bval ${Odir}/${ID}_Mdwi_bval.bval

echo "   Done"

# ======================================== #
# create a NIfTI with b0 in both direction #
#         and the acqparams.txt file       #
# ======================================== #
${BRAIN_DWI_folder}/BRAIN_DWI_preproc/BRAIN_DWI_combBlipUpDownB0.sh --Mdwi ${Odir}/${ID}_Mdwi.nii.gz \
																    --Bdwi ${Odir}/${ID}_Bdwi.nii.gz \
																    --Odir ${Odir} \
																    --Iden ${ID}


# ==================== #
#       Run topup      #
# ==================== #
${BRAIN_DWI_folder}/BRAIN_DWI_preproc/BRAIN_DWI_topup.sh --UDb0 ${Odir}/${ID}_Mdwi_Bdwi_b0.nii.gz \
														 --Ptxt ${Odir}/acqparams.txt \
														 --Odir ${Odir} \
														 --Iden ${ID}


# ========================== #
# get the brain mask for DWI #
# ========================== #
${BRAIN_DWI_folder}/BRAIN_DWI_preproc/BRAIN_DWI_getBrainMask.sh --img ${Odir}/${ID}_Mdwi_Bdwi_b0_topup_unwarped4D.nii.gz \
																--Odir ${Odir}


# ========================= #
# create the index txt file #
# ========================= #
${BRAIN_DWI_folder}/BRAIN_DWI_preproc/BRAIN_DWI_indexTXT.sh --img ${Odir}/${ID}_Mdwi.nii.gz \
															--idx 1 \
															--Odir ${Odir} \
															--pref ${ID}


# =============================== #
# Perform eddy current correction #
# =============================== #
${BRAIN_DWI_folder}/BRAIN_DWI_preproc/BRAIN_DWI_eddy.sh --Mdwi ${Odir}/${ID}_Mdwi.nii.gz \
									                    --Bmsk ${Odir}/${ID}_Mdwi_Bdwi_b0_topup_unwarped4D_Tmean_brain_mask.nii.gz \
									                    --Ptxt ${Odir}/acqparams.txt \
									                    --idx  ${Odir}/${ID}_index.txt \
									                    --bvec ${Odir}/${ID}_Mdwi_bvec.bvec \
									                    --bval ${Odir}/${ID}_Mdwi_bval.bval \
									                    --TUout ${Odir}/${ID}_Mdwi_Bdwi_b0_topup \
									                    --Odir ${Odir} \
									                    --Onam ${Odir}/${ID}_eddy \
									                    --Mode openmp \
									                    --GE