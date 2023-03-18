#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

combSegsMaskSrcImg(){
	
	srcImg=$1
	GM=$2
	WM=$3
	CSF=$4
	outImg=$5

    outImg_folder=$(dirname "${outImg}")
    outImg_filename=`echo $(basename "${outImg}") | awk -F'.' '{print $1}'`

    ${FSLDIR}/bin/fslmaths ${GM} -add ${WM} -thr 0.5 -bin $(dirname $GM)/temp
    ${FSLDIR}/bin/fslmaths ${CSF} -thr 0.9 -bin -add $(dirname $GM)/temp -bin -fillh -mul $srcImg $outImg

    if [ "$6" = "maskout" ]; then
        ${FSLDIR}/bin/fslmaths ${CSF} -thr 0.9 -bin -add $(dirname $GM)/temp -bin -fillh ${outImg_folder}/${outImg_filename}_mask
	fi

    rm -f $(dirname $GM)/temp.nii.gz
    
}

# $1 = src img
# $2 = GM img
# $3 = WM img
# $4 = CSF img
# $5 = output img
combSegsMaskSrcImg $1 $2 $3 $4 $5