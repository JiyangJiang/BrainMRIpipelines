#!/bin/bash

# DESCRIPTION
# ============================================================================
#
# This script excludes unreliable components from IC map derived from meta-
# ICA. Unreliable components are defined as spatial correlation with ICs from
# all individual ICA smaller being than 0.6.
#
#
# USAGE
# ============================================================================
#
# $1 = path to cohort folder.
#
# $2 = number of individual ICAs carried out.
#
# $3 = dimensionality of individual ICAs.
#
# $4 = dimensionality of meta ICA.
#
# $5 = 'yesQsub' or 'noQsub'
#
#
# REFERENCE
# ============================================================================
#
# Julia Schumacher, et al., 2017. "Functional connectivity in dementia with
# Lewy bodies: a within- and between-network analysis"
#

cohortFolder=$1
N_indICA=$2
N_dim_indICA=$3
N_dim_metaICA=$4
qsub_flag=$5

curr_dir=$(dirname $(which $0))


[ -f "${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.1" ] && \
	rm -f ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.1

[ -f "${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.2" ] && \
	rm -f ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.2

[ -f "${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.3" ] && \
	rm -f ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.3

[ -f "${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.4.sge" ] && \
	rm -f ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.4.sge



for i in `ls -d ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_*`
do
	mkdir -p ${i}/metaICA/excludeNoiseComponentsFromMetaICs/thresholded_ICmapFromIndICA
	mkdir -p ${i}/metaICA/excludeNoiseComponentsFromMetaICs/thresholded_ICmapFromMetaICA

	ICmap_metaICA="${i}/metaICA/d${N_dim_metaICA}/melodic_IC.nii.gz"


	for j in $(seq 1 ${N_indICA})
	do
		ICmap_indICA="${i}/metaICA/melodicIC_from_indICA/ICA_${j}_d${N_dim_indICA}_melodicIC.nii.gz"


		# threshold IC maps from individual ICA (z threshold > 3.2)
		cat << EOF >> ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.1
fslmaths ${ICmap_indICA} -thr 3.2 ${i}/metaICA/excludeNoiseComponentsFromMetaICs/thresholded_ICmapFromIndICA/ICA_${j}_d${N_dim_indICA}_melodicIC_thr3p2
EOF

		# threshold IC maps from meta ICA (z threshold > 3.2)
		cat << EOF >> ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.2
fslmaths ${ICmap_metaICA} -thr 3.2 ${i}/metaICA/excludeNoiseComponentsFromMetaICs/thresholded_ICmapFromMetaICA/melodic_IC_thr3p2
EOF

		# spatial correlation between thresholded individual IC map and thresholded meta IC map
		cat << EOF >> ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.3
fslcc --noabs -p 4 -t .204 ${i}/metaICA/excludeNoiseComponentsFromMetaICs/thresholded_ICmapFromMetaICA/melodic_IC_thr3p2 ${i}/metaICA/excludeNoiseComponentsFromMetaICs/thresholded_ICmapFromIndICA/ICA_${j}_d${N_dim_indICA}_melodicIC_thr3p2 > ${i}/metaICA/excludeNoiseComponentsFromMetaICs/sptCorr_metaICd${N_dim_metaICA}_indIC${j}d${N_dim_indICA}.txt
EOF

	done



	
	cat << EOF >> ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.4.sge
#!/bin/bash

#$ -N excldNoiCompFromMetaICs_4
#$ -V
#$ -cwd
#$ -pe smp 2
#$ -q short.q
#$ -l h_vmem=16G
#$ -o ${cohortFolder}/SGE_commands/oe/excldNoiCompFromMetaICs_4.out
#$ -e ${cohortFolder}/SGE_commands/oe/excldNoiCompFromMetaICs_4.err

module load fsl/5.0.11
module load matlab/R2018a

# merge the spatial correlation results (txt) together, as here the correlation coefficient matters
# rather than which individual ICA
cat ${i}/metaICA/excludeNoiseComponentsFromMetaICs/sptCorr_metaICd${N_dim_metaICA}_indIC*d${N_dim_indICA}.txt \
	> ${i}/metaICA/excludeNoiseComponentsFromMetaICs/sptCorr_metaICd${N_dim_metaICA}_all${N_indICA}IndICd${N_dim_indICA}.txt

# find noise components index
matlab -nodisplay -nosplash -r "addpath ('${curr_dir}'); \
								H_lv_metaICA_identifyNoiseComp ('${i}/metaICA/excludeNoiseComponentsFromMetaICs/sptCorr_metaICd${N_dim_metaICA}_all${N_indICA}IndICd${N_dim_indICA}.txt',\
																'${N_dim_metaICA}');\
								exit"

# remove noise components
tmp_dir=\`mktemp -d\`

cp ${ICmap_metaICA} \${tmp_dir}/.
ICmap_metaICA_inTmpDir=\${tmp_dir}/melodic_IC.nii.gz

fslsplit \${ICmap_metaICA_inTmpDir} \
		 \${tmp_dir}/metaICmap_fslsplit_ \
		 -t

while read noi_idx
do
	# index in the txt file starting from 1
	noi_idx_fsl=\$(bc <<< "\${noi_idx} - 1")

	rm -f \${tmp_dir}/metaICmap_fslsplit_\$(printf "%04d" \${noi_idx_fsl}).nii.gz

	fslmerge -t ${i}/metaICA/d${N_dim_metaICA}/melodic_IC_noiseRemoved \${tmp_dir}/metaICmap_fslsplit_*.nii.gz

done < ${i}/metaICA/excludeNoiseComponentsFromMetaICs/sptCorr_metaICd${N_dim_metaICA}_all${N_indICA}IndICd${N_dim_indICA}_excldIDX_startFrom1.txt

rm -fr \${tmp_dir}
EOF

done

# submit jobs
if [ "${qsub_flag}" = "yesQsub" ]; then
	excldNoi_1_jid=$($FSLDIR/bin/fsl_sub -T 200 -q short.q -N excldNoiCompFromMetaICs_1 -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.1)
	excldNoi_2_jid=$($FSLDIR/bin/fsl_sub -T 200 -q short.q -N excldNoiCompFromMetaICs_2 -l ${cohortFolder}/SGE_commands/oe -j ${excldNoi_1_jid} -t ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.2)
	excldNoi_3_jid=$($FSLDIR/bin/fsl_sub -T 200 -q short.q -N excldNoiCompFromMetaICs_3 -l ${cohortFolder}/SGE_commands/oe -j ${excldNoi_2_jid} -t ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.3)

	# fsl_sub cannot work with scripts with multiple lines, therefore used traditional sge scripts and qsub
	excldNoi_4_jid=`echo $(qsub -hold_jid ${excldNoi_3_jid} ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.4.sge) | awk '{print $3}'`
	# excldNoi_4_jid=$($FSLDIR/bin/fsl_sub -T 200 -q short.q -N excldNoiCompFromMetaICs_4 -l ${cohortFolder}/SGE_commands/oe -j ${excldNoi_3_jid} -t ${cohortFolder}/SGE_commands/excldNoiCompFromMetaICs.fslsub.4)
fi