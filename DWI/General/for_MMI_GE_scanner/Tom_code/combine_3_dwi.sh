#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
# COMBINE OUTPUT OF 3 EDDY-CORRECTED DWI DATASETS
# Inputs:  folders with eddy_corrected dwi, destination folder for combined eddy_corrected dwi, suffix
# Outputs: eddy_unwarped_images_[suffix].nii, bval_[SUFFIX].bval, rotated_bvec_[SUFFIX].bvec

COMPULSORY:
   -oa        Input DIR_NAME of FIRST DTI OUTPUT
   -ob        Input DIR_NAME of SECOND DTI OUTPUT
   -oc        Input DIR_NAME of THIRD DTI OUTPUT
   -o         WORKING DIR NAME
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
        -o|--workingDIR)
            workingDIR="$1"
            shift # past argument
            ;;
        -oa|--dirA)
            dirA="$1"
            shift # past argument
            ;;
        -ob|--dirB)
            dirB="$1"
            shift # past argument
            ;;
        -oc|--dirC)
            dirC="$1"
            shift # past argument
            ;;
        -s|--SUFFIX)
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
if [ -z ${dirA+x} ]; then
    echo " ERROR :  Input_first_dti_output_directory is unset "
    usage
    exit 1
fi
if [ -z ${dirB+x} ]; then
    echo " ERROR :  Input_second_dti_output_directory is unset "
    usage
    exit 1
fi
if [ -z ${dirC+x} ]; then
    echo " ERROR :  Input_third_dti_output_directory is unset "
    usage
    exit 1
fi
if [ -z ${workingDIR+x} ]; then
    echo " ERROR :  Input_combined_dti_output_directory is unset "
    usage
    exit 1
fi
if [ -z ${SUFFIX+x} ]; then
    echo " ERROR :  Input_subject_id is unset "
    usage
    exit 1
fi

##==============================================================================
# Begin processing
# Make new directory for combined output
mkdir -p $workingDIR

echo " ===== Combine eddy corrected dwi from all 3 dwi datasets ===== "
fslmerge -t $workingDIR/eddy_unwarped_images"$SUFFIX"_dwi $dirA/eddy_unwarped_images"$SUFFIX".nii.gz $dirB/eddy_unwarped_images"$SUFFIX".nii.gz $dirC/eddy_unwarped_images"$SUFFIX".nii.gz

echo " ===== Combine eddy corrected bvec from all 3 dwi datasets ===== "
rm $workingDIR/rotatedbvec_"$SUFFIX".txt
paste -d"\0" $dirA/rotatedbvec.* $dirB/rotatedbvec.* $dirC/rotatedbvec.* >> $workingDIR/rotatedbvec_"$SUFFIX".txt

echo " ===== Combine bval from all 3 dwi datasets ===== "
rm $workingDIR/mrtrixbval_"$SUFFIX".txt
paste $dirA/mrtrixbval.txt $dirB/mrtrixbval.txt $dirC/mrtrixbval.txt >> $workingDIR/mrtrixbval_"$SUFFIX".txt




