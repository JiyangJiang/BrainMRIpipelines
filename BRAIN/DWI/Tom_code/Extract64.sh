#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
TODO ####

COMPULSORY:
   -o        Input WORKING_DIR
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
        -o|--InputWORKING)
            INPUTWORKING="$1"
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
if [ -z ${INPUTWORKING+x} ]; then
    echo " ERROR :  Input_working_directory is unset "
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
cd $INPUTWORKING

##==============================================================================
echo " ====== SPLITTING MAIN DIFFUSION DATASET INTO SEPARATE NII VOLUMES ====== "
echo
fslsplit dwi"$INPUTSUFFIX".nii
echo

##==============================================================================
echo " ====== DELETING ORIGINAL dwi.nii ====== "
echo
rm dwi"$INPUTSUFFIX".nii*
echo
sleep 5
echo

##==============================================================================
echo " ====== EXTRACTING 64 DIRECTIONS FROM MAIN DIFFUSION DATASET ====== "
echo
fslmerge -t dwi"$INPUTSUFFIX".nii vol0080.nii.gz vol0081.nii.gz vol0082.nii.gz vol0083.nii.gz vol0084.nii.gz vol0085.nii.gz vol0086.nii.gz vol0087.nii.gz vol0088.nii.gz vol0089.nii.gz vol0090.nii.gz vol0091.nii.gz vol0092.nii.gz vol0093.nii.gz vol0094.nii.gz vol0095.nii.gz vol0096.nii.gz vol0097.nii.gz vol0098.nii.gz vol0099.nii.gz vol0100.nii.gz vol0101.nii.gz vol0102.nii.gz vol0103.nii.gz vol0104.nii.gz vol0105.nii.gz vol0106.nii.gz vol0107.nii.gz vol0108.nii.gz vol0109.nii.gz vol0110.nii.gz vol0111.nii.gz vol0112.nii.gz vol0113.nii.gz vol0114.nii.gz vol0115.nii.gz vol0116.nii.gz vol0117.nii.gz vol0118.nii.gz vol0119.nii.gz vol0120.nii.gz vol0121.nii.gz vol0122.nii.gz vol0123.nii.gz vol0124.nii.gz vol0125.nii.gz vol0126.nii.gz vol0127.nii.gz vol0128.nii.gz vol0129.nii.gz vol0130.nii.gz vol0131.nii.gz vol0132.nii.gz vol0133.nii.gz vol0134.nii.gz vol0135.nii.gz vol0136.nii.gz vol0137.nii.gz vol0138.nii.gz vol0139.nii.gz vol0140.nii.gz vol0141.nii.gz vol0142.nii.gz vol0143.nii.gz vol0144.nii.gz vol0145.nii.gz vol0146.nii.gz vol0147.nii.gz 
echo
echo

##==============================================================================
echo " ====== DELETING SEPARATE INDIVIDUAL VOLUMES ====== "
echo
rm vol*.nii.gz
echo
sleep 5

##==============================================================================
echo " ====== EXTRACTING 64 BVEC FROM MAIN DIFFUSION DATASET BVEC ====== "
echo
cut -d' ' -f81-148 bvec"$INPUTSUFFIX".bvec > bvec"$INPUTSUFFIX"_64.txt
echo

##==============================================================================
echo " ====== EXTRACTING 64 BVAL FROM MAIN DIFFUSION DATASET BVAL ====== "
echo
cut -d' ' -f1-68 bval"$INPUTSUFFIX".bval > bval"$INPUTSUFFIX"_64.txt
echo
echo

##==============================================================================
echo " ====== DELETING ORIGINAL BVEC AND BVAL ====== "
echo
rm bvec"$INPUTSUFFIX".bvec
rm bval"$INPUTSUFFIX".bval
echo

cd "$currentDIR"



