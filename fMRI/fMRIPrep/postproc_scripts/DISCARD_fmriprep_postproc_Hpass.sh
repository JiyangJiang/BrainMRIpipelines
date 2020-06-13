#!/bin/bash

# -------------------------------------------------------------------------
# DESCRIPTION :
# This script performs high pass filtering on the input 4D image.
# ------------------------------------------------------------------------
# USAGE :
#           $1 = path to the input 4D image
#           $2 = path to output folder
#           $3 = threshold for high pass (in seconds)
#           $4 = extract TR from the input 4D image ('epi') or passing
#                argument to $5 ('tr')
#           if $4 = 'tr', $5 = TR_value; if $4 = 'epi', leave $5 empty.
# ------------------------------------------------------------------------



Hpass(){

inputImg=$1
outputFolder=$2
Hpass_thr=$3
which_tr=$4

if [ "${which_tr}" = "tr" ]; then
	tr=$5
fi


# some preparation
# -------------------------------------------------------------------------
if [ -d "${outputFolder}/tmp_fmriprepTdenoiseHpass" ]; then
	rm -fr ${outputFolder}/tmp_fmriprepTdenoiseHpass
fi

mkdir ${outputFolder}/tmp_fmriprepTdenoiseHpass
tmpOutFoldr=${outputFolder}/tmp_fmriprepTdenoiseHpass


# Get mean of the 4D data (to be added to the residuals below)
# -------------------------------------------------------------------------
fslmaths ${inputImg} \
		 -Tmean \
		 ${tmpOutFoldr}/input4Dimg_Tmean


# apply highpass filter and add the Tmean back into data
# ------------------------------------------------------
case ${which_tr} in
	tr)
		tr=${tr}
		;;
	epi)
		tr=`fslval ${inputImg} pixdim4`
		;;
esac

fwhm=`python -c "print (${Hpass_thr}/${tr})"`
sigma=`python -c "print (${fwhm}/2)"`


fslmaths ${inputImg} -bptf ${sigma} -1 \
					 -add ${tmpOutFoldr}/input4Dimg_Tmean \
					 ${outputFolder}/input4Dimg_Hpass
}

Hpass $1 $2 $3 $4 $5