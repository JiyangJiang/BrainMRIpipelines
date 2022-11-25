#!/bin/bash


usage()
{
cat << EOF
CONVERSION OF EDDY CORRECTED DWI TO MRTRIX3 FORMAT
Inputs:    eddy_unwarped_images*.nii.gz,rotatedbvec.bvec mrtrixbval*.txt 
Outputs:   dwinii2mif*.mif,  eddy_unwarped_images*.nii

COMPULSORY:
   -i        Input DIR_NAME of COMBINED DESTINATION
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
        -i|--InputCombined)
            INPUTCOMBINED="$1"
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
            echo " ERROR : Unknown key " $key
            usage
            exit 1
            ;;
    esac
done

##==============================================================================
if [ -z ${INPUTCOMBINED+x} ]; then
    echo " ERROR :  Input_combined_dti_output_directory is unset "
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
echo "CONVERTING EDDY CORRECTED NII INTO MIF FORMAT FOR USE IN MRtrix3"

mrconvert "$INPUTCOMBINED"/eddy_unwarped_images"$INPUTSUFFIX"*.nii.gz \
          -fslgrad "$INPUTCOMBINED"/rotatedbvec*.* "$INPUTCOMBINED"/mrtrixbval*.* \
          "$INPUTCOMBINED"/dwinii2mif.mif \
          -force


