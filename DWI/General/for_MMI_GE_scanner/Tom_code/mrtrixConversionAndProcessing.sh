#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
mrtrixConversionAndProcessing.sh
 - Script to carry out:
     CONVERT COMBINED dwi, bvec and bval TO MRtrix mif FORMAT 
     EXTRACT BZERO AFTER EDDY, RUN BET ON THE EXTRACTED BZERO AND CREATE MASK 
     CREATE RESPONSE FILES 
     CREATE ODFs 
     GENERATE TRACTOGRAPHY FOR 10,000 STREAMLINES 
Inputs:  SUBJECT_ID (suffix)
         Folder for processing
Outputs: Build odf, test by running small (10K) streamlines

COMPULSORY:
   -o           working folder name
   -s           SUBJECT_ID (suffix)
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
        -s|--suffix)
            SUFFIX="$1"
            shift # past argument
            ;;
        -h|--help)
            usage
            exit 1
            ;;
        *)
            echo " ERROR - Unknown input: ", $key
            usage
            exit 1
            ;;
    esac
done

##==============================================================================
if [ -z ${workingDIR+x} ]; then
    echo " ERROR : workingDIR is unset "
    usage
    exit 1
fi
if [ -z ${SUFFIX+x} ]; then
    echo " ERROR : suffix is unset "
    usage
    exit 1
fi

##==============================================================================
### CHECK ALL INPUT ....
if ! [ -d "$workingDIR" ] ; then
    echo  "*** ERROR *** workingDIR not found: " "$workingDIR"
    exit 1
fi



# Begin processing
##==============================================================================
echo " ======= CONVERT dwi, bvec and bval TO MRtrix mif FORMAT ======= "
echo "START: " $(date) 

ConvertEddyDwiToMrtrix3Format_REVISED.sh -i $workingDIR -s $SUFFIX

echo "END: " $(date) " ===============////====================="

##==============================================================================
echo " ======= EXTRACT BZERO AFTER EDDY, RUN BET AND CREATE MASK ======= "
echo "START: " $(date) 

ExtractBzeroAfterEddy_REVISED.sh -i $workingDIR -s $SUFFIX

echo "END: " $(date) " ===============////====================="

##==============================================================================
echo " ======= CREATE RESPONSE FILES ======= "
echo "START: " $(date) 

CalculateResponseFiles_REVISED.sh -i $workingDIR -s $SUFFIX

echo "END: " $(date) " ===============////====================="

##==============================================================================
# CREATE ODFs
echo " ======= CREATE ODFs ======= "
echo "START: " $(date) 

CalculateODFmultishell_REVISED.sh -i $workingDIR -s $SUFFIX

echo "END: " $(date) " ===============////====================="

##==============================================================================
# MTNORMALISE
echo " ======= NORMALISE FODs ======= "
echo "START: " $(date) 

NormaliseFOD.sh -i $workingDIR

echo "END: " $(date) " ===============////====================="

##==============================================================================
# GENERATE TRACTOGRAPHY FOR 10,000 STREAMLINES
echo " ======= GENERATE TRACTOGRAPHY FOR 10,000 STREAMLINES ======= "
echo "START: " $(date) 

GenerateTractography_REVISED.sh -i $workingDIR -s $SUFFIX

echo "END: " $(date) " ===============////====================="


