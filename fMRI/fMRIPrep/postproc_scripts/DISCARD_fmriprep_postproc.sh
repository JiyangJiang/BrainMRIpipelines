#!/bin/bash

# DESCRIPTION :
# ----------------------------------------------------------
# This script does :
#
#     1. nuisance regression
#     2. temporal filtering (high pass)
#
# which should be done after fmriprep processing
# ----------------------------------------------------------

Tdenoise(){

	inputImg=$1
	outputFolder=$2
	Hpass_thr=$3
	tr_val=$4

	$(dirname $(which $0))/fmriprep_postproc_Hpass.sh ${inputImg} \
													  ${outputFolder} \
													  ${Hpass_thr} \
													  tr \
													  ${tr_val}
}

Tdenoise $1 $2 $3 $4