#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
NORMALISE FODs
Inputs:    Suffix & working directory containing:
           fod_wm.mif 		csf.mif			gm.mif			mask.mif
Outputs:   fod_wm_norm.mif	csf_norm.mif	gm_norm.mif

COMPULSORY:
   -i        Input WORKING_DIR
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

##==============================================================================
# Begin processing
echo " ===== NORMALISING FOD FILES ===== "

# multi-tissue informed log-domain intensity normalisation
#
# Intensity normalisation is performed in the log-domain, and can smoothly
# vary spatially to accomodate the effects of (residual) intensity
# inhomogeneities
#
mtnormalise -force \
            "$INPUTWORKING"/fod_wm.mif \
            "$INPUTWORKING"/fod_wm_norm.mif \
            "$INPUTWORKING"/csf.mif \
            "$INPUTWORKING"/csf_norm.mif \
            -mask "$INPUTWORKING"/mask.mif







