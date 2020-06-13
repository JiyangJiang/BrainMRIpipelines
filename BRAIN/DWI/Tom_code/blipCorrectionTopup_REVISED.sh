#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
BLIP CORRECTION TOPUP

Inputs:    dwiflipped.nii, workingDirectory, suffix
Outputs:   acqparams.txt,  topup_b0_blips*

COMPULSORY:
   -f        name of dwiflipped.nii
   -o        name of working folder (has nii[suffix].nii etc)
   -s        suffix. dwi[suffix]FLIP.nii.gz
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
        -f|--InputDTIFLIPNII)
            niiF="$1"
            shift # past argument
            ;;
        -o|--OUTDIR)
            outputDIR="$1"
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
            echo "Unknown parameter " $key
            usage
            exit 1
            ;;
    esac
done


##==============================================================================
if [ -z ${niiF+x} ]; then
    echo " ERROR :  dwiflipped.nii is unset "
    usage
    exit 1
fi
if [ -z ${outputDIR+x} ]; then
    echo " ERROR :  outputDIR is unset "
    usage
    exit 1
fi
if [ -z ${suffix+x} ]; then
    echo " ERROR :  suffix is unset "
    usage
    exit 1
fi

if ! [ -d "$outputDIR" ] ; then
    echo  "*** ERROR *** working directory not found: " "$outputDIR"
    exit 1
fi

##==============================================================================
# Begin processing
if [[ "$niiF" == *.gz ]]; then
    niiFlipNAME="$outputDIR"/dwi"$suffix"FLIP.nii.gz
else
    niiFlipNAME="$outputDIR"/dwi"$suffix"FLIP.nii
fi
cp "$niiF" "$niiFlipNAME"


##==============================================================================
echo "=========EXTRACTING BZERO FROM MAIN AND FLIPPED DIFFUSION DATASET========="

# assuming the first volume is blipped b0 from blipped DTI
fslroi "$niiFlipNAME" "$outputDIR"/b0_blipdown 0 1

# Alternatively, to extract all bzero volumes:
# mrconvert dwi.nii -fslgrad bvec.bvec bval.bval dwinii2mif.mif
# dwiextract -bzero dwinii2mif.mif allbzero.mif
# mrconvert allbzero.mif b0_blipup.nii


echo "=========MERGING BZEROS FROM MAIN AND BLIPPED DATASETS========="
fslmerge -t "$outputDIR"/b0_bothblips "$outputDIR"/b0_blipup "$outputDIR"/b0_blipdown

echo "=========CREATING acqparams.txt FILE========="
echo "0 -1 0 0.11154" >"$outputDIR"/acqparams.txt
echo "0 1 0 0.11154" >>"$outputDIR"/acqparams.txt

echo "=========RUNNING TOPUP. THIS CAN TAKE A FEW MINUTES========="
topup --imain="$outputDIR"/b0_bothblips \
      --datain="$outputDIR"/acqparams.txt \
      --config=b02b0.cnf \
      --out="$outputDIR"/topup_b0_blips \
      --iout="$outputDIR"/my_iout \
      --fout="$outputDIR"/my_fout \
      --verbose


