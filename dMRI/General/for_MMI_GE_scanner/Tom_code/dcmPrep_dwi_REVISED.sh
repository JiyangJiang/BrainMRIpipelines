#!/bin/bash


##==============================================================================
##
usage()
{
cat << EOF
DCM PREP FOR DIFFUSION [DWI] DATA

Inputs:  folder with dicoms, destination folder, suffix
Outputs: dwi[suffix].nii, bval[suffix].bval, bvec[suffix].bvec
COMPULSORY:
   -i        Input DIR_NAME of diffusion dicoms
   -o        Input DESTINATION directory name
   -s        Input SUBJECT_ID (suffix)
OPTIONS:
   -h      Show this message
EOF
}

##==============================================================================
##
OPTIND=1
while [[ $# > 0 ]]; do
    key="$1"
    shift
    case $key in
        -i|--InputDTI)
            INPUTDTI="$1"
            shift # past argument
            ;;
        -o|--InputDestination)
            INPUTDESTINATION="$1"
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
    echo " ERROR :  Input_main_dti_directory is unset "
    usage
    exit 1
fi
if [ -z ${INPUTDESTINATION+x} ]; then
    echo " ERROR :  Input_destination_directory is unset "
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
dcm2nii -m N -g N $INPUTDTI/*
if [ $? -eq 0 ]; then
    echo OK
else
    echo "dcm2nii FAIL for "$INPUTDTI
	exit 1
fi

echo " ====== CHANGING NIFTI NAME TO dwi[suffix].nii ====== "
mv $INPUTDTI/*.nii dwi"$INPUTSUFFIX".nii

echo " ====== RENAMING bval to bval[INPUTSUFFIX].bval and bvec to bvec[suffix].bvec ====== "
mv $INPUTDTI/*.bval bval"$INPUTSUFFIX".bval
mv $INPUTDTI/*.bvec bvec"$INPUTSUFFIX".bvec

mkdir -p $INPUTDESTINATION
mv $INPUTDTI/dwi"$INPUTSUFFIX".nii $INPUTDESTINATION
mv $INPUTDTI/bvec"$INPUTSUFFIX".bvec $INPUTDESTINATION
mv $INPUTDTI/bval"$INPUTSUFFIX".bval $INPUTDESTINATION

