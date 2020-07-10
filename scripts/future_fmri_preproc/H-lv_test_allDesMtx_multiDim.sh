#!/bin/bash

# DESCRIPTION
# ===============================================================
# This script runs all design matrices (and contrasts) in
# groupICA/des_mtx folder with different ICA results (i.e. different 
# dimensionalities. This is useful if you explore many
# hypotheses.
#
# Difference from H-lv_grpICA_dualReg_grpComp.sh : This script
# will always run dual regression. Otherwise, there is no point
# looping all design matrices.
#
# ========================   USAGE   ============================
#
# $1 : cohort folder that contains all study folders.
#
# $2 : 'genList' or 'noGenList'.
#
# $3 : lower level cleanup method - 'fix' or 'aroma'.
#
# $4 : 'yesGrpICA' or 'noGrpICA'. whether implement group ICA.
#
# $5 : Number of different dimensionalities.
#
# $6 : List of different dimensionalities.
#
# $7 : number of randomise permutations. set to 1 for just raw
#      tstat output. set to 0 to not run randomise at all.
#
# $8 : 'grp_mean' for group-mean (one-group t-test) modelling.
#      'grp_cmp' if testing other hypotheses. Only affecting
#      *randomise*.
#
# $9 : 'predef_20_rsns', 'predef_10_rsns', or 'grp_ICs'
#
# ${10} : sin, par_Mcore, or par_cluster
#
# ===============================================================

doAllDesMtx(){

	cohortFolder=$1
	genList_flag=$2
	cleanup_type=$3
	grpICA_flag=$4
	Ndim=$5
	dim_list=$6
	nperms=$7
	test=$8
	template=$9
	proc_mode=${10}


	currdir=$(dirname $(which $0))

	if [ -d "${cohortFolder}/groupICA/par_cluster_cmds/test_allDesMtx_multiDim" ]; then
		rm -fr ${cohortFolder}/groupICA/par_cluster_cmds/test_allDesMtx_multiDim
	fi
	mkdir -p ${cohortFolder}/groupICA/par_cluster_cmds/test_allDesMtx_multiDim/oe


	# if yesGrpICA
	if [ "${grpICA_flag}" = "yesGrpICA" ]; then
		${currdir}/H-lv_generate_multi-dim_ICmaps.sh ${cohortFolder} \
													 ${genList_flag} \
													 ${cleanup_type} \
													 ${Ndim} \
													 ${dim_list} \
													 ${proc_mode} \
													 noSubq
	fi

	# test all design matrices
	for j in $(seq 1 ${Ndim})
	do
		curr_dim=`echo ${dim_list} | cut -d ',' -f ${j}`

		if [ "${proc_mode}" = "par_cluster" ] && [ "${grpICA_flag}" = "yesGrpICA" ]; then
			grpICA_cmd=${cohortFolder}/groupICA/par_cluster_cmds/generate_multi-dim_ICmaps/groupICA_d${curr_dim}_SGE_cmd
			grpICA_jobid=`echo $(qsub ${grpICA_cmd}) | awk 'match($0,/[0-9]+/){print substr($0, RSTART, RLENGTH)}'`
		fi

		for i in `ls ${cohortFolder}/groupICA/des_mtx/*.mat`
		do
			des_mtx_basename=$(basename $i | awk -F '.' '{print $1}')

			case ${proc_mode} in

				sin)
					${currdir}/H-lv_grpICA_dualReg_grpComp.sh ${cohortFolder} \
															  ${genList_flag} \
															  ${cleanup_type} \
															  noGrpICA \
															  yesDualReg \
															  ${curr_dim} \
															  ${des_mtx_basename} \
															  ${nperms} \
															  ${test} \
															  ${template}
					;;

				par_Mcore)

					${currdir}/H-lv_grpICA_dualReg_grpComp.sh ${cohortFolder} \
															  ${genList_flag} \
															  ${cleanup_type} \
															  noGrpICA \
															  yesDualReg \
															  ${curr_dim} \
															  ${des_mtx_basename} \
															  ${nperms} \
															  ${test} \
															  ${template} \
															  &
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

					multiDesMtx_multiDim_sge_cmd=${cohortFolder}/groupICA/par_cluster_cmds/test_allDesMtx_multiDim/allDesMtx_d${curr_dim}_SGE_cmd

					echo "#!/bin/bash" > ${multiDesMtx_multiDim_sge_cmd}
					echo "#$ -N test_allDesMtx_d${curr_dim}" >> ${multiDesMtx_multiDim_sge_cmd}
					echo "#$ -V" >> ${multiDesMtx_multiDim_sge_cmd}
					echo "#$ -cwd" >> ${multiDesMtx_multiDim_sge_cmd}
					echo "#$ -o ${cohortFolder}/groupICA/par_cluster_cmds/test_allDesMtx_multiDim/oe/allDesMtx_d${curr_dim}_SGE_cmd.out" >> ${multiDesMtx_multiDim_sge_cmd}
					echo "#$ -e ${cohortFolder}/groupICA/par_cluster_cmds/test_allDesMtx_multiDim/oe/allDesMtx_d${curr_dim}_SGE_cmd.err" >> ${multiDesMtx_multiDim_sge_cmd}

					echo "module load fsl/6.0.0" >> ${multiDesMtx_multiDim_sge_cmd}

					echo "${currdir}/H-lv_grpICA_dualReg_grpComp.sh ${cohortFolder} \
																    ${genList_flag} \
																    ${cleanup_type} \
																    noGrpICA \
																    yesDualReg \
																    ${curr_dim} \
																    ${des_mtx_basename} \
																    ${nperms} \
																    ${test} \
																    ${template}" >> ${multiDesMtx_multiDim_sge_cmd}

					case ${grpICA_flag} in
						yesGrpICA)						
							qsub -hold_jid ${grpICA_jobid} ${multiDesMtx_multiDim_sge_cmd}
							;;
						noGrpICA)
							qsub ${multiDesMtx_multiDim_sge_cmd}
							;;
					esac
					;;
			esac

		done
	done

}

doAllDesMtx $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}