#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh



ven_mask=$1
c3_mask=$2
outputDir=$3

# add -dilM if dilation is needed
${FSLDIR}/bin/fslmaths ${ven_mask} -nan \
									-bin \
									${outputDir}/dilated_ventricular_mask

${FSLDIR}/bin/fslmaths ${c3_mask} -nan \
									-thr 0.8 \
									-bin \
									-mul ${outputDir}/dilated_ventricular_mask \
									${outputDir}/ventricular_mask

									#-mas ${outputDir}/dilated_ventricular_mask \
										
