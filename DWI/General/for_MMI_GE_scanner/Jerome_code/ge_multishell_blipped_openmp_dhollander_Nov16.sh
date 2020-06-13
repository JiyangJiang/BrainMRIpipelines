#!/bin/bash

# General Electric Healthcare script to process multishell blipped diffusion MRI data
# Written by Jerome J Maller, GE HealthCare Australia 2016
# User must have dcm2nii installed.
# User must have FSL 5.0.9 or above installed.
# This script is for those not using the neurodebian version of FSL. If using neurodebian then all FSL commands
# must have 5.0-FSL- inserted in front of them
# User must have MRtrix 0.3.15 or above installed
# The output is saved in a folder called "output" in the subject's directory 
# It is suggested that you place this script in your PATH eg export PATH="$PATH:~/Desktop", otherwise type in ./ge_multishell_blipped.sh
# Make sure to give permission to execute by typing in chmod u+x ge_mutlishell_blipped.sh
# If Bad Interpreter message appears then type in sed -i -e 's/\r$//' ge_multishell_blipped.sh and then execute the script


echo
echo "*****************************************************************************"
echo "*** General Electric Healthcare multishell blipped diffusion MRI pipeline ***"
echo "***                        by Jerome Maller, 2016                         ***"
echo "***                 All rights reserved GE Healthcare 2016                ***"
echo "*****************************************************************************"
echo
echo
echo "usage: $0 -i input_main_dti_directory -b input_blipped_dti_directory -t t1_data_directory"
echo
echo

usage()

{

cat << EOF

USAGE: $0 -i input_main_dti_directory -b input_blipped_dti_directory -t t1_data_directory

COMPULSORY:

   -i      Input DIR_NAME of main set of diffusion dicoms

   -b      Input DIR_NAME of blipped set of diffusion dicoms

   -t      Input DIR_NAME of T1-weighted dicoms


OPTIONS:

   -h      Show this message

EOF

}


OPTIND=1
 

while [[ $# -gt 1 ]]

do

key="$1"

 

case $key in

    -i|--InputDTI)

    INPUTDTI="$2"

    shift # past argument

    ;;
 
    -b|--InputBlippedDTI)

    INPUTBLIPPEDDTI="$2"

    shift # past argument

    ;;

    -t|--InputT1)

    INPUTT1="$2"

    shift # past argument

    ;;

    -h|--help)

    usage

    shift # past argument

    ;;

    *)

            # unknown option

    ;;

esac

shift # past argument or value

done
echo

echo "input_main_dti = ${INPUTDTI}"
echo "input_blipped_dti = ${INPUTBLIPPEDDTI}"
echo "input_t1 = ${INPUTT1}"

if [ -z ${INPUTDTI+x} ]; then

    echo " ERROR :  InputDTI is unset "

    usage

    exit

fi

if [ -z ${INPUTBLIPPEDDTI+x} ]; then

    echo " ERROR :  Input_blipped_dti_DIR_NAME is unset "

    usage

    exit

fi

if [ -z ${INPUTT1+x} ]; then

    echo " ERROR :  T1_NAME is unset "

    usage

    exit

fi

# Begin processing
echo
echo
cd $INPUTDTI
echo
echo "CONVERTING MAIN DIFFUSION DATASET DICOMS TO NIFTI FORMAT"
echo
dcm2nii -m N -g N *
echo
echo "CHANGING NIFTI NAME TO dwi.nii"

mv *.nii dwi.nii

echo "RENAMING bval to bval.bval and bvec to bvec.bvec"

mv *.bval bval.bval
mv *.bvec bvec.bvec

# Make subject's working directory
cd ..
mkdir output
cd output
OUTPUTDIRNAME="$(pwd)"

echo "MOVING dwi.nii, bvec.bvec and bval.bval TO SUBJECT'S WORKING DIRECTORY"
cd $INPUTDTI
mv dwi.nii $OUTPUTDIRNAME
mv bvec.bvec $OUTPUTDIRNAME
mv bval.bval $OUTPUTDIRNAME

cd $INPUTBLIPPEDDTI
echo "CONVERTING FLIPPED DIFFUSION DATASET DICOMS TO NIFTI FORMAT"
echo
dcm2nii -m N -g N *
echo
echo "CHANGING NIFTI NAME TO dwiflipped.nii"

mv *.nii dwiflipped.nii

echo "MOVING dwiflipped.nii TO SUBJECT'S WORKING DIRECTORY"
mv dwiflipped.nii $OUTPUTDIRNAME

cd $INPUTT1
echo "CONVERTING T1-weighted DATASET DICOMS TO NIFTI FORMAT AND CHANGING NAME TO t1.nii"

dcm2nii -m N -g N *
mv *co*.nii t1.nii

echo "MOVING t1.nii TO SUBJECT'S WORKING DIRECTORY"
mv t1.nii $OUTPUTDIRNAME

# Next command deletes the remaining nifti files in the t1 directory i.e. original and reorientated original
rm *.nii

echo "MOVING TO SUBJECT'S WORKING DIRECTORY"
cd $OUTPUTDIRNAME

echo "EXTRACTING BZERO FROM MAIN DIFFUSION DATASET"
fslroi dwi.nii b0_blipup 0 1

# Alternatively, to extract all bzero volumes:
# mrconvert dwi.nii -fslgrad bvec.bvec bval.bval dwinii2mif.mif
# dwiextract -bzero dwinii2mif.mif allbzero.mif
# mrconvert allbzero.mif b0_blipup.nii

echo "EXTRACTING BZERO FROM BLIPPED DATASET"

fslroi dwiflipped.nii b0_blipdown 0 1

echo "MERGING BZEROS FROM MAIN AND BLIPPED DATASETS"
fslmerge -t b0_bothblips b0_blipup b0_blipdown

echo "CREATING acqparams.txt FILE"

echo "0 -1 0 0.11154" >acqparams.txt ; echo "0 1 0 0.11154" >>acqparams.txt

echo "RUNNING TOPUP. THIS CAN TAKE A FEW MINUTES"

topup --imain=b0_bothblips --datain=acqparams.txt --config=b02b0.cnf --out=topup_b0_blips --iout=my_iout --fout=my_fout

echo "RUNNING BET AND CREATING MASK BASED ON BZERO FROM MAIN DIFFUSION DATASET"

bet b0_blipup nodif_brain -m -f 0.2

echo
fslnvols dwi.nii >nvols.txt
vols=$(fslnvols dwi.nii)
echo
echo "THIS IS HOW MANY VOLUMES IN YOUR MAIN DATASET: $vols"
echo
echo "CREATING index.txt FILE"

indx=""
for ((i=1; i<=$vols; i+=1));do indx="$indx 1"; done
echo $indx > index$vols.txt


echo "CREATING acqparams_$vols.txt FILE"
echo

for ((i=0; i<vols; i++));
do printf "%s\n" "0 1 0 0.11154" >>acqparams_$vols.txt
done
echo
#BECAUSE ALL OF THE GE Multiband Multishell WIP DICOMS HAVE THE SAME VALUE ENTERED AS THE HIGHEST BVALUE ON THE CONSOLE
#NEED TO CREATE A BVAL FILE WITH THE CORRECT BVALUES. THIS IS DONE BY CONVERTING THE NII, BVAL AND BVEC FROM DCM2NII INTO MIF FORMAT
#AND THEN EXTRACTING THE CORRECT BVAL (AND BVEC) FROM THAT MIF FILE
mrconvert dwi.nii -fslgrad bvec.bvec bval.bval dwinii2mifpreeddy.mif
mrinfo dwinii2mifpreeddy.mif -export_grad_fsl mrtrixbvec.txt mrtrixbval.txt

echo "RUNNING EDDY. NOTE THAT THIS CAN TAKE A LONG TIME"
echo
eddy_openmp --imain=dwi --mask=nodif_brain_mask --index=index$vols.txt --acqp=acqparams_$vols.txt --bvecs=mrtrixbvec.txt --bvals=mrtrixbval.txt --fwhm=0 --topup=topup_b0_blips --flm=quadratic --out=eddy_unwarped_images
echo
echo "RENAMING ROTATED BVEC"
mv eddy_unwarped_images.eddy_rotated_bvecs rotatedbvec.bvec

echo
echo "CONVERTING EDDY CORRECTED NII INTO MIF FORMAT FOR USE IN MRtrix3"
mrconvert eddy_unwarped_images.nii.gz -fslgrad rotatedbvec.bvec mrtrixbval.txt dwinii2mif.mif
gunzip eddy_unwarped_images.nii.gz
echo

echo "EXTRACTING BZERO FROM EDDY CORRECTED DIFFUSION DATA"
cd $OUTPUTDIRNAME
echo
fslroi eddy_unwarped_images.nii.gz nodif_eddy 0 1

echo "REGISTERING T1-WEIGHTED SCAN TO THE BZERO FROM EDDY CORRECTED DIFFUSION DATA. THIS CAN TAKE A FEW MINUTES TO COMPLETE"
echo
flirt -in t1.nii -ref nodif_eddy.nii -out t1_reg.nii -omat t1_reg.mat -bins 256 -cost normmi -searchrx -5 5 -searchry -5 5 -searchrz -5 5 -dof 6 -interp trilinear

echo "RUNNING BET ON THE REGISTERED T1-WEIGHTED DATA AND THEN CREATING A MASK FROM IT"
echo
bet t1_reg.nii t1_reg_bet.nii -f 0.5 -m

echo "CONVERTING FORMAT OF THE BRAIN MASK INTO MIF FORMAT"
echo
mrconvert t1_reg_bet_mask.nii.gz mask.mif

echo "SEGMENTING THE OUTPUT INTO GM, WM, AND CSF MASKS"
echo
fast -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -o t1_reg_bet

echo "CONVERTING GM, WM AND CSF MASKS INTO MIF FORMAT"
echo
mrconvert t1_reg_bet_pve_0.nii.gz mask_csf.mif
mrconvert t1_reg_bet_pve_1.nii.gz mask_gm.mif
mrconvert t1_reg_bet_pve_2.nii.gz mask_wm.mif
echo
echo "CALCULATING BVALUE IN EACH SHELL"
mrinfo dwinii2mif.mif -shells >shell_bvalues.txt
# Add commas between each shell bvalue
sed -e "s/ /,/g" < shell_bvalues.txt > tempshell_values.txt
sed 's/.$//' tempshell_values.txt > tempshell_values.nolast
mv tempshell_values.nolast shellbvalues_wm.txt

echo "CALCULATING NUMBER OF DIRECTIONS IN EACH SHELL"
mrinfo dwinii2mif.mif -shellcount >shellcount.txt

# The command below inserts commas between bvalues but has a comma at the end:

sed -e "s/ /,/g" < shellcount.txt > shellcount2.txt

# Removing comma at the end:

sed 's/.$//' shellcount2.txt > shellcount2.nolast
mv shellcount2.nolast shellcountall.txt

echo "CREATING RESPONSE FILES"
echo
#COMMAND BELOW USES THE DHOLLANDER OPTION WHICH DOES NOT REQUIRE YOU TO MANUALLY SPECIFY LMAX OR SHELL VALUES

dwi2response dhollander dwinii2mif.mif wm.txt gm.txt csf.txt

echo
echo "CREATING ODF FILES"
dwi2fod msmt_csd dwinii2mif.mif wm.txt fod_wm.mif gm.txt gm.mif csf.txt csf.mif -mask mask.mif

echo "GENERATING TRACTOGRAPHY BASED ON 1 MILLION STREAMLINES"
tckgen fod_wm.mif wholebrain_CSD_1m.tck -seed_image mask.mif -mask mask.mif -number 1000000
echo
echo "TO CHECK THE OUTPUT TYPE IN: mrview t1_reg.nii.gz -tractography.load wholebrain_CSD_1m.tck"

# CLEANUP FILES NOT REQUIRED
rm acqparams_148.txt
rm acqparams.txt
rm b0_blipdown.nii.gz
rm b0_blipup.nii.gz
rm b0_bothblips.nii.gz
rm bval.bval
rm bvec.bvec
rm dwiflipped.nii
rm dwi.nii
rm dwinii2mifpreeddy.mif
rm eddy_unwarped_images.eddy_rotated_bvecs2
rm list.txt
rm mrtrixbvec.txt
rm nodif_brain_mask.nii.gz
rm nodif_brain.nii.gz
rm nodif_eddy.nii.gz
rm shell_bvalues.txt
rm shellcount2.txt
rm shellcount.txt
rm t1.nii
rm t1_reg_bet_mixeltype.nii.gz
rm t1_reg_bet_pveseg.nii.gz
rm t1_reg_bet_seg.nii.gz
rm t1_reg.mat






