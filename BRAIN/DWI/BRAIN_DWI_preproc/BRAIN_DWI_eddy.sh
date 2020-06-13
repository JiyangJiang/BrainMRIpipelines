#!/bin/bash

# EXAMPLE:
#
# BRAIN_DWI_eddy.sh --Mdwi outputDIR/TEST123_Mdwi.nii.gz \
#                   --Bmsk outputDIR/TEST123_Mdwi_Bdwi_b0_topup_unwarped4D_Tmean_brain_mask.nii.gz \
#                   --Ptxt outputDIR/acqparams.txt \
#                   --idx  outputDIR/TEST123_index.txt \
#                   --bvec outputDIR/TEST123_Mdwi_bvec.bvec \
#                   --bval outputDIR/TEST123_Mdwi_bval.bval \
#                   --TUout outputDIR/TEST123_Mdwi_Bdwi_b0_topup \
#                   --Odir outputDIR \
#                   --Onam TEST123_eddy \
#                   --Mode openmp \
#                   --GE




# ========== usage function ========== #
usage()
{
cat << EOF

DESCRIPTION: This script runs eddy_openmp or eddy_cuda.

USAGE:

	COMPULSORY:

		--Mdwi|-m          <path to main DWI>             main DWI
		--Bmsk|-k          <path to brain mask>           DWI brain mask
		--Ptxt|-p          <acqparams.txt>                acqparams.txt
		--idx|-x           <index.txt>                    index txt file
		--bvec|-c          <bvec>                         bvec file
		--bval|-l          <bval>                         bval file
		--TUout|-t         <topup base name>              base name specified with --out in topup
		--Odir|-o          <eddy output directory>        eddy output directory
		--Onam|-n          <eddy output base name>        eddy output base name
		--Mode|-e          <openmp or cuda>               openmp or cuda for eddy_openmp or eddy_cuda
		--help|-h                                         display this message

	
	OPTIONAL:

		--GE                                              using default bval/bvec template

EOF
}


# ========== passing arguments ============= #
OPTIND=1

GEmode="OFF"

while [[ $# > 0 ]]; do
	key=$1
	shift

	case ${key} in

		--Mdwi|-m)
			Mdwi=$1
			shift
			;;

		--Bmsk|-k)
			brainMask=$1
			shift
			;;

		--Ptxt|-p)
			acqparams=$1
			shift
			;;

		--idx|-x)
			index=$1
			shift
			;;

		--bvec|-c)
			bvec=$1
			shift
			;;

		--bval|-l)
			bval=$1
			shift
			;;

		--TUout|-t)
			topup_out=$1
			shift
			;;

		--Odir|-o)
			Odir=$1
			shift
			;;

		--Onam|-n)
			Onam=$1
			shift
			;;

		--Mode|-e)
			mode=$1
			shift
			;;

		--help|-h)
			usage
			exit 0
			;;

		--GE)
			GEmode="ON"
			;;

	esac


done


# ============ checking if arguments are null ============ #
if [ -z ${Mdwi+a} ]; then
	echo
	echo "ERROR: Mdwi (--Mdwi|-m) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${brainMask+a} ]; then
	echo
	echo "ERROR: brainMask (--Bmsk|-k) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${acqparams+a} ]; then
	echo
	echo "ERROR: acqparams (--Ptxt|-p) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${index+a} ]; then
	echo
	echo "ERROR: index (--idx|-x) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${bvec+a} ]; then
	echo
	echo "ERROR: bvec (--bvec|-c) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${bval+a} ]; then
	echo
	echo "ERROR: bval (--bval|-l) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${topup_out+a} ]; then
	echo
	echo "ERROR: topup_out (--TUout|-t) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${Odir+a} ]; then
	echo
	echo "ERROR: Odir (--Odir|-o) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${Onam+a} ]; then
	echo
	echo "ERROR: Onam (--Onam|-n) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${mode+a} ]; then
	echo
	echo "ERROR: mode (--Mode|-e) is not properly set."
	echo
	usage
	exit 1
fi


# =========== whether using bvec/bval templates ============= #

if [ "${GEmode}" = "ON" ]; then
	Nvols=`echo $(fslnvols ${Mdwi}) | sed 's/ //g'`
	scriptDir=$(dirname "$0")

	case $Nvols in
		68)
		bvec="$scriptDir/64_Directions.bvecs"
		#Note this file is cut from 147_Directions.bvecs
		;;
		130)
		bvec="${scriptDir}/129_Directions.bvecs"
		;;
		134)
		bvec="${scriptDir}/133_Directions.bvecs"
		;;
		148)
		bvec="${scriptDir}/147_Directions.bvecs"
		;;
	esac
fi





# =========== Some preparation work ================ #
# -------------------------------------------------- #
# Mdwi will need same dimension as dwi mask which is 
# generated from the 4D blip-up-down b0s
# -------------------------------------------------- #
Nslices_Mdwi=`echo $(fslval ${Mdwi} dim3) | sed 's/ //g'`
Nslices_Bmsk=`echo $(fslval ${brainMask} dim3) | sed 's/ //g'`

if [ ${Nslices_Mdwi} -ne ${Nslices_Bmsk} ]; then
	echo -n "Mdwi and Bmsk do not have the same dimension, removing the first slice from Mdwi ..."
	Mdwi_folder=$(dirname "${Mdwi}")
	Mdwi_filename=`echo $(basename "${Mdwi}") | awk -F'.' '{print $1}'`

	fslroi ${Mdwi} \
		   ${Mdwi_folder}/${Mdwi_filename}_even \
		   0 -1 \
		   0 -1 \
		   1 -1 \
		   0 -1

	echo "   Done"

	Mdwi_toUse="${Mdwi_folder}/${Mdwi_filename}_even.nii.gz"
else
	Mdwi_toUse=${Mdwi}
fi

# ----------------------------
# get FSL-compatible bvec/bval
# ----------------------------
mrconvert -force \
		  -fslgrad ${bvec} ${bval} \
		  ${Mdwi_toUse} \
		  ${Odir}/${Mdwi_filename}_mif.mif

mrinfo -force \
	   -export_grad_fsl ${Odir}/${Mdwi_filename}_bvec2use.bvec \
	   				    ${Odir}/${Mdwi_filename}_bval2use.bval \
	   ${Odir}/${Mdwi_filename}_mif.mif
		  

bvec_toUse=${Odir}/${Mdwi_filename}_bvec2use.bvec
bval_toUse=${Odir}/${Mdwi_filename}_bval2use.bval


# ============== Now do the job ================= #
# ==============    Run eddy    ================= #
# ----------------------------------------------- #

echo -n "Running eddy_${mode} ..."

# eddy_${mode} --imain=${Mdwi_toUse} \
# 			 --mask=${brainMask} \
# 			 --acqp=${acqparams} \
# 			 --index=${index} \
# 			 --bvecs=${bvec} \
# 			 --bvals=${bval} \
# 			 --topup=${topup_out} \
# 			 --out=${Odir}/${Onam} \
# 			 --verbose


[ ${mode} = "openmp" ] && \
eddy_openmp --imain=${Mdwi_toUse} \
			--mask=${brainMask} \
			--acqp=${acqparams} \
			--index=${index} \
			--bvecs=${bvec_toUse} \
			--bvals=${bval_toUse} \
			--topup=${topup_out} \
			--out=${Odir}/${Onam} \
			--verbose


[ ${mode} = "cuda" ] && \
eddy_cuda --imain=${Mdwi_toUse} \
		  --mask=${brainMask} \
		  --acqp=${acqparams} \
		  --index=${index} \
		  --bvecs=${bvec_toUse} \
		  --bvals=${bval_toUse} \
		  --topup=${topup_out} \
		  --out=${Odir}/${Onam}

echo "   Done."