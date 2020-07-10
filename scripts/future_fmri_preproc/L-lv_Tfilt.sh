#!/bin/bash

# $1 = path to cohort folder
# $2 = cleanup mode
# $3 = TR
# $4 = high pass threshold
# $5 = 'par_cluster' if running on cluster, or the number
#      of CPU cores to use if running on workstation.
#      Note that 'par_cluster' will only generate sge script
#      without qsub.


Tfilt(){

	cleanedup_func=$1
	postcleanup_folder=$2
	Hpass_thr_in_sec=$3
	tr=$4
	Tfiltered_output=$5
	cleanup_mode=$6


	# Get mean of denoised functional data (to be added to the residuals below)
	# -------------------------------------------------------------------------
	fslmaths ${cleanedup_func} \
			 -Tmean \
			 ${postcleanup_folder}/cleanedup_func_Tmean


	# apply highpass filter and add the Tmean back into data
	# ------------------------------------------------------

	fwhm=`python -c "print (${Hpass_thr_in_sec}/${tr})"`
	sigma=`python -c "print (${fwhm}/2)"`

	# FIX has done highpass, only AROMA needs highpass
	case ${cleanup_mode} in

		aroma)

			fslmaths ${cleanedup_func} \
					 -bptf ${sigma} -1 \
					 -add ${postcleanup_folder}/cleanedup_func_Tmean \
					 ${Tfiltered_output}
			;;

		fix)
			fslmaths ${cleanedup_func} \
					 ${Tfiltered_output}
			;;

	esac
}

cohortFolder=$1
cleanup_mode=$2
tr=$3
Hpass_thr_in_sec=$4
Ncpus=$5

while read studyFolder
do
	subjID=$(basename ${studyFolder})

	case ${cleanup_mode} in
		aroma)
			workingDir=${studyFolder}/${subjID}_func.feat
			cleanedup_func="${workingDir}/ICA_AROMA/denoised_func_data_nonaggr"
			postcleanup_folder=${workingDir}/post-ICA_AROMA
			;;
		fix)
			workingDir=${studyFolder}/${subjID}_func.ica
			# cleanedup_func="${workingDir}/filtered_func_data"
			# ---------------------------------------------------
			# 2019 May 27 : shouldn't the FIX-cleaned image being
			#               filtered_func_data_clean, instead of
			#               filtered_func_data.
			cleanedup_func="${workingDir}/filtered_func_data_clean"
			postcleanup_folder=${workingDir}/post-FIX
			;;
	esac

	Tfiltered_output="${postcleanup_folder}/Tfiltered_cleanedup_func"

	re='^[0-9]+$'

	if [[ ${Ncpus} =~ $re ]]; then

		Tfilt ${cleanedup_func} \
			  ${postcleanup_folder} \
			  ${Hpass_thr_in_sec} \
			  ${tr} \
			  ${Tfiltered_output} \
			  ${cleanup_mode} \
			  &

		[ $(jobs | wc -l) -gt ${Ncpus} ] && wait

	elif [ "${Ncpus}" = "par_cluster" ]; then

			cat << EOF > ${cohortFolder}/SGE_commands/${subjID}_L-lv_Tfilt.sge
#!/bin/bash

#$ -N sub${subjID}_Tfilt
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q standard.q
#$ -l h_vmem=4G
#$ -o ${cohortFolder}/SGE_commands/oe/${subjID}_Tfilt.out
#$ -e ${cohortFolder}/SGE_commands/oe/${subjID}_Tfilt.err

module load fsl/5.0.11

fslmaths ${cleanedup_func} \
		 -Tmean \
		 ${postcleanup_folder}/cleanedup_func_Tmean

fwhm=\`python -c "print (${Hpass_thr_in_sec}/${tr})"\`
sigma=\`python -c "print (\${fwhm}/2)"\`

case ${cleanup_mode} in

	aroma)

		fslmaths ${cleanedup_func} -bptf \${sigma} -1 -add ${postcleanup_folder}/cleanedup_func_Tmean ${Tfiltered_output}
		;;

	fix)
		fslmaths ${cleanedup_func} ${Tfiltered_output}
		;;

esac
EOF
	fi

done < ${cohortFolder}/studyFolder.list

wait