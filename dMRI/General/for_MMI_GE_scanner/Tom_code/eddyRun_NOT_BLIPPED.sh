#!/bin/bash


##==============================================================================
usage()
{
cat << EOF
EDDY FOR NOT BLIPPED DATA
Inputs:    Suffix and Working directory containing:
                 acqparams.txt, dwidenoised[suffix].nii
Outputs:   index*.txt,  acqparams*, nodif_brain_mask, mrtrixbvec.txt, mrtrixbval.txt, dwinii2mifpreeddy.mif, eddy_unwarped_images*

COMPULSORY:
   -o        Input WORKING_DIR
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
        -o|--InputWORKING)
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
echo " ======= RUNNING BET AND CREATING MASK BASED ON BZERO FROM MAIN DIFFUSION DATASET ======= "
bet "$INPUTWORKING"/b0_blipup "$INPUTWORKING"/nodif_brain -m -f 0.2

echo
fslnvols "$INPUTWORKING"/dwidenoised"$INPUTSUFFIX".nii > "$INPUTWORKING"/nvols.txt
vols=$(fslnvols "$INPUTWORKING"/dwidenoised"$INPUTSUFFIX".nii)
echo
echo "THIS IS HOW MANY VOLUMES IN YOUR MAIN DATASET: $vols"
echo
##==============================================================================
echo " ======= CREATING index.txt FILE ======= "

indx=""
for ((i=1; i<=$vols; i+=1));do indx="$indx 1"; done
echo $indx > "$INPUTWORKING"/index$vols.txt

##==============================================================================
echo " ======= CREATING acqparams_$vols.txt FILE ======= "
echo

for ((i=0; i<vols; i++));
do printf "%s\n" "0 1 0 0.11154" >>"$INPUTWORKING"/acqparams_$vols.txt
done
echo

#BECAUSE ALL OF THE GE Multiband Multishell WIP DICOMS HAVE THE SAME VALUE ENTERED AS THE HIGHEST BVALUE ON THE CONSOLE
#NEED TO CREATE A BVAL FILE WITH THE CORRECT BVALUES. THIS IS DONE BY CONVERTING THE NII, BVAL AND BVEC FROM DCM2NII INTO MIF FORMAT
#AND THEN EXTRACTING THE CORRECT BVAL (AND BVEC) FROM THAT MIF FILE

##-ADDED BVECS FILE FROM TENSOR9.DAT-------------------
scriptDir=$(dirname $(which eddyRun_NOT_BLIPPED.sh))
case $vols in
	68)
	bvecs="$scriptDir/64_Directions.bvecs"
	#Note this file is cut from 147_Directions.bvecs
	;;
	130)
	bvecs="$scriptDir/129_Directions.bvecs"
	;;
	134)
	bvecs="$scriptDir/133_Directions.bvecs"
	;;
	148)
	bvecs="$scriptDir/147_Directions.bvecs"
	;;
esac
##-----------------------------------------------------

mrconvert -force "$INPUTWORKING"/dwidenoised"$INPUTSUFFIX".nii* -fslgrad $bvecs "$INPUTWORKING"/bval"$INPUTSUFFIX"*.* "$INPUTWORKING"/dwinii2mifpreeddy.mif
mrinfo -force "$INPUTWORKING"/dwinii2mifpreeddy.mif -export_grad_fsl "$INPUTWORKING"/mrtrixbvec.txt "$INPUTWORKING"/mrtrixbval.txt

##==============================================================================
echo " ======= RUNNING EDDY. NOTE THAT THIS CAN TAKE A LONG TIME ======= "
echo
eddy_openmp --imain="$INPUTWORKING"/dwidenoised"$INPUTSUFFIX" --mask="$INPUTWORKING"/nodif_brain_mask --index="$INPUTWORKING"/index$vols.txt --acqp="$INPUTWORKING"/acqparams_$vols.txt --bvecs="$INPUTWORKING"/mrtrixbvec.txt --bvals="$INPUTWORKING"/mrtrixbval.txt --fwhm=0 --flm=quadratic --out="$INPUTWORKING"/eddy_unwarped_images"$INPUTSUFFIX" --data_is_shelled --verbose
echo

##==============================================================================
echo " ======= RENAMING ROTATED BVEC ======= "
mv "$INPUTWORKING"/eddy_unwarped_images"$INPUTSUFFIX".eddy_rotated_bvecs "$INPUTWORKING"/rotatedbvec.txt
echo



