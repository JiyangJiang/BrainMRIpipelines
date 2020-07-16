#!/bin/bash

usage(){
cat << EOF

$(basename $0) : Copy header from src image and paste to tgt (target) image.

USAGE :

	future_fsl_cpHdr.sh srcImg.nii     tgtImg.nii
	future_fsl_cpHdr.sh srcImg.nii.gz  tgtImg.nii.gz


COMPULSORY :

	-s, --srcImg 			<src_img>			Source image of which header will be copied to
												target image.

	-t, --tgtImg			<tgt_img>			Target image of which header will be replaced
												by that of source image.

	-h, --help									Display this message.

EOF
}

for arg in $@
do
	case "$arg" in

		-s|--srcImg)
			srcImg=$2
			shift 2
			;;

		-t|--tgtImg)
			tgtImg=$2
			shift 2
			;;

		-h|--help)
			usage
			exit 0
			;;

		-*)
			usage
			exit 1
			;;
	esac
done

[ -z ${srcImg+x} ] && usage && exit 1
[ -z ${tgtImg+x} ] && usage && exit 1


. ${FSLDIR}/etc/fslconf/fsl.sh

srcImg_folder=$(dirname $(readlink -f $srcImg))
tgtImg_folder=$(dirname $(readlink -f $tgtImg))

tgtImg_filename=`imglob $(basename $(readlink $tgtImg))`

# make a tgt img backup
imcp ${tgtImg} ${tgtImg_folder}/${tgtImg_filename}_orig

${FSLDIR}/bin/fslhd -x ${srcImg} > ${srcImg_folder}/srcImg_hdr.xml

${FSLDIR}/bin/fslcreatehd ${srcImg_folder}/srcImg_hdr.xml \
						  ${tgtImg}

rm -f ${srcImg_folder}/srcImg_hdr.xml
