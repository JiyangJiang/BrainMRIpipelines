#!/bin/bash

# DESCRIPTION
# ====================================================================================================
#
# This script appends WM and CSF masks to the meta IC map. This may be necessary because when removing
# unreliable components (H-lv_metaICA_excludeNoiseComponentsFromMetaICs.sh) may cause the removal of
# noise components which are necessary in dual regression to account for noise as dual regression is
# essentially a multivariate regression analysis.
#
# This script is called by H-lv_metaICA_main.sh
#
# only works in SGE.
#
#
# USAGE
# ====================================================================================================
#
# $1 = path to cohort folder
#
# $2 = number of individual ICAs
#
# $3 = dimensionality of meta ICA
#
# $4 = isotropic resampling scale. This should be set consistently with previous scripts.
#
# $5 = 'yesQsub' or 'noQsub'
#
# ====================================================================================================

cohortFolder=$1
N_indICA=$2
N_dim_metaICA=$3
iso_resample_scale=$4
qsub_flag=$5

FUTUREdir=$(dirname $(dirname $(dirname $(dirname $(which $0)))))


cat << EOF > ${cohortFolder}/SGE_commands/appendWMCSFmask2metaICmap.1.sge
#!/bin/bash

#$ -N appendWMCSFmask2metaICmap_1
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q short.q
#$ -l h_vmem=8G
#$ -o ${cohortFolder}/SGE_commands/oe/appendWMCSFmask2metaICmap_1.out
#$ -e ${cohortFolder}/SGE_commands/oe/appendWMCSFmask2metaICmap_1.err

module load fsl/5.0.11

# resample MNI WM mask
fslmaths \${FSLDIR}/data/standard/tissuepriors/avg152T1_white.hdr \
		 -thrp 99.9 \
		 -bin \
		 -mul 5 \
		 ${cohortFolder}/groupICA/resampled_MNI/MNI_wm_99percent

flirt -in ${cohortFolder}/groupICA/resampled_MNI/MNI_wm_99percent \
	  -ref \${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz \
	  -applyisoxfm ${iso_resample_scale} \
	  -init ${FUTUREdir}/Atlas/MNI2MNI_4resample/MNI2MNI.mat \
	  -out ${cohortFolder}/groupICA/resampled_MNI/MNI_WM_99percent_${iso_resample_scale}mm

# resample MNI CSF mask
fslmaths \${FSLDIR}/data/standard/tissuepriors/avg152T1_csf.hdr \
		 -thrp 99.9 \
		 -bin \
		 -mul 5 \
		 ${cohortFolder}/groupICA/resampled_MNI/MNI_csf_99percent

flirt -in ${cohortFolder}/groupICA/resampled_MNI/MNI_csf_99percent \
	  -ref \${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz \
	  -applyisoxfm ${iso_resample_scale} \
	  -init ${FUTUREdir}/Atlas/MNI2MNI_4resample/MNI2MNI.mat \
	  -out ${cohortFolder}/groupICA/resampled_MNI/MNI_CSF_99percent_${iso_resample_scale}mm
EOF



	cat << EOF > ${cohortFolder}/SGE_commands/appendWMCSFmask2metaICmap.2.sge
#!/bin/bash

#$ -N appendWMCSFmask2metaICmap_2
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q short.q
#$ -l h_vmem=8G
#$ -o ${cohortFolder}/SGE_commands/oe/appendWMCSFmask2metaICmap_2.out
#$ -e ${cohortFolder}/SGE_commands/oe/appendWMCSFmask2metaICmap_2.err

module load fsl/5.0.11

for i in \`ls -d ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_*/metaICA/d${N_dim_metaICA}\`
do
	if [ -f "\${i}/melodic_IC_noiseRemoved.nii.gz" ]; then
		metaICmap=\${i}/melodic_IC_noiseRemoved
	else
		metaICmap=\${i}/melodic_IC
	fi
done
fslmerge -t \${metaICmap}_WMCSFappended \${metaICmap} ${cohortFolder}/groupICA/resampled_MNI/MNI_WM_99percent_${iso_resample_scale}mm ${cohortFolder}/groupICA/resampled_MNI/MNI_CSF_99percent_${iso_resample_scale}mm
EOF


# submit jobs
if [ "${qsub_flag}" = "yesQsub" ]; then
	appendWMCSF_1_jid=`echo $(qsub ${cohortFolder}/SGE_commands/appendWMCSFmask2metaICmap.1.sge) | awk '{print $3}'`
	# appendWMCSF_1_jid=$($FSLDIR/bin/fsl_sub -T 200 -q short.q -N appendWMCSF_1 -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/appendWMCSFmask2metaICmap.fslsub.1)
	appendWMCSF_2_jid=`echo $(qsub -hold_jid ${appendWMCSF_1_jid} ${cohortFolder}/SGE_commands/appendWMCSFmask2metaICmap.2.sge) | awk '{print $3}'`
fi