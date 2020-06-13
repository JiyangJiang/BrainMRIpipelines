#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
EXTRACT BZERO FROM EDDY CORRECTED DWI
Inputs:    eddy_unwarped_images[suffix]*.nii.gz
Outputs:   nodif_eddy.nii.gz

COMPULSORY:
   -i        Input WORKING_DIR
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
        -i|--InputWORKING)
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
echo " ===== EXTRACTING BZERO FROM EDDY CORRECTED DIFFUSION DATA ===== "

fslroi "$INPUTWORKING"/eddy_unwarped_images"$INPUTSUFFIX"*.nii.gz \
       "$INPUTWORKING"/nodif_eddy \
       0 1

bet "$INPUTWORKING"/nodif_eddy \
    "$INPUTWORKING"/nodif_eddy_brain \
    -m \
    -f 0.2

mrconvert -force \
          "$INPUTWORKING"/nodif_eddy_brain_mask.nii.gz \
          "$INPUTWORKING"/mask.mif


