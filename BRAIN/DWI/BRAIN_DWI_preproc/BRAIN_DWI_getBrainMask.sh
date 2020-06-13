#!/bin/bash


. ${FSLDIR}/etc/fslconf/fsl.sh

# ======== usage function ========== #
usage ()
{
cat << EOF

DESCRIPTION: This script gets the brain mask from the topup-ed blip-up-blip-down b0s (4D).

USAGE:
		--img|-i         <path_to_topuped_blippedB0s>           Path to topup-ed blip-up-blip-down b0s (4D)
		--Odir|-o        <output_directory>                     Output directory
		--help|-h                                               Display this message

EOF
}

# ========== passing parameters =========== #
OPTIND=1

if [ "$#" -eq "0" ]; then
	usage
	exit 0
fi

while [[ $# > 0 ]]; do
	key="$1"
	shift

	case ${key} in

		--img|-i)
			img="$1"
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


# ============ check if par is null ============= #
if [ -z ${img+a} ]; then
	echo "ERROR: img is not properly set."
	echo
	usage
	exit 1
fi


# ========== Now do the job =========== #
echo -n "Getting brain mask ..."

img_folder=$(dirname "${img}")
img_filename=`echo $(basename "${img}") | awk -F'.' '{print $1}'`

fslmaths ${img} \
		 -Tmean ${img_folder}/${img_filename}_Tmean

bet ${img_folder}/${img_filename}_Tmean \
	${img_folder}/${img_filename}_Tmean_brain \
	-m \
	-f 0.2

echo "   Done"