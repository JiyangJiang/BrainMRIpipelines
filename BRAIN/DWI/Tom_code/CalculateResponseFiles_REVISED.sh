#!/bin/bash



##==============================================================================
usage()
{
cat << EOF
CREATE RESPONSE FILES
Inputs:    dwinii2mif.mif
Outputs:   wm.txt, gm.txt, csf.txt

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
echo " ===== CREATING RESPONSE FILES ===== "
# COMMAND BELOW USES THE DHOLLANDER OPTION WHICH DOES NOT REQUIRE YOU TO MANUALLY SPECIFY LMAX OR SHELL VALUES
dwi2response dhollander \
             "$INPUTWORKING"/dwinii2mif.mif \
             "$INPUTWORKING"/wm.txt \
             "$INPUTWORKING"/gm.txt \
             "$INPUTWORKING"/csf.txt \
             -force




