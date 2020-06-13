#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
GENERATE WHOLE BRAIN TRACTOGRAPHY BASED ON 10 THOUSAND STREAMLINES USING iFOD2 ALGORITHM
Inputs:    fod_wm_norm.mif, mask.mif
Outputs:   wholebrain_CSD_10k.tck

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
echo "====== GENERATING TRACTOGRAPHY BASED ON 10 THOUSAND STREAMLINES ====== "

tckgen -force \
       "$INPUTWORKING"/fod_wm_norm.mif \
       "$INPUTWORKING"/wholebrain_CSD_"$INPUTSUFFIX"_10k.tck \
       -seed_image "$INPUTWORKING"/mask.mif \
       -mask "$INPUTWORKING"/mask.mif \
       -select 10000





