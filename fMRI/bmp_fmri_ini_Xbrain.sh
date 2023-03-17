#!/bin/bash

# ==========================================================================
# DESCRIPTION : This script is extracting brain from the original anat head
#               image. It is optimised for multicore workstations. Parallel
#               jobs are assigned to CPU cores automatically.
# ==========================================================================

# ==================================================================================
# USAGE : 
#        $1 : cohort folder
#        $2 : path to CNS
#        $3 : path to SPM12
#        $4 : running mode - 'par_Mcore' (parallel on multi-core workstation)
#                            'par_cluster' (parallel on cluster)
#                            'sin' (single)
#        $5 : 'overwrite' existing brain image or 'skip' the current subject if
#             existing brain image.
# ==================================================================================

usage (){

cat << EOF

DESCRIPTION :

  Extract brain from head image.

USAGE :

COMPULSORY :


OPTIONAL :

  -c, --cohort_folder    </path/to/cohort/folder>    Path to cohort folder that contains 
                                                     all the study folders. Each study folder 
                                                     has the folder name of subject ID, and 
                                                     contains a T1 and a fMRI scan for the
                                                     subject ID. Default is pwd.



EOF
}





cohortFolder=$1
SPM12_path=$2
running_mode=$3
overwrite_flag=$4


while read Sfolder
do

	case ${running_mode} in

		par_Mcore)
			
			f_xbrain ${Sfolder} \
					 $(basename "${Sfolder}")_anat \
					 ${SPM12_path} \
					 ${overwrite_flag} \
					 &
			;;

		par_cluster)

			$(dirname $(which $0))/bmp_fmri_ini_Xbrain_SGE.sh ${Sfolder} \
																												 $(basename "${Sfolder}")_anat \
																												 ${SPM12_path} \
																												 ${overwrite_flag} \
																												 ${cohortFolder}/SGE_commands/Xbrain_$(basename ${Sfolder}).sge

			;;

		sin)

			f_xbrain ${Sfolder} \
					 $(basename "${Sfolder}")_anat \
					 ${SPM12_path} \
					 ${overwrite_flag}
			;;

	esac

	case ${running_mode} in

		par_Mcore)
			
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

	esac
	
	
done < ${cohortFolder}/studyFolder.list

wait

Xbrain(){

	local SPM12_path=$1
	local anat=$2

	anat_folder=$(dirname ${anat})
	anat_filename=`echo $(basename ${anat}) | awk -F'.nii' '{print $1}'`
	anat_gz=`echo $(basename ${anat}) | awk -F'.nii' '{print $2}'`

	# if anat is gzip'ed
	[ "${anat_gz}" = ".gz" ] && \
		gunzip ${anat} && \
		anat="${anat_folder}/${anat_filename}.nii"

	# temp folder to contain intermediate output: c1/2/3, rc1/2/3, seg8mat
	if [ ! -d "${anat_folder}/temp" ]; then
		mkdir ${anat_folder}/temp
	fi

	matlab -nodisplay \
	   -nosplash \
	   -r \
	   "BMP_PATH = getenv ('BMP_PATH');\
	   	addpath ('${BMP_PATH}/fMRI');\
	    [c1,c2,c3,rc1,rc2,rc3,seg8mat] = bmp_fmri_ini_Xbrain_SPMsegment('${anat}','${SPM12_path}');\
	    bmp_fmri_ini_Xbrain_SPMnbtrN ('${anat}',c1,c2,c3,'${anat_folder}/${anat_filename}_brain');\
	    movefile (c1, '${anat_folder}/temp');\
	    movefile (c2, '${anat_folder}/temp');\
	    movefile (c3, '${anat_folder}/temp');\
	    movefile (rc1, '${anat_folder}/temp');\
	    movefile (rc2, '${anat_folder}/temp');\
	    movefile (rc3, '${anat_folder}/temp');\
	    movefile (seg8mat, '${anat_folder}/temp');\
	    exit"

}

f_xbrain(){
		local studyFolder=$1
		local anat_filename=$2
		local SPM12_path=$3
		local overwrite_f=$4

		anat=`ls ${studyFolder}/${anat_filename}.nii*`

		if [ -f "${studyFolder}/${anat_filename}_brain.nii.gz" ] \
			&& [ "${overwrite_f}" = "skip" ]; then

			echo
			echo "${anat_filename}_brain exists, skipping ..."
			echo
		
		elif [ -f "${studyFolder}/${anat_filename}_brain.nii.gz" ] \
			&& [ "${overwrite_f}" = "overwrite" ]; then

			echo
			echo "${anat_filename} exists, but overwriting ..."
			echo

			Xbrain ${SPM12_path} ${anat}

		elif [ ! -f "${studyFolder}/${anat_filename}_brain.nii.gz" ]; then

			echo
			echo "Non-brain tissue removal on ${anat_filename} ..."
			echo

			Xbrain ${SPM12_path} ${anat}

		fi
}	