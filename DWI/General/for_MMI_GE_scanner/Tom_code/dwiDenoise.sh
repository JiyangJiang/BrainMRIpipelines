#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
DWI DENOISING
Inputs:    Suffix and Working directory containing:
                dwi[suffix].nii
Outputs:   nodif_brain_mask, dwidenoised[suffix].nii

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

bet "$INPUTWORKING"/b0_blipup \
    "$INPUTWORKING"/nodif_brain \
    -m \
    -f 0.2


dwidenoise -force \
           -mask "$INPUTWORKING"/nodif_brain.nii* \
           "$INPUTWORKING"/dwi"$INPUTSUFFIX".nii* \
           "$INPUTWORKING"/dwidenoised"$INPUTSUFFIX".nii





