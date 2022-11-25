#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
setupDTI2Mrtrix.sh
 - Script to set up standard folder structure for DTI recon to MRTrix 
Inputs:  Folder for processing, SUFFIX, nifti, bvec and bval
Outputs: Build folder and copy nifti etc as dwi[suffix].nii(.gz), bval[SUFFIX].bval, bvec[SUFFIX].bvec

COMPULSORY:
   -o           Folder name
   -i           nii file name
   -bvec        bvec file name
   -bval        bval file name
   -s           Input SUBJECT_ID (suffix)
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
        -i|--niiIn)
            niiIN="$1"
            shift # past argument
            ;;
        -bvec|--bvecIN)
            bvecIN="$1"
            shift # past argument
            ;;
        -bval|--bvalIN)
            bvalIN="$1"
            shift # past argument
            ;;
        -s|--suffix)
            suffix="$1"
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
if [ -z ${niiIN+x} ]; then
    echo " ERROR : niiIN is unset "
    usage
    exit 1
fi
if [ -z ${bvecIN+x} ]; then
    echo " ERROR : bvecIN is unset "
    usage
    exit 1
fi
if [ -z ${bvalIN+x} ]; then
    echo " ERROR : bvalIN is unset "
    usage
    exit 1
fi
if [ -z ${suffix+x} ]; then
    echo " ERROR : suffix is unset "
    usage
    exit 1
fi
##==============================================================================
### CHECK ALL INPUT ....
if ! [ -f "$niiIN" ] ; then
    echo  "*** ERROR *** file not found: " "$niiIN"
    exit 1
fi
if ! [ -f "$bvecIN" ] ; then
    echo  "*** ERROR *** file not found: " "$bvecIN"
    exit 1
fi
if ! [ -f "$bvalIN" ] ; then
    echo  "*** ERROR *** file not found: " "$bvalIN"
    exit 1
fi

##==============================================================================
# Begin processing
# Make new directory for combined output

# mkdir -p: no error if existing, make parent directories as needed
mkdir -p $workingDIR

# checking if the last command had a zero exit status (meaning "successful")
if [ $? -ne 0 ]; then
    echo "*** ERROR *** creating  "$workingDIR
	exit 1
fi

# check if gzipped
if [[ "$niiIN" == *.gz ]]; then
    niiNAME="$workingDIR"/dwi"$suffix".nii.gz
else
    niiNAME="$workingDIR"/dwi"$suffix".nii
fi

cp "$niiIN" "$niiNAME"
if [ $? -ne 0 ]; then
    echo "*** ERROR *** copying to "$workingDIR
    exit 1
fi

cp $bvecIN $workingDIR/bvec"$suffix".bvec
if [ $? -ne 0 ]; then
    echo "*** ERROR *** copying to "$workingDIR
    exit 1
fi

cp $bvalIN $workingDIR/bval"$suffix".bval
if [ $? -ne 0 ]; then
    echo "*** ERROR *** copying to "$workingDIR
    exit 1
fi

# assuming the first volume of DTI nii is the b0_blipup
fslroi "$niiNAME" "$workingDIR"/b0_blipup 0 1





