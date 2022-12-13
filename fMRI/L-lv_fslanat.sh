#!/bin/bash

# $1 = path to cohort folder
#
# $2 = 'forceNoFSLanat' only use when fsl_anat has already
#      been run. Any non-empty string othewise.
#
# $3 = 'par_cluster' if running on cluster, or the number
#      of CPU cores to use if running on workstation.
#      Note that 'par_cluster' will only generate sge script
#      without qsub.

cohortFolder=$1
forceSkipFSLanat_flag=$2
Ncpus=$3

while read studyFolder
do

	subjID=$(basename ${studyFolder})
	anat=`ls ${studyFolder}/${subjID}_anat.nii*`
	fsl_anat_dir=${studyFolder}/${subjID}_anat.anat

	# fsl_anat
	if [ "${forceSkipFSLanat_flag}" = "forceNoFSLanat" ]; then
			echo "force skipping fsl_anat"
	else
		if [ -d "${fsl_anat_dir}" ]; then
			rm -fr ${fsl_anat_dir}
		fi

		re='^[0-9]+$'




		# if parallelise on SGE cluster
		if [ "${Ncpus}" = "par_cluster" ]; then



			cat << EOF > ${cohortFolder}/SGE_commands/${subjID}_L-lv_fslanat.sge
#!/bin/bash

#$ -N sub${subjID}_fslanat
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q standard.q
#$ -l h_vmem=4G
#$ -o ${cohortFolder}/SGE_commands/oe/${subjID}_fslanat.out
#$ -e ${cohortFolder}/SGE_commands/oe/${subjID}_fslanat.err

module load fsl/5.0.11

fsl_anat --nocrop -i ${anat}
EOF
			


		# if workstation with number of CPU cores specified.
		elif [[ ${Ncpus} =~ $re ]]; then
			# need to stop auto-cropping. Otherwise the dimension is changed
			# and the transformation matrices in "reg" folder will be unusable.
			fsl_anat --nocrop \
					 -i ${anat} \
					 &

			[ $(jobs | wc -l) -gt ${Ncpus} ] && wait
		fi
	fi

done < ${cohortFolder}/studyFolder.list

wait