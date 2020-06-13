#!/bin/bash

# -----------------
# passing arguments
currdir=$(dirname $0)

cleanup_mode=$1
studyFolder=$2
epi_filename=$3
Hpass_thr=$4

case ${cleanup_mode} in

	fix)
		fixdir=$5
		Tdata=$6
		fix_thr=$7
		;;

	aroma)
		ICA_AROMA_path=$5
		;;

esac

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~


case ${cleanup_mode} in



# ======================
# Option 1 : FIX cleanup
# ======================

fix)

	echo "FIX cleanup selected."
		# fsf="/home/jiyang/Dropbox/Jiyang/CNSP/FUTURE/fMRI_processing/FSL/template_fsf/MELODIC_preproc_fsf/preproc_MELODIC.fsf"
		# =================================== #
		# info about this MELODIC_preproc.fsf #
		# =================================== #
		# - default output from MELODIC GUI
		# =================================== #



	echo "Performing FIX cleanup ..."

	# Run FIX cleanup
	${currdir}/L-lv_fsl_fix_cleanup.sh --ica ${studyFolder}/${epi_filename}.ica \
	                                   --fixdir ${fixdir} \
	                                   --Tdata ${Tdata} \
	                                   --thr ${fix_thr} \
	                                   --Hpass ${Hpass_thr}


	;;


# ====================
# Option 2 : ICA-AROMA
# ====================

aroma)

	echo "ICA-AROMA cleanup selected."
	echo "Note that 1) MELODIC is NOT supposed to be run before ICA-AROMA. ICA-AROMA will run MELODIC automatically."
	echo "          2) Temporal filtering should also be run after ICA-AROMA."


	echo "Performing ICA-AROMA cleanup ..."

	# Make appropriate brain mask on example_func (middle-timepoint fMRI img)
	bet ${studyFolder}/${epi_filename}.feat/example_func \
		${studyFolder}/${epi_filename}.feat/mask_aroma \
		-f 0.3 \
		-n \
		-m \
		-R


	# run ICA_AROMA.py with existing .feat folder (feat mode; overwrite existing)
	python2.7 ${ICA_AROMA_path}/ICA_AROMA.py -feat ${studyFolder}/${epi_filename}.feat \
	                                         -out ${studyFolder}/${epi_filename}.feat/ICA_AROMA/ \
	                                         -m ${studyFolder}/${epi_filename}.feat/mask_aroma.nii.gz \
	                                         -overwrite


	;;


*)
	echo "ERROR : unknown cleanup_mode ${cleanup_mode}"
	exit 1
	;;

# ----------------------- #
# End of Step 2 - Cleanup #
# ----------------------- #
esac

