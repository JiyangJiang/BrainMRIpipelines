#!/bin/bash



# ++++ LOG +++++
# - '-bin' to binarise mask

# ++++ ISSUE ++++
# - the ranges of z-scores (in template) and p-values (in results) 
#   are not the same. Will this affect fslmeants outcome 
#   (both average and eigenvariate)?




# +++++++++++++++++++ Change these parameters +++++++++++++++++++ #
cohortFolder=/data/jiyang/grp_cmp_lt80_over95_nondemented
template=/data/jiyang/grp_cmp_lt80_over95_nondemented/groupICA/metaICA/30indICAs_TueMay7150502AEST2019/metaICA/d30/melodic_IC.nii.gz
resultsFolder=/data/jiyang/grp_cmp_lt80_over95_nondemented/groupICA/conVScent_adjSEXandEDU_gmCovMap_fslOrder_d30_20000permutations_WMCSFappended

# ic ID starting from 0
ic_ID=1

# tstat ID (i.e. which contrast)
tstat_ID=2

zthr_template=4
pthr_result=0.98

# measure to extract (average or eigenvariate)
meas2ext=eigenvariate
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

mkdir -p ${resultsFolder}/coactivationWithPhenotype
# echo -n "removing previous results ...     "
# rm -fr ${resultsFolder}/coactivationWithPhenotype/*
# echo "done"

# extract corresponding IC
fslroi ${template} \
	   ${resultsFolder}/ic \
	   ${ic_ID} \
	   1

# threshold IC template (z values)
fslmaths ${resultsFolder}/ic \
		 -thr ${zthr_template} \
		 -bin \
		 ${resultsFolder}/ic_thr

# make masks for significant results
resultImg=${resultsFolder}/dr_stage3_ic$(zeropad ${ic_ID} 4)_tfce_corrp_tstat${tstat_ID}.nii.gz
fslmaths ${resultImg} \
		 -thr ${pthr_result} \
		 -bin \
		 ${resultsFolder}/result_thr

# extract corresponding IC template timeseries
[ -f "${cohortFolder}/SGE_commands/ext_templateIC_meants.fslsub" ] && \
	rm -f ${cohortFolder}/SGE_commands/ext_templateIC_meants.fslsub

[ -f "${cohortFolder}/SGE_commands/ext_resultMask_meants.fslsub" ] && \
	rm -f ${cohortFolder}/SGE_commands/ext_resultMask_meants.fslsub

[ -f "${cohortFolder}/SGE_commands/paste_ic_res_meants.fslsub" ] && \
	rm -f ${cohortFolder}/SGE_commands/paste_ic_res_meants.fslsub

while read preproc_epi
do
	subjID=$(basename $(dirname $(dirname $(dirname ${preproc_epi}))))

	case ${meas2ext} in

		average)

			echo "fslmeants -i ${preproc_epi} -o ${resultsFolder}/coactivationWithPhenotype/${subjID}_ic_meants.txt -m ${resultsFolder}/ic_thr" \
				>> ${cohortFolder}/SGE_commands/ext_templateIC_meants.fslsub

			echo "fslmeants -i ${preproc_epi} -o ${resultsFolder}/coactivationWithPhenotype/${subjID}_res_meants.txt -m ${resultsFolder}/result_thr" \
				>> ${cohortFolder}/SGE_commands/ext_resultMask_meants.fslsub

			;;

		eigenvariate)

			echo "fslmeants -i ${preproc_epi} -o ${resultsFolder}/coactivationWithPhenotype/${subjID}_ic_meants.txt -m ${resultsFolder}/ic_thr --eig" \
				>> ${cohortFolder}/SGE_commands/ext_templateIC_meants.fslsub

			echo "fslmeants -i ${preproc_epi} -o ${resultsFolder}/coactivationWithPhenotype/${subjID}_res_meants.txt -m ${resultsFolder}/result_thr --eig" \
				>> ${cohortFolder}/SGE_commands/ext_resultMask_meants.fslsub

			;;

	esac

	echo "paste ${resultsFolder}/coactivationWithPhenotype/${subjID}_ic_meants.txt ${resultsFolder}/coactivationWithPhenotype/${subjID}_res_meants.txt > ${resultsFolder}/coactivationWithPhenotype/${subjID}_ic_res_meants.txt" \
		>> ${cohortFolder}/SGE_commands/paste_ic_res_meants.fslsub

done < ${cohortFolder}/groupICA/input.list

jobID_1=$(fsl_sub -T 10 -N ext_templateIC_meants -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/ext_templateIC_meants.fslsub)
jobID_2=$(fsl_sub -T 10 -N ext_resultMask_meants -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/ext_resultMask_meants.fslsub)
jobID_3=$(fsl_sub -j ${jobID_1},${jobID_2} -T 5 -N paste_ic_res_meants -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/paste_ic_res_meants.fslsub)
