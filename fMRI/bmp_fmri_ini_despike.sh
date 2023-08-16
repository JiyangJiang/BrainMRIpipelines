#!/bin/bash

usage (){

cat << EOF

DESCRIPTION :

  Despiking with AFNI's 3dDespike.

USAGE :

  $(basename $0) argument1

ARGUMENTS :

  argument 1: Path to study folder.


EOF
}


Sfolder=$1

func_img=`ls ${Sfolder}/func.nii*`

3dDespike -ignore 10 -localedit -NEW -prefix ${Sfolder}/func_despike ${func_img}

3dAFNItoNIFTI -prefix ${Sfolder}/func_despike ${Sfolder}/func_despike+orig

rm -f ${Sfolder}/func_despike+orig.*

# change name to continue with following steps
mv ${Sfolder}/func.nii ${Sfolder}/func_beforeDespike.nii
mv ${Sfolder}/func_despike.nii ${Sfolder}/func.nii
