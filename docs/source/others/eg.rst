Example code
============

T1 brain extraction with pnlpipe
--------------------------------

..  code-block::

	# t1w non-brain tissue removal (Ref : https://github.com/pnlbwh/pnlpipe-containers)
	# -----------------
	for_each -nthreads $nthr sub-* : \
	docker run --rm \
	-v /software/freesurfer/7.3.2/license.txt:/home/pnlbwh/freesurfer-7.1.0/license.txt \
	-v ${studyFolder}/IN:/home/pnlbwh/myData \
	-v /software/miscellaneous/pnlpipe/IITmean_b0_256.nii.gz:/home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder/IITmean_b0_256.nii.gz \
	tbillah/pnlpipe \
	"nifti_atlas -t /home/pnlbwh/myData/t1w.nii.gz -o /home/pnlbwh/myData/t1Mask --train /home/pnlbwh/pnlpipe/soft_dir/trainingDataT1AHCC-8141805/trainingDataT1Masks-hdr.csv" # skull stripping for T1w

Synthesise reverse PE B0 with synB0-DISCO (may need some modification for new version of synB0-DISCO)
-----------------------------------------------------------------------------------------------------

..  code-block::

	# synthesize reverse PE B0
	# -----------------
	echo "synB0-DISCO ..."
	cp /software/freesurfer/7.3.2/license.txt ./FreeSurfer_license.txt

	# from Json file : BandwidthPerPixelPhaseEncode: 15.674
	cat << EOT > acqparams.txt
	0 1 0 0.064
	0 1 0 0.00
	EOT

	for i in sub-*
	do
	[ -d 'INPUTS' ]  && rm -fr INPUTS
	[ -d 'OUTPUTS' ] && rm -fr OUTPUTS
	mkdir -p INPUTS OUTPUTS 
	cp $i/b0.nii.gz acqparams.txt INPUTS
	cp $i/t1w_brain.nii.gz INPUTS/T1.nii.gz
	docker run --rm \
	-v ${studyFolder}/INPUTS/:/INPUTS/ \
	-v ${studyFolder}/OUTPUTS/:/OUTPUTS/ \
	-v ${studyFolder}/FreeSurfer_license.txt:/extra/freesurfer/license.txt \
	--user $(id -u):$(id -g) \
	leonyichencai/synb0-disco \
	--stripped \
	--notopup							# Ref : https://github.com/MASILab/Synb0-DISCO
										#
										# 1) Synb0-DISCO requires INPUTS and OUTPUTS
										#    folder in the current directory.
										#
										# 2) not doing topup because the topup setting in
										#    synb0-DISCO generate field coeff maps
										#    that will cause eddy_cuda to fail.

	[ -d "$i/synB0discoOutput" ] && rm -fr $i/synB0discoOutput
	mv OUTPUTS $i/synB0discoOutput
	done
	rm -fr INPUTS OUTPUTS

	# topup
	# -----------------
	for_each -nthreads $nthr sub-* : fslmerge -t IN/synB0discoOutput/b0_all \
												IN/b0 \
												IN/synB0discoOutput/b0_u # b0_u is the synthesized undistorted b0.
																		 # Note here the original b0 is used.
																		 # In Synb0-DISCO topup, smoothed b0 is used,
																		 # ie., b0_d_smooth (line 63 of https://github.com/MASILab/Synb0-DISCO/blob/master/src/pipeline.sh).

	for_each -nthreads $nthr sub-* : topup 	--imain=IN/synB0discoOutput/b0_all \
											--datain=acqparams.txt \
											--config=$scriptFolder/dwi/b02b0_noSubsamp.cnf \
											--iout=IN/synB0discoOutput/b0_all_topup \
											--out=IN/synB0discoOutput/topup 	# Here b02b0.cnf is modified to not subsample
																				# because otherwise num of slices needs to be
																				# even.