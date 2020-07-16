#!/bin/bash

## ======================== #
## jyj561@raijin.nci.org.au #
## ======================== #
##
## adjust ncpus to increase the number of running jobs
## be careful of filesystem quota limit
##

## =============================================
cmd_file="/data2/heidi/MAS_W124/MW1/MW1_FS_reconall.txt"
studyFolder="/data2/heidi/MAS_W124/MW1"
## =============================================

## delete IsRunning
rm -f ${studyFolder}/*/scripts/IsRunning.lh+rh

## in case matlab/R2012b is loaded
## unload it as using local R2012b runtime
# module unload matlab/R2012b

Ncmd=`wc -l ${cmd_file} | awk '{print $1}'`

for i in $(seq 1 ${Ncmd})
do
	## clear previous cmd_${i}.txt
	if [ -f "cmd_${i}.txt" ]; then
		rm -f cmd_${i}.txt*
	fi

	##Project ID
	echo "#PBS -P ba64" > cmd_${i}.txt

	##Queue type
	echo "#PBS -q normal" >> cmd_${i}.txt

	##Wall time
	## recon-all -all will take 20-40 hours
	## recon-all -hippocampal-subfields-T1 will take ~50 min on top of recon-all -all
	echo "#PBS -l walltime=40:00:00" >> cmd_${i}.txt

	##Number of CPU cores
	echo "#PBS -l ncpus=1" >> cmd_${i}.txt

	##requested memory per node
	echo "#PBS -l mem=8GB" >> cmd_${i}.txt

	##Disk space
	echo "#PBS -l jobfs=2GB" >> cmd_${i}.txt

	##Job is excuted from current working dir instead of home
	echo "#PBS -l wd" >> cmd_${i}.txt

	##Send email when begin, abort, end
	# echo "#PBS -M jiyang.jiang@unsw.edu.au" >> cmd_${i}.txt
	# echo "#PBS -m abe" >> cmd_${i}.txt

	## use NCI's freesurfer/6.0.0
	echo "module load freesurfer/6.0.0" >> cmd_${i}.txt
	echo "source \$FREESURFER_HOME/SetUpFreeSurfer.sh" >> cmd_${i}.txt
	echo "source \$FREESURFER_HOME/FreeSurferEnv.sh" >> cmd_${i}.txt

	# ## use local FreeSurfer 6.0.0
	# echo "export FREESURFER_HOME=/short/ba64/jyj561/freesurfer" >> cmd_${i}.txt
	# echo "source \$FREESURFER_HOME/SetUpFreeSurfer.sh" >> cmd_${i}.txt
	# echo "source \$FREESURFER_HOME/FreeSurferEnv.sh" >> cmd_${i}.txt
	
	## load MATLAB - used R2012b runtime in calculating hippocampal subfields
	## not needed now as installed R2012b runtime in local freesurfer folder
	# echo "module load matlab/R2012b" >> cmd_${i}.txt
	# echo "ln -s /apps/matlab/R2012b \$FREESURFER_HOME/MCRv80" >> cmd_${i}.txt

	## SUBJECTS_DIR
	echo "export SUBJECTS_DIR=${studyFolder}" >> cmd_${i}.txt

	## FS command
	awk NR==${i} ${cmd_file} >> cmd_${i}.txt

	qsub cmd_${i}.txt
done

