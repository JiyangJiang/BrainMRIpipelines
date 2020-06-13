#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh


# ============ usage function ============ #

usage()
{
cat << EOF

DESCRIPTION: This script generates a file with the same number of 1s (or 2s) as the number of DWI volumes. 1 means the volume should look for the first line in acqparams.txt.

USAGE:
		Compulsory:

			--img|-i            <main DWI data>             The main DWI data
			--idx|-x            <index 1 or 2>              Index 1 or 2
			--Odir|-o           <output directory>          Output directory
			
		Optional:

			--help|-h                                       Display this message
			--pref|-p           <suffix string>             Prefix for the output text file (if not set, then index.txt)

EOF
}



# =========== passing arguments ============= #
OPTIND=1

if [ "$#" = "0" ]; then
	usage
	exit 0
fi

while [[ $# > 0 ]]; do
	key=$1
	shift

	case ${key} in
		
		--img|-i)
			img=$1
			shift
			;;

		--idx|-x)
			index=$1
			shift
			;;

		--Odir|-o)
			Odir=$1
			shift
			;;

		--help|-h)
			usage
			exit 0
			;;

		--pref|-p)
			pref=$1
			shift
			;;

		*)
			usage
			exit 1
			;;
	esac
done


# =============== check if variables are null ================ #
if [ -z ${img+a} ]; then
	echo
	echo "ERROR: img is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${index+a} ]; then
	echo
	echo "ERROR: index (--idx) is not properly set."
	echo
	usage
	exit 1
fi

if [ -z ${Odir+a} ]; then
	echo
	echo "ERROR: Odir is not properly set."
	echo
	usage
	exit 1
fi


# ============= optional flag ================ #
if [ ! -z ${pref+a} ]; then
	indexTXT_filename="${pref}_index.txt"
else
	indexTXT_filename="index.txt"
fi


# ============= Now do the job ================= #
echo -n "Creating ${indexTXT_filename} ..."

Nvol=`echo $(fslnvols ${img}) | sed 's/ //g'`

ind=""

for ((i=1; i<=${Nvol}; i+=1))
do
	ind="${ind} 1"
done

if [ -f "${Odir}/${indexTXT_filename}" ]; then
	rm -f ${Odir}/${indexTXT_filename}
fi

echo ${ind} > ${Odir}/${indexTXT_filename}

echo "   Done"