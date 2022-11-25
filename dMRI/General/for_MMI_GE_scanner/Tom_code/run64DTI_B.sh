#!/bin/bash


echo
echo "*****************************************************************************"
echo "***  Single-shell blipped 64 direction diffusion dataset MRI pipeline     ***"
echo "***                        by Jerome Maller, 2016                         ***"
echo "***                                                                       ***"
echo "*****************************************************************************"
echo
echo

##==============================================================================
usage()
{
cat << EOF
PROCESS DATA FOR CHRONIC STUDY
THIS INCLUDES 1 LARGE DIFFUSION DATASET (AND BLIPPING)

COMPULSORY:
   -ia        Set 1 diffusion .nii
   -ibveca    Set 1 bvec
   -ibvala    Set 1 bval
   -iflip     Flipped (blipped) .nii
   -o         WORKING directory name
   -s         Input SUBJECT_ID (suffix)

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
        -ia|--nii1)
            nii1="$1"
            shift # past argument
            ;;
        -ibveca|--bvec1)
            bvec1="$1"
            shift # past argument
            ;;
        -ibvala|--bval1)
            bval1="$1"
            shift # past argument
            ;;
        -o|--workingDIR)
            workingDIR="$1"
            shift # past argument
            ;;
        -iflip|--niiFLIP)
            niiFLIP="$1"
            shift # past argument
            ;;
        -s|--Suffix)
            SUFFIX="$1"
            shift # past argument
            ;;
        -h|--help)
            usage
            exit 1
            ;;
        *)
            echo "Unknown parameter " $key
            usage
            exit 1
            ;;
    esac
done


##==============================================================================
if [ -z ${nii1+x} ]; then
    echo " ERROR :  nii1 directory is unset "
    usage
    exit 1
fi
if [ -z ${bvec1+x} ]; then
    echo " ERROR :  bvec1 directory is unset "
    usage
    exit 1
fi
if [ -z ${bval1+x} ]; then
    echo " ERROR :  bval1 directory is unset "
    usage
    exit 1
fi
if [ -z ${workingDIR+x} ]; then
    echo " ERROR :  nii1 destination directory is unset "
    usage
    exit 1
fi
if [ -z ${niiFLIP+x} ]; then
    echo " ERROR :  flipped blipped nii directory is unset "
    usage
    exit 1
fi
if [ -z ${SUFFIX+x} ]; then
    echo " ERROR :  Input subject id is unset "
    usage
    exit 1
fi

##==============================================================================
### SETUP ALL INPUT ....
if ! [ -f "$niiFLIP" ] ; then
    echo  "*** ERROR *** file not found: " "$niiFLIP"
    exit 1
fi
setupDTI2Mrtrix.sh -o "$workingDIR" -i "$nii1" -bval "$bval1" -bvec "$bvec1" -s $SUFFIX
if [ $? -ne 0 ]; then
    echo "*** ERROR *** in setupDTI2Mrtrix.sh for " $workingDIR
    exit 1
fi


##==============================================================================
echo "=========== EXTRACT 64 DIRECTIONS FROM GENFL DATASET ==========="
echo "START: " $(date) 
Extract64.sh -o $workingDIR -s $SUFFIX
echo "END: " $(date) " ===============////====================="

##==============================================================================
echo "================ BLIP CORRECTION TOPUP ===================="
echo "START: " $(date) 
blipCorrectionTopup_REVISED.sh -f $niiFLIP -o $workingDIR -s $SUFFIX
echo "END: " $(date) " ===============////====================="


##==============================================================================
echo "================ DWI DENOISING ===================="
echo "START: " $(date) 
for (( i=1; i<4; i++ )); do
    dwiDenoise.sh -o $workingDIR -s $SUFFIX
done
echo "END: " $(date) " ===============////====================="
##

##==============================================================================
echo "================== EDDY RUN BLIPPED ===================="
echo "START: " $(date) 
eddyRunBlipped_REVISED.sh -o $workingDIR -s $SUFFIX
echo "END: " $(date) " ===============////====================="

###
##==============================================================================
mrtrixConversionAndProcessing.sh -o $workingDIR -s $SUFFIX

echo " ######## PROCESSING COMPLETE FOR TOPUP, EDDY, MRTRIX3 64d TRACTOGRAPHY PIPELINE ######## "



