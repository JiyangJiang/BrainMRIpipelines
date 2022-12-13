#!/bin/bash

# --------------------------------------- #
# This script conducts bandpass           #
# after spatial normalisation to MNI, and #
# before group ICA.                       #
# --------------------------------------- #
#

cohortFolder=$1
iso_resample_scale=$2

echo "$(basename $0) : running, this will take some time ..."

[ -f ${cohortFolder}/SGE_commands/bandpassA ] && rm -f ${cohortFolder}/SGE_commands/bandpassA
[ -f ${cohortFolder}/SGE_commands/bandpassB ] && rm -f ${cohortFolder}/SGE_commands/bandpassB
[ -f ${cohortFolder}/SGE_commands/bandpassC ] && rm -f ${cohortFolder}/SGE_commands/bandpassC
[ -f ${cohortFolder}/SGE_commands/bandpassD ] && rm -f ${cohortFolder}/SGE_commands/bandpassD
[ -f ${cohortFolder}/SGE_commands/bandpassE ] && rm -f ${cohortFolder}/SGE_commands/bandpassE

while read final_epi
do
        if [ ! -f "$(echo ${final_epi} | awk -F '.nii' '{print $1}')_noBandpass.nii.gz" ]; then

                echo "Not bandpassed before."

                echo "cp ${final_epi} $(echo ${final_epi} | awk -F '.nii' '{print $1}')_noBandpass.nii.gz;fslmaths ${final_epi} -Tmean $(remove_ext ${final_epi})_Tmean" \
                        >> ${cohortFolder}/SGE_commands/bandpassA

                # echo "3dBandpass -prefix $(dirname ${final_epi})/bandpass -mask ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${iso_resample_scale}mm.nii.gz -blur 6 -despike 0.009 0.08 ${final_epi}" \
                #         >> ${cohortFolder}/SGE_commands/bandpassB
                echo "3dBandpass -prefix $(dirname ${final_epi})/bandpass -mask ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${iso_resample_scale}mm.nii.gz 0.009 0.08 ${final_epi}" \
                        >> ${cohortFolder}/SGE_commands/bandpassB

                echo "3dAFNItoNIFTI -prefix $(dirname ${final_epi})/final_cleanedup_func_std_space $(dirname ${final_epi})/bandpass+tlrc" \
                        >> ${cohortFolder}/SGE_commands/bandpassC

                echo "gzip -f $(dirname ${final_epi})/final_cleanedup_func_std_space.nii" \
                        >> ${cohortFolder}/SGE_commands/bandpassD

                echo "rm -f $(dirname ${final_epi})/bandpass+tlrc.*;cp $(dirname ${final_epi})/final_cleanedup_func_std_space.nii.gz $(dirname ${final_epi})/final_cleanedup_func_std_space_bandpass.nii.gz;fslmaths $(dirname ${final_epi})/final_cleanedup_func_std_space -add $(remove_ext ${final_epi})_Tmean $(dirname ${final_epi})/final_cleanedup_func_std_space" \
                        >> ${cohortFolder}/SGE_commands/bandpassE
        else

                echo "Already bandpassed. redoing."
                echo "mv $(echo ${final_epi} | awk -F '.nii' '{print $1}')_noBandpass.nii.gz ${final_epi};cp ${final_epi} $(echo ${final_epi} | awk -F '.nii' '{print $1}')_noBandpass.nii.gz;fslmaths ${final_epi} -Tmean $(remove_ext ${final_epi})_Tmean" \
                        >> ${cohortFolder}/SGE_commands/bandpassA

                # echo "3dBandpass -prefix $(dirname ${final_epi})/bandpass -mask ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${iso_resample_scale}mm.nii.gz -blur 6 -despike 0.009 0.08 ${final_epi}" \
                #         >> ${cohortFolder}/SGE_commands/bandpassB
                echo "3dBandpass -prefix $(dirname ${final_epi})/bandpass -mask ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${iso_resample_scale}mm.nii.gz 0.009 0.08 ${final_epi}" \
                        >> ${cohortFolder}/SGE_commands/bandpassB

                echo "3dAFNItoNIFTI -prefix $(dirname ${final_epi})/final_cleanedup_func_std_space $(dirname ${final_epi})/bandpass+tlrc" \
                        >> ${cohortFolder}/SGE_commands/bandpassC

                echo "gzip -f $(dirname ${final_epi})/final_cleanedup_func_std_space.nii" \
                        >> ${cohortFolder}/SGE_commands/bandpassD

                echo "rm -f $(dirname ${final_epi})/bandpass+tlrc.*;cp $(dirname ${final_epi})/final_cleanedup_func_std_space.nii.gz $(dirname ${final_epi})/final_cleanedup_func_std_space_bandpass.nii.gz;fslmaths $(dirname ${final_epi})/final_cleanedup_func_std_space -add $(remove_ext ${final_epi})_Tmean $(dirname ${final_epi})/final_cleanedup_func_std_space" \
                        >> ${cohortFolder}/SGE_commands/bandpassE
        fi

done < ${cohortFolder}/groupICA/input.list

bandpassA_jid=`fsl_sub -T 5 -N bandpassA -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/bandpassA`
bandpassB_jid=`fsl_sub -T 30 -N bandpassB -l ${cohortFolder}/SGE_commands/oe -j ${bandpassA_jid} -t ${cohortFolder}/SGE_commands/bandpassB`
bandpassC_jid=`fsl_sub -T 15 -N bandpassC -l ${cohortFolder}/SGE_commands/oe -j ${bandpassB_jid} -t ${cohortFolder}/SGE_commands/bandpassC`
bandpassD_jid=`fsl_sub -T 5 -N bandpassD -l ${cohortFolder}/SGE_commands/oe -j ${bandpassC_jid} -t ${cohortFolder}/SGE_commands/bandpassD`
bandpassE_jid=`fsl_sub -T 15 -N bandpassE -l ${cohortFolder}/SGE_commands/oe -j ${bandpassD_jid} -t ${cohortFolder}/SGE_commands/bandpassE`