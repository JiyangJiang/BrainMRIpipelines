#!/bin/bash

# DESCRIPTION
# --------------------------------------------------------------------------------------------------
#
#
# USAGE
# --------------------------------------------------------------------------------------------------
# $1 = path to BIDS project folder.
#
# $2 = path to FreeSurfer annot file (either lh or rh, do not use ?h). For example :
#
#          /path/to/atlas/lh.myatlas.annot
#
#      special case : if using HCP-MMP1 atlas (lh.HCP-MMP1.annot and rh.HCP-MMP1.annot), 
#                     pass 'HCP-MMP1'. if using Desikan-Killiany atlas, pass ('Desikan').
#
# $3 = 'subq' or 'noSubq'. noSubq may be useful for job dependency, i.e. wait for other scipt to
#      finish to execute this one.
#
#
# NOTES AND REFERENCES
# --------------------------------------------------------------------------------------------------
# 1) This script needs to be called with full path, or by adding FUTURE/DWI/MRtrix3/Raijin to $PATH.
#

dist_jobs(){
	BIDS_folder=$1
	subjID=$2
	FSannot_path=$3
	subq_flag=$4


	nthreads=4


	cd ${BIDS_folder}/derivatives/mrtrix

	raijin_connectivity_cmd="raijin_cmds/connectivity/${subjID}_raijin_connectivity_cmd.txt"

	## Project ID
	echo "#PBS -P ba64" > ${raijin_connectivity_cmd}

	## Queue type
	echo "#PBS -q normal" >> ${raijin_connectivity_cmd}

	## Wall time
	echo "#PBS -l walltime=02:00:00" >> ${raijin_connectivity_cmd}

	## Number of CPU cores
	echo "#PBS -l ncpus=${nthreads}" >> ${raijin_connectivity_cmd}

	## requested memory per node
	echo "#PBS -l mem=16GB" >> ${raijin_connectivity_cmd}

	## Disk space
	echo "#PBS -l jobfs=2GB" >> ${raijin_connectivity_cmd}

	## Job is excuted from current working dir instead of home
	echo "#PBS -l wd" >> ${raijin_connectivity_cmd}

	## redirect output and error
	echo "#PBS -e ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/connectivity/oe/${subjID}.err" >> ${raijin_connectivity_cmd}
	echo "#PBS -o ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/connectivity/oe/${subjID}.out" >> ${raijin_connectivity_cmd}

	# use my local freesurfer
	# echo "module load freesurfer/6.0.0" >> ${raijin_connectivity_cmd}

	# create individual space atlas from FreeSurfer annot files
	echo "$(dirname $(which $0))/mrtrix_createIndSpcAtlas_BIDS_subj.sh ${BIDS_folder} \
																	   ${subjID} \
																	   ${FSannot_path} \
																	   yesMap2dwi" >> ${raijin_connectivity_cmd}

	# scale by the atlas region's volume
	case ${FSannot_path} in

		HCP-MMP1)
			FSannot="HCP-MMP1"
			;;
		Desikan)
			FSannot="Desikan"
			;;
		*)
			FSannot=$(basename ${FSannot_path} | awk -F '.' '{print $2}')
			;;
	esac

	echo "tck2connectome -symmetric \
					     -zero_diagonal \
					     -scale_invnodevol \
					     tck/${subjID}_sift_1mio.tck \
					     ${BIDS_folder}/derivatives/atlas/${FSannot}_dwiSpace/${subjID}_${FSannot}_dwiSpace.mif \
					     network/${subjID}_${FSannot}.csv \
					     -out_assignment network/${subjID}_${FSannot}_nodeAssignments4eachStreamline.csv \
					     -force" >> ${raijin_connectivity_cmd}

	# run after tractography and reconall
	# qsub -W depend=afterany:JOBNAME.${subjID}_mrtrix_tractography:JOBNAME.${subjID}_freesurfer_reconall \
	# 	 -N ${subjID}_mrtrix_connectivity \
	# 	 ${raijin_connectivity_cmd}
	case ${subq_flag} in
		subq)
			qsub -N ${subjID}_mrtrix_connectivity \
				 ${raijin_connectivity_cmd}
			;;
		noSubq)
			# not qsub, useful for job dependency
			;;
	esac
}



buildconn_main(){

	BIDS_folder=$1
	FSannot_path=$2
	subq_flag=$3

	cd ${BIDS_folder}/derivatives/mrtrix

	# if [ -d "${BIDS_folder}/derivatives/mrtrix/raijin_cmds/connectivity" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/connectivity
	# fi
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/network" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/network
	# fi

	mkdir -p ${BIDS_folder}/derivatives/mrtrix/network
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/connectivity/oe


	# +++++++++++++++++ #
	# Loop all subjects #
	# +++++++++++++++++ #
	if [ -d "orig_mif/part_xaa" ]; then
		for orig_mif in `ls orig_mif/part_x*/*.mif`
		do
			subjID=$(basename ${orig_mif} | awk -F '_' '{print $1}')

			dist_jobs ${BIDS_folder} ${subjID} ${FSannot_path} ${subq_flag}
		done
	else
		for orig_mif in `ls orig_mif/*.mif`
		do
			subjID=$(basename ${orig_mif} | awk -F '_' '{print $1}')

			dist_jobs ${BIDS_folder} ${subjID} ${FSannot_path} ${subq_flag}
		done
	fi
}

buildconn_main $1 $2 $3