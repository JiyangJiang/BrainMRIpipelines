#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
JJM's STIL script to process FSL's DTIFIT for diffusion MRI data
User must have FSL 5.0.9 or above installed as well as MRtrix3.
The output is saved in a folder called "dtifit" in the subject's directory 
Make sure to give permission to execute by typing in chmod u+x name_of_this_file.sh
If Bad Interpreter message appears then type in sed -i -e 's/\r$//' name_of_this_file.sh and then execute the script

Inputs:  folder with dicoms, destination folder, suffix
Outputs: dwi[suffix].nii, bval[suffix].bval, bvec[suffix].bvec

COMPULSORY:
   -i        Input DIR_NAME of processed diffusion data
   -p        Input DESTINATION DIR DTIFIT location
   -s        Input SUBJECT_ID (suffix)
OPTIONS:
   -h      Show this message
EOF
}

##==============================================================================
OPTIND=1
while [[ $# > 0 ]]; do
    key="$1"
    shift
    case $key in
        -i|--InputDTI)
            INPUTDTI="$1"
            shift # past argument
            ;;
        -p|--InputDTIFIT)
            INPUTDTIFIT="$1"
            shift # past argument
            ;;
        -s|--InputSuffix)
            INPUTSUFFIX="$1"
            shift # past argument
            ;;
        -h|--help)
            usage
            exit 1
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

##==============================================================================
if [ -z ${INPUTDTI+x} ]; then
    echo " ERROR :  Input_dti_directory is unset "
    usage
    exit 1
fi
if [ -z ${INPUTDTIFIT+x} ]; then
    echo " ERROR :  Input_destination_dtifit_ directory is unset "
    usage
    exit 1
fi
if [ -z ${INPUTSUFFIX+x} ]; then
    echo " ERROR :  Input_subject_id is unset "
    usage
    exit 1
fi

##==============================================================================
# Begin processing
currentDIR=$(pwd)
echo
echo
echo "************************************************************************"
echo "*               STIL's DTIFIT brain diffusion MRI pipeline             *"
echo "************************************************************************"
# Processing steps
# 1. Make output directory called dtifit
# 2. Copy eddy_unwarped_images.nii.gz, rotatedbvecs, bvals and mask from previously processed pipeline to new directory
# 3. Navigate to dtifit directory
# 4. Convert mask.mif to mask.nii
# 5. Run dtifit
# 6. Delete eddy_unwarped_images.nii.gz, rotatedbvecs, bvals and mask

##==============================================================================
echo " ======= MAKING SUBJECT'S OUTPUT DIRECTORY ======= "
mkdir $INPUTDTIFIT
echo
echo " ======= COPYING eddy_unwarped_images.nii.gz, rotatedbvecs, bvals and mask from previously processed pipeline to DTIFIT directory ======= "
cp $INPUTDTI/eddy_unwarped_images*.nii.gz $INPUTDTIFIT
cp $INPUTDTI/rotated*.* $INPUTDTIFIT
cp $INPUTDTI/mrtrixbval*.* $INPUTDTIFIT
cp $INPUTDTI/mask.mif $INPUTDTIFIT

##==============================================================================
echo " ======= CONVERTING mask.mif TO mask.nii ======= "
cd $INPUTDTIFIT
mrconvert -force mask.mif mask.nii

##==============================================================================
echo " ======= CHANGING NAMES ======= "
mv eddy_unwarped*.* eddy.nii.gz
mv rotated*.* bvec.bvec
mv *bval*.* bval.bval


echo
##==============================================================================
echo " ======= RUNNING DTIFIT ======= "
# dtifit --data=eddy_unwarped_images"$INPUTSUFFIX"_dwi.nii.gz --out=dti_"$INPUTSUFFIX" --mask=mask.nii --bvecs=rotatedbvec_"$INPUTSUFFIX".txt --bvals=mrtrixbval_"$INPUTSUFFIX".txt
dtifit --data=eddy.nii.gz --out=dti_"$INPUTSUFFIX" --mask=mask.nii --bvecs=bvec.bvec --bvals=bval.bval

#rm eddy.nii.gz
#rm bvec.bvec
#rm bval,bval
#rm mask*.*

echo " ##### End of DTIFIT script ######"
echo

cd "$currentDIR"






