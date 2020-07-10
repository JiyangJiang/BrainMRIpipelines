#!/bin/bash

# DESCRIPTION
# ===========================================================================================
# 
# Generate 24 motion parameters (including temporal derivatives) based on 6 motion parameters
# from mcflirt. This can be used for lower-level nuisance regression to regress out motion
# effects from preprocessed fMRI data.
#
# USAGE
# ===========================================================================================
#
# $1 = path to cohort folder
#
# $2 = lower level clean-up mode, 'aroma' or 'fix'
#
# $3 = 'par_cluster' if running on cluster, or the number
#      of CPU cores to use if running on workstation.
#      Note that 'par_cluster' will only generate sge script
#      without qsub.
#
# ===========================================================================================


gen24param(){
	${fMRI_dir}/Other/fmri_other_mpdiffpow24.sh ${mcflirt_param} \
												$(dirname ${mcflirt_param})/24motion_param

	cp $(dirname ${mcflirt_param})/24motion_param.dat \
		${cohortFolder}/confounds/motion_params/${subjID}.24motion.params
}


cohortFolder=$1
cleanup_mode=$2
Ncpus=$3

fMRI_dir=$(dirname $(dirname $(dirname $(which $0))))

while read studyFolder
do

	subjID=$(basename ${studyFolder})

	case ${cleanup_mode} in

		aroma)

			mcflirt_param=${studyFolder}/${subjID}_func.feat/mc/prefiltered_func_data_mcf.par

			;;

		fix)

			mcflirt_param=${studyFolder}/${subjID}_func.ica/mc/prefiltered_func_data_mcf.par

			;;

	esac

	re='^[0-9]+$'

	if [[ ${Ncpus} =~ $re ]]; then

		gen24param ${fMRI_dir} \
				   ${mcflirt_param} \
				   ${cohortFolder} \
				   ${subjID} \
				   &

		[ $(jobs | wc -l) -gt ${Ncpus} ] && wait
	
	elif [ "${Ncpus}" = "par_cluster" ]; then

			cat << EOF > ${cohortFolder}/SGE_commands/${subjID}_L-lv_gen24motionParam.sge
#!/bin/bash

#$ -N sub${subjID}_gen24motionParam
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q standard.q
#$ -l h_vmem=4G
#$ -o ${cohortFolder}/SGE_commands/oe/${subjID}_gen24motionParam.out
#$ -e ${cohortFolder}/SGE_commands/oe/${subjID}_gen24motionParam.err

${fMRI_dir}/Other/fmri_other_mpdiffpow24.sh ${mcflirt_param} $(dirname ${mcflirt_param})/24motion_param

cp $(dirname ${mcflirt_param})/24motion_param.dat ${cohortFolder}/confounds/motion_params/${subjID}.24motion.params
EOF
	fi

done < ${cohortFolder}/studyFolder.list

wait