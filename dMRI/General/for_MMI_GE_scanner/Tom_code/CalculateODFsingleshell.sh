#!/bin/bash


# CREATE ODF FILES FOR MULTISHELL

# Inputs:    dwinii2mif[suffix].mif,wm.txt, gm.txt, csf.txt, mask.mif
# Outputs:   fod_wm.mif, gm.mif, csf.mif

##==============================================================================
usage()
{
cat << EOF
CREATE ODF FILES FOR SINGLE SHELL
Inputs:    Suffix & working directory containing:
            dwinii2mif[suffix].mif,wm.txt, gm.txt, csf.txt, mask.mif
Outputs:   fod_wm.mif, gm.mif, csf.mif

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
echo
cd "$INPUTWORKING"/

echo "REMOVING FIRST LINE OF THE WM RESPONSE FILE"

tail -n +2 "$INPUTWORKING"/wm.txt > "wm_64.tmp" && mv "$INPUTWORKING"/wm_64.tmp "$INPUTWORKING"/wm.txt

echo "CREATING ODF FILES"

dwi2fod -force csd "$INPUTWORKING"/dwinii2mif"$INPUTSUFFIX".mif "$INPUTWORKING"/wm.txt "$INPUTWORKING"/fod_wm.mif -mask "$INPUTWORKING"/mask.mif

echo



