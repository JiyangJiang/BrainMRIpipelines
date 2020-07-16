#!/bin/bash

# path to Template_6.nii
HiResDARTELtemplate=$1

# resampling scale or 'keep_dim'
iso_resample_scale=$2

# comma-delimited image list which are to be affined registered to MNI
# May 1, 2019 : passed a text file, otherwise argument is too long
DARTELimg2affine_list_file=$3


qsub_flag=$4



# =========================================================================================

DARTELimg2affine_list=`cat ${DARTELimg2affine_list_file}`

curr_dir=$(dirname $(which $0))
fMRI_folder=$(dirname $(dirname ${curr_dir}))
logdir=$(dirname ${HiResDARTELtemplate})
rand_suffix=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 5)

# estimate affine matrix
cat << EOF > ${logdir}/affine2mni.estimateMAT.${rand_suffix}
$FSLDIR/bin/flirt -in ${HiResDARTELtemplate} \
				  -ref ${fMRI_folder}/SPM/TPM.nii \
				  -omat $($FSLDIR/bin/remove_ext ${HiResDARTELtemplate})_affine2mni.mat \
				  -dof 12
EOF


# apply affine matrix to DARTEL image (DARTELimg2affine)
for DARTELimg2affine in `echo ${DARTELimg2affine_list} | tr ',' ' '`
do

re='^[0-9]+$'

if [[ ${iso_resample_scale} =~ $re ]]; then

cat << EOF >> ${logdir}/affine2mni.applyAffine.${rand_suffix}
$FSLDIR/bin/flirt -in ${DARTELimg2affine} \
				  -ref ${fMRI_folder}/SPM/TPM.nii \
				  -applyisoxfm ${iso_resample_scale} \
				  -init $($FSLDIR/bin/remove_ext ${HiResDARTELtemplate})_affine2mni.mat \
				  -out $($FSLDIR/bin/remove_ext ${DARTELimg2affine})_affine2mni
EOF

elif [ "${iso_resample_scale}" = "keep_dim" ]; then

cat << EOF >> ${logdir}/affine2mni.applyAffine.${rand_suffix}
$FSLDIR/bin/flirt -in ${DARTELimg2affine} \
				  -ref ${fMRI_folder}/SPM/TPM.nii \
				  -applyxfm \
				  -init $($FSLDIR/bin/remove_ext ${HiResDARTELtemplate})_affine2mni.mat \
				  -out $($FSLDIR/bin/remove_ext ${DARTELimg2affine})_affine2mni
EOF

fi
done





if [ "${qsub_flag}" = "yesQsub" ]; then
	estimateMAT_jid=`$FSLDIR/bin/fsl_sub -T 30 \
										 -N affine2mni_1 \
										 -l $logdir \
										 -t ${logdir}/affine2mni.estimateMAT.${rand_suffix}`

	applyAffine_jid=`$FSLDIR/bin/fsl_sub -j ${estimateMAT_jid} \
										 -T 30 \
										 -N affine2mni_2 \
										 -l $logdir \
										 -t ${logdir}/affine2mni.applyAffine.${rand_suffix}`
fi