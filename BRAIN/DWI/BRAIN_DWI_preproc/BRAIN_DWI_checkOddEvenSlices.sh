#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh


# ============== usage function ================ #
usage ()
{
cat << EOF

DESCRIPTION: This script checkes whether 3D/4D image has odd or even number of slices. This can be useful as b02b0.cnf in topup only works for even number of slices.

REF: https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;c0f0d3a8.1512

USAGE:
		--img|-i        <image>          The image to check number slices for
		--help|-h                        Display this message

EOF
}

# ============= passing parameters ============= #
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

		--img|-i)
			img="$1"
			shift
			;;


		--help|-h)
			usage
			exit 0
			;;
	esac
done


# ============== checking whether the arguments are null =============== #
if [ -z ${img+a} ]; then
	echo "ERROR: img is not properly set."
	echo
	usage
	exit 1
fi


# ========== Now do the job ============ #

# check odd/even
Nsclices=`echo $(fslval ${img} dim3) | sed 's/ //g'`

# if even
[ $((Nsclices%2)) -eq 0 ] && \
	echo "$(basename "${img}") has even number of slices (N=${Nsclices}) - no action."


# if odd
if [ $((Nsclices%2)) -eq 1 ]; then
	echo -n "$(basename "${img}") has odd number of slices (N=${Nsclices}) - trimming the first slice..."

	img_folder=$(dirname "${img}")
	img_filename=`echo $(basename "${img}") | awk -F'.' '{print $1}'`
	
	fslroi ${img} \
		   ${img_folder}/${img_filename}_even \
		   0 -1 \
		   0 -1 \
		   1 -1 \
		   0 -1

	echo "   Done"

fi

