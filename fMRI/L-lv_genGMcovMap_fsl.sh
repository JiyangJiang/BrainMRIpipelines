#!/bin/bash

# call feat_gm_prepare
#
# https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/tutorial_packages/OSX/fsl_501/bin/feat_gm_prepare
#
#
# USAGE:
#
# cohortFolder=$1
# cleanup_mode=$2
# iso_resample_scale=$3
# additional_smoothing_fwhm=$4
# qsub_flag=$5


feat_gm_prepare_func(){

OUT=`${FSLDIR}/bin/remove_ext $1`
/bin/rm -rf ${OUT}.log
mkdir -p ${OUT}.log

shift




# isotropic resample and additional smoothing (as recommended)
cat << EOF > ${OUT}.log/isoresample
#!/bin/bash

#$ -N gmMap_isoresample
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q short.q
#$ -l h_vmem=8G
#$ -o ${OUT}.log/isoresample.out
#$ -e ${OUT}.log/isoresample.err

module load fsl/5.0.11

echo 1 0 0 0 > ${OUT}.log/eye.mat
echo 0 1 0 0 >> ${OUT}.log/eye.mat
echo 0 0 1 0 >> ${OUT}.log/eye.mat
echo 0 0 0 1 >> ${OUT}.log/eye.mat

# isotropic resampling
flirt -in $OUT -ref $OUT -applyisoxfm $1 -init ${OUT}.log/eye.mat -out ${OUT}_${1}mm

# additional smoothing as suggested.
# Ref on smoothing with fslmaths : https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;54608a1b.1111
smooth_scale=$(echo "scale=4; ${2} / 2.3548" | bc)
fslmaths ${OUT}_${1}mm -s \${smooth_scale} ${OUT}_${1}mm
EOF

shift 2





# estimate how much we will need to smooth the structurals by, in the end
# echo Estimating smoothness of functional data...
func_smoothing=`grep "fmri(smooth)" $1/design.fsf | tail -n 1 | awk '{print $3}'`
standard_space_resolution=`${FSLDIR}/bin/fslval $1/reg/standard pixdim1`
struc_smoothing=`${FSLDIR}/bin/match_smoothing $1/example_func $func_smoothing $1/reg/highres $standard_space_resolution`
# echo Structural-space GM PVE images will be smoothed by sigma=${struc_smoothing}mm to match the standard-space functional data

# run segmentations, smoothing, and standard-space transformation
CWD=`pwd`
for f in $@ ; do
  ${FSLDIR}/bin/fslecho "cd ${f}/reg; $FSLDIR/bin/fast -R 0.3 -H 0.1 -o grot highres; $FSLDIR/bin/immv grot_pve_1 highresGM; /bin/rm grot*; $FSLDIR/bin/fslmaths highresGM -s $struc_smoothing highresGMs; \c" >> ${OUT}.log/featseg1
  if [ `${FSLDIR}/bin/imtest ${f}/reg/highres2standard_warp` = 1 ] ; then
      ${FSLDIR}/bin/fslecho "${FSLDIR}/bin/applywarp --ref=standard --in=highresGMs --out=highresGMs2standard --warp=highres2standard_warp; \c" >> ${OUT}.log/featseg1
  else
      ${FSLDIR}/bin/fslecho "${FSLDIR}/bin/flirt -in highresGMs -out highresGMs2standard -ref standard -applyxfm -init highres2standard.mat; \c" >> ${OUT}.log/featseg1
  fi 
  echo "cd $CWD" >> ${OUT}.log/featseg1
  GMlist="$GMlist ${f}/reg/highresGMs2standard"
done
chmod a+x ${OUT}.log/featseg1
# echo Running segmentations...
# featseg1_id=`$FSLDIR/bin/fsl_sub -T 30 -N featseg1 -l ./${OUT}.log -t ./${OUT}.log/featseg1`



# concatenate and de-mean GM images
echo "${FSLDIR}/bin/fslmerge -t $OUT $GMlist; ${FSLDIR}/bin/fslmaths $OUT -Tmean -mul -1 -add $OUT $OUT" > ${OUT}.log/featseg2
# echo Running concatenation of all standard space GM images
# $FSLDIR/bin/fsl_sub -T 10 -N featseg2 -l ./${OUT}.log -j $featseg1_id -t ./${OUT}.log/featseg2 > /dev/null


# echo "Once this is all complete you may want to add additional smoothing to $OUT in order to ameliorate possible effects of mis-registrations between functional and structural data, and to lessen the effect of the additional confound regressors"
}









cohortFolder=$1
cleanup_mode=$2
iso_resample_scale=$3
additional_smoothing_fwhm=$4
qsub_flag=$5

case ${cleanup_mode} in
	fix)
		feat_gm_prepare_func ${cohortFolder}/confounds/GMcovMap/gmCovMap_fsl \
							 ${iso_resample_scale} \
							 ${additional_smoothing_fwhm} \
							 $(ls -1d ${cohortFolder}/*/*.ica | sort | tr '\n' ' ')
		;;
	aroma)
		feat_gm_prepare_func ${cohortFolder}/confounds/GMcovMap/gmCovMap_fsl \
							 ${iso_resample_scale} \
							 ${additional_smoothing_fwhm} \
							 $(ls -1d ${cohortFolder}/*/*.feat | sort | tr '\n' ' ')
		;;
esac

# submit jobs
if [ "${qsub_flag}" = "yesQsub" ]; then
	featseg1_id=`$FSLDIR/bin/fsl_sub -T 30 -N featseg1 -l ${cohortFolder}/confounds/GMcovMap/gmCovMap_fsl.log -t ${cohortFolder}/confounds/GMcovMap/gmCovMap_fsl.log/featseg1`
	featseg2_id=`$FSLDIR/bin/fsl_sub -T 10 -N featseg2 -l ${cohortFolder}/confounds/GMcovMap/gmCovMap_fsl.log -j $featseg1_id -t ${cohortFolder}/confounds/GMcovMap/gmCovMap_fsl.log/featseg2`
	isoresample_id=`qsub -hold_jid ${featseg2_id} ${cohortFolder}/confounds/GMcovMap/gmCovMap_fsl.log/isoresample`
fi











