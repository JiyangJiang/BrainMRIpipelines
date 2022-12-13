#!/bin/bash

# DESCRIPTION
# ========================================================================
#
#
# USAGE
# ========================================================================
# $1 = clean up method ('aroma', or 'fix')
#
# $2 = cohort folder
#
# $3 = threshold (in units of mm and degrees)
#
# $4 = maxmum CPU cores to be used, or 'par_cluster'
#
# $5 = 'yesQsub' or 'noQsub'
#
# DEPENDENCIES
# ========================================================================
# This should be run after mcflirt (either through FEAT or MELODIC).

cleanup_mode=$1
cohortFolder=$2
threshold=$3
Ncpus=$4
qsub_flag=$5

curr_dir=$(dirname $(which $0))

if [ -f "${cohortFolder}/SGE_commands/rmExcessiveMotion.fslsub.1" ]; then
	rm -f ${cohortFolder}/SGE_commands/rmExcessiveMotion.fslsub.1
fi

# make dir cohortFolder/excessive_motion
mkdir -p ${cohortFolder}/excessive_motion

# call L_lv_remove_excessive_motion.m
re='^[0-9]+$'

while read studyFolder
do

	if [[ ${Ncpus} =~ $re ]]; then

		matlab -nodesktop -nosplash -r "addpath('${curr_dir}'); \
										L_lv_rmExcMotion_calcMeanRotTrans ('${cleanup_mode}', \
																		   '${studyFolder}', \
																		   '${threshold}');\
										exit" &

		[ $(jobs | wc -l) -gt ${Ncpus} ] && wait


	elif [ "${Ncpus}" = "par_cluster" ]; then

		cat << EOF >> ${cohortFolder}/SGE_commands/rmExcessiveMotion.fslsub.1
matlab -nodesktop -nosplash -r "addpath('${curr_dir}');L_lv_rmExcMotion_calcMeanRotTrans('${cleanup_mode}','${studyFolder}','${threshold}');exit"
EOF
	fi

done < ${cohortFolder}/studyFolder.list



if [[ ${Ncpus} =~ $re ]]; then
	
	wait

	# re-run Ini_genLists.sh to re-generate list files excluding subjects with
	# excessive motion
	${curr_dir}/Ini_genLists.sh ${cohortFolder} ${cleanup_mode}

elif [ "${Ncpus}" = "par_cluster" ]; then

	cat << EOF > ${cohortFolder}/SGE_commands/rmExcessiveMotion.fslsub.2
${curr_dir}/Ini_genLists.sh ${cohortFolder} ${cleanup_mode}
EOF
	if [ "${qsub_flag}" = "yesQsub" ]; then
		rmExcessiveMotion_1_jid=$($FSLDIR/bin/fsl_sub -T 100 -q short.q -N rmExcessiveMotion_1 -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/rmExcessiveMotion.fslsub.1)
		rmExcessiveMotion_2_jid=$($FSLDIR/bin/fsl_sub -T 100 -q short.q -N rmExcessiveMotion_2 -l ${cohortFolder}/SGE_commands/oe -j ${rmExcessiveMotion_1_jid} -t ${cohortFolder}/SGE_commands/rmExcessiveMotion.fslsub.2)
	fi
fi




