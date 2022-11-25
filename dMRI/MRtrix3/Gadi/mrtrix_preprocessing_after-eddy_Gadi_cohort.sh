# # mrconvert nii.gz to mif
	# rotated_bvec=${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${subjID}_eddy/eddy/eddy_corrected.eddy_rotated_bvecs
	# eddyCorr_dwi=${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${subjID}_eddy/eddy/eddy_corrected.nii.gz
	# orig_bval=${bval}
	# echo "mrconvert -force \
	# 				-fslgrad ${rotated_bvec} ${orig_bval} \
	# 				${eddyCorr_dwi} \
	# 				${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${unr_mif_filename}_preproc.mif" >> ${preproc_cmd}

	# # ++++++++++++++++++++++++++++++ #
	# # Step 4 : Bias field correction #
	# # ++++++++++++++++++++++++++++++ #
	# preproc_mif=${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${unr_mif_filename}_preproc.mif
	# preproc_mif_filename=${unr_mif_filename}_preproc
	# echo "dwibiascorrect -force \
	# 					 -ants \
	# 					 ${preproc_mif} \
	# 					 ${BIDS_folder}/derivatives/mrtrix/biascorrect/${basedir}/${preproc_mif_filename}_unbiased.mif \
	# 					 -bias ${BIDS_folder}/derivatives/mrtrix/biascorrect/${basedir}/${preproc_mif_filename}_bias.mif " >> ${preproc_cmd}

	# # ++++++++++++++++++++++++++ #
	# # Step 5 : Generate DWI mask #
	# # ++++++++++++++++++++++++++ #
	# unbiased_mif=${BIDS_folder}/derivatives/mrtrix/biascorrect/${basedir}/${preproc_mif_filename}_unbiased.mif
	# unbiased_mif_filename=${preproc_mif_filename}_unbiased
	# echo "dwi2mask -force \
	# 			   ${unbiased_mif} \
	# 			   ${BIDS_folder}/derivatives/mrtrix/dwi_mask/${basedir}/${unbiased_mif_filename}_mask.mif" >> ${preproc_cmd}
