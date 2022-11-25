#!/bin/bash


echo
echo "*****************************************************************************"
echo "***  Multishell NOT BLIPPED diffusion blipped 3 dataset MRI pipeline      ***"
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
THIS INCLUDES 3 LARGE DIFFUSION DATASETS (NO BLIPPING)

COMPULSORY:
   -ia        Set 1 diffusion .nii
   -ibveca    Set 1 bvec
   -ibvala    Set 1 bval
   -ib        Set 2 diffusion .nii
   -ibvecb    Set 2 bvec
   -ibvalb    Set 2 bval
   -ic        Set 3 diffusion .nii
   -ibvecc    Set 3 bvec
   -ibvalc    Set 3 bval
   -o         WORKING directory name
   -s         SUBJECT_ID (suffix)

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
        -ib|--nii2)
            nii2="$1"
            shift # past argument
            ;;
        -ibvecb|--bvec2)
            bvec2="$1"
            shift # past argument
            ;;
        -ibvalb|--bval2)
            bval2="$1"
            shift # past argument
            ;;
        -ic|--nii3)
            nii3="$1"
            shift # past argument
            ;;
        -ibvecc|--bvec3)
            bvec3="$1"
            shift # past argument
            ;;
        -ibvalc|--bval3)
            bval3="$1"
            shift # past argument
            ;;
        -s|--Suffix)
            SUFFIX="$1"
            shift # past argument
            ;;
        -o|--workingDIR)
            workingDIR="$1"
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
if [ -z ${nii2+x} ]; then
    echo " ERROR :  nii2 directory is unset "
    usage
    exit 1
fi
if [ -z ${bvec2+x} ]; then
    echo " ERROR :  bvec2 directory is unset "
    usage
    exit 1
fi
if [ -z ${bval2+x} ]; then
    echo " ERROR :  bval2 directory is unset "
    usage
    exit 1
fi
if [ -z ${nii3+x} ]; then
    echo " ERROR :  nii3 directory is unset "
    usage
    exit 1
fi
if [ -z ${bvec3+x} ]; then
    echo " ERROR :  bvec3 directory is unset "
    usage
    exit 1
fi
if [ -z ${bval3+x} ]; then
    echo " ERROR :  bval3 directory is unset "
    usage
    exit 1
fi
if [ -z ${SUFFIX+x} ]; then
    echo " ERROR :  Input subject id is unset "
    usage
    exit 1
fi
if [ -z ${workingDIR+x} ]; then
    echo " ERROR :  combined output directory is unset "
    usage
    exit 1
fi


##==============================================================================
declare -a niiL=("$nii1" "$nii2" "$nii3")
declare -a bvecL=("$bvec1" "$bvec2" "$bvec3")
declare -a bvalL=("$bval1" "$bval2" "$bval3")
OUTDIR1="$workingDIR"/outputA
OUTDIR2="$workingDIR"/outputB
OUTDIR3="$workingDIR"/outputC
declare -a outDIRL=("$OUTDIR1" "$OUTDIR2" "$OUTDIR3")

##==============================================================================
## SETUP ALL INPUT ....
for (( i=1; i<4; i++ )); do
    setupDTI2Mrtrix.sh -o ${outDIRL[$i-1]} -i ${niiL[$i-1]} -bval ${bvalL[$i-1]} -bvec ${bvecL[$i-1]} -s $SUFFIX
    if [ $? -ne 0 ]; then
        echo "*** ERROR *** in setupDTI2Mrtrix.sh for " ${outDIRL[$i-1]}
        exit 1
    fi
done

##==============================================================================
echo "================ DWI DENOISING ===================="
echo "START: " $(date) 
for (( i=1; i<4; i++ )); do
    dwiDenoise.sh -o ${outDIRL[$i-1]} -s $SUFFIX
done
echo "END: " $(date) " ===============////====================="

##==============================================================================
echo "================== EDDY RUN NON BLIPPED ===================="
echo "START: " $(date)
for (( i=1; i<4; i++ )); do
    eddyRun_NOT_BLIPPED.sh -o ${outDIRL[$i-1]} -s $SUFFIX
done
echo "END: " $(date) " ===============////====================="

##==============================================================================
echo " ======= COMBINING PREPROCESSED DATA ======= "
echo "START: " $(date) 
combine_3_dwi.sh -oa $OUTDIR1 -ob $OUTDIR2 -oc $OUTDIR3 -o $workingDIR -s $SUFFIX
echo "END: " $(date) " ===============////====================="

##==============================================================================
mrtrixConversionAndProcessing.sh -o $workingDIR -s $SUFFIX

echo " ######## PROCESSING COMPLETE FOR TOPUP, EDDY, MRTRIX3 TRACTOGRAPHY PIPELINE ######## "

##==============================================================================

