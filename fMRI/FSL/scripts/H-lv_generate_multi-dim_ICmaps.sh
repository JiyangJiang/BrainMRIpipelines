#!/bin/bash

# DESCRIPTION
# =======================================================================================
#
# This script runs group ICA multiple times with different user-defined dimensionalities.
# This can be useful if you want to explore IC maps with different dimensionalities on
# cluster or local workstations.
#
#
# USAGE
# =======================================================================================
# 
# $1 : cohort folder that contains all study folders.
#
# $2 : 'genList' or 'noGenList'.
#
# $3 : lower level cleanup method - 'fix' or 'aroma'.
#
# $4 : number of different dimensionalities to be extracted.
#
# $5 : list of different dimensionalities with a coma (,) without space.
#
# $6 : processing mode - 'sin', 'par_Mcore', 'par_cluster'
#
# $7 : 'subq' or 'noSubq'. noSubq may be useful for job dependency, i.e. wait for other scipt to
#      finish to execute this one. Only affect if par_cluster
#
#
# DEPENDENCIES
# =======================================================================================
#
# This script calls H-lv_grpICA_dualReg_grpComp.sh with 'yesGrpICA' and 'noDualReg'
#

genMultiDimICs(){
	cohortFolder=$1
	genList_flag=$2
	cleanup_type=$3
	Ndim=$4
	dim_list=$5
	proc_mode=$6
	subq_flag=$7

	currdir=$(dirname $(which $0))

	if [ -d "${cohortFolder}/groupICA/par_cluster_cmds/generate_multi-dim_ICmaps" ]; then
		rm -fr ${cohortFolder}/groupICA/par_cluster_cmds/generate_multi-dim_ICmaps
	fi
	mkdir -p ${cohortFolder}/groupICA/par_cluster_cmds/generate_multi-dim_ICmaps/oe


	for i in $(seq 1 ${Ndim})
	do

		curr_dim=`echo ${dim_list} | cut -d ',' -f ${i}`

		case ${proc_mode} in

			sin)

				${currdir}/H-lv_grpICA_dualReg_grpComp.sh ${cohortFolder} \
														  ${genList_flag} \
														  ${cleanup_type} \
														  yesGrpICA \
														  noDualReg \
														  ${curr_dim}
				;;
				
			par_Mcore)

				${currdir}/H-lv_grpICA_dualReg_grpComp.sh ${cohortFolder} \
														  ${genList_flag} \
														  ${cleanup_type} \
														  yesGrpICA \
														  noDualReg \
														  ${curr_dim} \
														  &

				# check operating system, and use the largest
				# number of cpu cores.
				unameOut="$(uname -s)"
				case "${unameOut}" in
				    Linux*)
						machine=Linux
						# at most number of CPU cores
						[ $(jobs | wc -l) -ge $(python -c "print ($(nproc)/2)") ] && wait
						;;

				    Darwin*)
						machine=Mac
						# at most number of CPU cores
						[ $(jobs | wc -l) -ge $(python -c "print ($(sysctl -n hw.physicalcpu)/2)") ] && wait
						;;

				    CYGWIN*)    machine=Cygwin;;
				    MINGW*)     machine=MinGw;;
				    *)          machine="UNKNOWN:${unameOut}"
				esac
				# echo ${machine}
				;; 

			par_cluster)

				grpICA_sge_cmd=${cohortFolder}/groupICA/par_cluster_cmds/generate_multi-dim_ICmaps/groupICA_d${curr_dim}_SGE_cmd

				echo "#!/bin/bash" > ${grpICA_sge_cmd}
				echo "#$ -N groupICA_d${curr_dim}" >> ${grpICA_sge_cmd}
				echo "#$ -V" >> ${grpICA_sge_cmd}
				echo "#$ -cwd" >> ${grpICA_sge_cmd}
				echo "#$ -o ${cohortFolder}/groupICA/par_cluster_cmds/generate_multi-dim_ICmaps/oe/groupICA_d${curr_dim}_SGE_cmd.out" >> ${grpICA_sge_cmd}
				echo "#$ -e ${cohortFolder}/groupICA/par_cluster_cmds/generate_multi-dim_ICmaps/oe/groupICA_d${curr_dim}_SGE_cmd.err" >> ${grpICA_sge_cmd}

				echo "module load fsl/6.0.0" >> ${grpICA_sge_cmd}

				echo "${currdir}/H-lv_grpICA_dualReg_grpComp.sh ${cohortFolder} \
															    ${genList_flag} \
															    ${cleanup_type} \
															    yesGrpICA \
															    noDualReg \
															    ${curr_dim}" >> ${grpICA_sge_cmd}

				case ${subq_flag} in
					subq)
						qsub ${grpICA_sge_cmd}
						;;
					noSubq)
						# not qsub
						;;
				esac
				;;
		esac


	done



}

genMultiDimICs $1 $2 $3 $4 $5 $6