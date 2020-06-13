#!/bin/bash

# command-line
# -------------------------------------------------------------------------------
# usage: fmriprep [-h] [--version] [--skip_bids_validation]
#                 [--participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
#                 [-t TASK_ID] [--echo-idx ECHO_IDX] [--nthreads NTHREADS]
#                 [--omp-nthreads OMP_NTHREADS] [--mem_mb MEM_MB] [--low-mem]
#                 [--use-plugin USE_PLUGIN] [--anat-only] [--boilerplate]
#                 [--ignore-aroma-denoising-errors] [-v] [--debug]
#                 [--ignore {fieldmaps,slicetiming,sbref} [{fieldmaps,slicetiming,sbref} ...]]
#                 [--longitudinal] [--t2s-coreg] [--bold2t1w-dof {6,9,12}]
#                 [--output-space {T1w,template,fsnative,fsaverage,fsaverage6,fsaverage5} [{T1w,template,fsnative,fsaverage,fsaverage6,fsaverage5} ...]]
#                 [--force-bbr] [--force-no-bbr]
#                 [--template {MNI152NLin2009cAsym}]
#                 [--output-grid-reference OUTPUT_GRID_REFERENCE]
#                 [--template-resampling-grid TEMPLATE_RESAMPLING_GRID]
#                 [--medial-surface-nan] [--use-aroma]
#                 [--aroma-melodic-dimensionality AROMA_MELODIC_DIMENSIONALITY]
#                 [--skull-strip-template {OASIS,NKI}]
#                 [--skull-strip-fixed-seed] [--fmap-bspline] [--fmap-no-demean]
#                 [--use-syn-sdc] [--force-syn] [--fs-license-file PATH]
#                 [--no-submm-recon] [--cifti-output | --fs-no-reconall]
#                 [-w WORK_DIR] [--resource-monitor] [--reports-only]
#                 [--run-uuid RUN_UUID] [--write-graph] [--stop-on-first-crash]
#                 [--notrack] [--sloppy]
#                 bids_dir output_dir {participant}


# docker wrapper
# -----------------------------------------------------------------------------
# usage: fmriprep-docker [-h] [--version] [-i IMG] [-w WORK_DIR]
#                        [--output-grid-reference OUTPUT_GRID_REFERENCE]
#                        [--template-resampling-grid TEMPLATE_RESAMPLING_GRID]
#                        [--fs-license-file PATH] [--use-plugin PATH] [-f PATH]
#                        [-n PATH] [-p PATH] [--shell] [--config PATH]
#                        [-e ENV_VAR value] [-u USER]
#                        [bids_dir] [output_dir] [{participant}]

bids_dir=/Users/jiyang/Desktop/fMRI_fMRIPrep+ICA/rawData_SCS/fmriprep_test
output_dir=/Users/jiyang/Desktop/fMRI_fMRIPrep+ICA/rawData_SCS/fmriprep_test/derivatives
fs_license=/Users/jiyang/Dropbox/Jiyang/CNSP/FUTURE/fMRI_processing/fMRIPrep/license.txt

# # Basic mode
# fmriprep-docker --image poldracklab/fmriprep:latest \
# 				--work-dir ${output_dir} \
# 				--template-resampling-grid native \
# 				--fs-license-file ${fs_license} \
# 				${bids_dir} \
# 				${output_dir} \
# 				participant

# adding more arguments
fmriprep-docker --image poldracklab/fmriprep:latest \
				--work-dir ${output_dir} \
				--template-resampling-grid native \
				--fs-license-file ${fs_license} \
				${bids_dir} \
				${output_dir} \
				participant \
				--task-id rest \
				--nthreads 2 \
				--omp-nthreads 1 \
				--mem_mb 8000 \
				--bold2t1w-dof 6 \
				--output-space T1w fsnative fsaverage fsaverage5 template \
				--template MNI152NLin2009cAsym \
				--template-resampling-grid native \
				--use-aroma \
				--skull-strip-template OASIS \
				--skull-strip-fixed-seed \
				--use-syn-sdc \
				--resource-monitor \
				--write-graph



## calling docker directly
# docker run -ti --rm \
# 	                   -v ${bids_dir}:/data:ro \
# 	                   -v ${output_dir}:/out \
# 	                   poldracklab/fmriprep:latest \
# 	                   /data \
# 	                   /out/ouot \
# 	                   participant \
# 	                   --ignore fieldmaps



# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                                  fMRIPrep detailed workflow
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# ******************************
# Anatomical image preprocessing
# ******************************
#
# 1. Preparation
# --------------
#    - constructing an average image by conforming all found T1w images to RAS orientation and
#      a common voxel size.
#
#    - in the case of multiple images, average into a single reference template (longitudinal
#      processing).
#
# 2. Brain extraction
# -------------------
#    - T1w image/average is skull stripped by antsBrainExtraction.sh - an atlas-based brain
#      extraction workflow.
#
# 3. Brain tissue segmentation
# ----------------------------
#    - FSL's fast is then applied to skull-stripped brain for brain tissue segmentation.
#
# 4. Spatial normalisation
# ------------------------
#    - spatial normalization to MNI-space is performed using ANTs’ antsRegistration in 
#      a multiscale, mutual-information based, nonlinear registration scheme. In particular, 
#      spatial normalization is done using the ICBM 2009c Nonlinear Asymmetric template 
#      (1×1×1mm) [Fonov2011].
#
#    - IMPORTANT : When processing images from patients with focal brain lesions (e.g. stroke, 
#                  tumor resection), it is possible to provide a lesion mask to be used during 
#                  spatial normalization to MNI-space [Brett2001]. ANTs will use this mask to 
#                  minimize warping of healthy tissue into damaged areas (or vice-versa). 
#                  Lesion masks should be binary NIfTI images (damaged areas = 1, everywhere 
#                  else = 0) in the same space and resolution as the T1 image, and follow the 
#                  naming convention specified in BIDS Extension Proposal 3: Common Derivatives 
#                  (e.g. sub-001_T1w_label-lesion_roi.nii.gz). This file should be placed in 
#                  the sub-*/anat directory of the BIDS dataset to be run through fmriprep.
#
# 5. Longitudinal processing
# --------------------------
#    - In the case of multiple T1w images (across sessions and/or runs), T1w images are merged 
#      into a single template image using FreeSurfer’s mri_robust_template.
#
#    - This template may be unbiased, or equidistant from all source images, or aligned to 
#      the first image (determined lexicographically by session label).
#
#    - For two images, the additional cost of estimating an unbiased template is trivial 
#      and is the default behavior, but, for greater than two images, the cost can be a 
#      slowdown of an order of magnitude.
#
#    - Therefore, in the case of three or more images, fmriprep constructs templates aligned 
#      to the first image, unless passed the --longitudinal flag, which forces the estimation 
#      of an unbiased template.
#
#		NOTE : The preprocessed T1w image defines the T1w space. In the case of multiple T1w images, 
#		       this space may not be precisely aligned with any of the original images. Reconstructed 
#		       surfaces and functional datasets will be registered to the T1w space, and not to the 
#		       input images.
#
# 6. Surface preprocesing (fmriprep.workflows.anatomical.init_surface_recon_wf)
# -----------------------------------------------------------------------------
#    - fmriprep uses FreeSurfer to reconstruct surfaces from T1w/T2w structural images.
#
#    - All surface preprocessing may be disabled with the --fs-no-reconall flag.
#    
#    NOTE : Surface processing will be skipped if the outputs already exist. In order to bypass 
#           reconstruction in fmriprep, place existing reconstructed subjects in <output dir>/freesurfer 
#           prior to the run. fmriprep will perform any missing recon-all steps, but will not perform 
#           any steps whose outputs already exist.
#
#    - If FreeSurfer reconstruction is performed, the reconstructed subject is placed in 
#      <output dir>/freesurfer/sub-<subject_label>/ (see FreeSurfer Derivatives).
#
#    - Surface reconstruction is performed in three phases:
#
#      Phase 1 : initializes the subject with T1w and T2w (if available) structural images and performs 
#                basic reconstruction (autorecon1) with the exception of skull-stripping. Skull-stripping 
#                is skipped since the brain mask calculated previously is injected into the appropriate 
#                location for FreeSurfer.
#                For example, a subject with only one session with T1w and T2w images would be processed 
#                by the following command:
#
#                recon-all  -sd <output dir>/freesurfer \
#                           -subjid sub-<subject_label> \
#						    -i <bids-root>/sub-<subject_label>/anat/sub-<subject_label>_T1w.nii.gz \
#						    -T2 <bids-root>/sub-<subject_label>/anat/sub-<subject_label>_T2w.nii.gz \
#						    -autorecon1 \
#						    -noskullstrip
#
#      Phase 2 : imports the brainmask calculated in the T1w/T2w preprocessing sub-workflow.
#
#      Phase 3 : resumes reconstruction, using the T2w image to assist in finding the pial surface, 
#                if available. See init_autorecon_resume_wf() for details. 
#
#    - Reconstructed white and pial surfaces are included in the report.
#
#    - If T1w voxel sizes are less than 1mm in all dimensions (rounding to nearest .1mm), 
#      submillimeter reconstruction is used, unless disabled with --no-submm-recon.
#
#    - lh.midthickness and rh.midthickness surfaces are created in the subject surf/ directory, 
#      corresponding to the surface half-way between the gray/white boundary and the pial surface. 
#       
#    - The smoothwm, midthickness, pial and inflated surfaces are also converted to GIFTI format 
#      and adjusted to be compatible with multiple software packages, including FreeSurfer and the 
#      Connectome Workbench.
#
#    NOTE : GIFTI surface outputs are aligned to the FreeSurfer T1.mgz image, which may differ from 
#           the T1w space in some cases, to maintain compatibility with the FreeSurfer directory. 
#           Any measures sampled to the surface take into account any difference in these images.
#
# 7. Refinement of the brain mask
# -------------------------------
#    - the original brain mask calculated with antsBrainExtraction.sh will contain some innaccuracies 
#      including small amounts of MR signal from outside the brain
#
#    - Based on the tissue segmentation of FreeSurfer (located in mri/aseg.mgz) and only when the 
#      Surface Processing step has been executed, FMRIPREP replaces the brain mask with a refined 
#      one that derives from the aseg.mgz file as described in fmriprep.interfaces.freesurfer.grow_mask.
#
#
#
# ******************
# BOLD preprocessing (fmriprep.workflows.bold.base.init_func_preproc_wf)
# ******************
#
# 1. BOLD reference image estimation (fmriprep.workflows.bold.util.init_bold_reference_wf)
# ----------------------------------
#    - If a single-band reference (“sbref”) image associated with the BOLD series is available, 
#      then it is used directly
#
#    - If not, a reference image is estimated from the BOLD series as follows :
#
#			- When T1-saturation effects (“dummy scans” or non-steady state volumes) are detected, 
#             they are averaged and used as reference due to their superior tissue contrast.
#
#           - Otherwise, a median of motion corrected subset of volumes is used.
#
#    - The reference image is then used to calculate a brain mask for the BOLD signal using the 
#      fmriprep.workflows.bold.util.init_enhance_and_skullstrip_bold_wf
#
#    - Further, the reference is fed to the head-motion estimation workflow and the registration 
#      workflow to map BOLD series into the T1w image of the same subject.
#
# 2. Head-motion correction (fmriprep.workflows.bold.hmc.init_bold_hmc_wf)
# -------------------------
#    - Using the previously estimated reference scan, FSL mcflirt is used to estimate head-motion.
#
#    - one rigid-body transform with respect to the reference image is written for each BOLD time-step.
#
#    - a list of 6-parameters (three rotations, three translations) per time-step is written and fed to
#      the confounds workflow.
#
#    - For a more accurate estimation of head-motion, we calculate its parameters before any time-domain 
#      filtering (i.e. slice-timing correction), as recommended in [Power2017].
#
# 3. Slice-timing correction (fmriprep.workflows.bold.stc.init_bold_stc_wf)
# --------------------------
#    - If the SliceTiming field is available within the input dataset metadata, this workflow performs 
#      slice time correction prior to other signal resampling processes.
#
#    - Slice time correction is performed using AFNI 3dTShift.
#
#    - All slices are realigned in time to the middle of each TR.
#
#    - Slice time correction can be disabled with the --ignore slicetiming command line argument.
#
#    - if a BOLD series has fewer than 5 usable (steady-state) volumes, slice time correction will be 
#      disabled for that run
#
# 4. Susceptibility Distortion Correction (fmriprep.workflows.fieldmap.base.init_sdc_wf)
# ---------------------------------------
#    - spatial distortion due to inhomogeneity of the field in the scanner.
#
# 5. Preprocessed BOLD in native space (fmriprep.workflows.bold.resampling.init_bold_preproc_trans_wf)
# ------------------------------------
#    - All volumes in the BOLD series are resampled in their native space by concatenating the mappings 
#      found in previous correction workflows (HMC and SDC if excecuted) for a one-shot interpolation process.
#
#    - Interpolation uses a Lanczos kernel
#
# 6. EPI to T1w registration (fmriprep.workflows.bold.registration.init_bold_reg_wf)
# --------------------------
#    - The alignment between the reference EPI image of each run and the reconstructed subject using the 
#      gray/white matter boundary (FreeSurfer’s ?h.white surfaces) is calculated by the bbregister routine.
#
#    - If FreeSurfer processing is disabled, FSL flirt is run with the BBR cost function, using the fast 
#      segmentation to establish the gray/white matter boundary.
#
#    - After BBR is run, the resulting affine transform will be compared to the initial transform found 
#      by FLIRT. Excessive deviation will result in rejecting the BBR refinement and accepting the original, 
#      affine registration.
#
# 7. EPI to MNI transformation (fmriprep.workflows.bold.resampling.init_bold_mni_trans_wf)
# ----------------------------
#    - This sub-workflow concatenates the transforms calculated upstream (i.e. Head-motion estimation, 
#      Susceptibility Distortion Correction, EPI to T1w registration, and a T1w-to-MNI transform from 
#      T1w/T2w preprocessing) to map the EPI image to standard MNI space.
#
#    - It also maps the T1w-based mask to MNI space
#
#    - Transforms are concatenated and applied all at once, with one interpolation (Lanczos) step, 
#      so as little information is lost as possible.
#
#    - The output space grid can be specified using the template_out_grid argument. 
#      This option accepts the following (str) values:
#
#        'native': the original resolution of the BOLD image will be used.
#        '1mm': uses the 1:math:times`1:math:times`1 [mm] version of the template.
#        '2mm': uses the 2:math:times`2:math:times`2 [mm] version of the template.
#        Path to arbitrary reference file: the output will be resampled on a grid with same resolution 
#                                          as this reference.
#
# 8. EPI sampled to FreeSurfer surfaces (fmriprep.workflows.bold.resampling.init_bold_surf_wf)
# -------------------------------------
#    - If FreeSurfer processing is enabled, the motion-corrected functional series 
#      (after single shot resampling to T1w space) is sampled to the surface by averaging across 
#      the cortical ribbon.
#
#    - Specifically, at each vertex, the segment normal to the white-matter surface, extending to 
#      the pial surface, is sampled at 6 intervals and averaged.
#
#    - Surfaces are generated for the “subject native” surface, as well as transformed to the fsaverage 
#      template space.
#
#    - All surface outputs are in GIFTI format.
#
# 9. Confounds estimation (fmriprep.workflows.bold.confounds.init_bold_confs_wf)
# -----------------------
#    - The "discover_wf" sub-workflow calculates potential confounds per volume, given a motion-corrected fMRI, 
#      a brain mask, mcflirt movement parameters and a segmentation.
#
#    - Calculated confounds include the mean global signal, mean tissue class signal, tCompCor, aCompCor, 
#      Frame-wise Displacement, 6 motion parameters, DVARS, and, if the --use-aroma flag is enabled, the noise 
#      components identified by ICA-AROMA (those to be removed by the “aggressive” denoising strategy).
#
# 10. ICA-AROMA (fmriprep.workflows.bold.confounds.init_ica_aroma_wf)
# -------------
#    - When one of the –output-spaces selected is in MNI space, ICA-AROMA denoising can be automatically appended 
#      to the workflow.
#
#    - The number of ICA-AROMA components depends on a dimensionality estimate made by MELODIC.
#
#    - For datasets with a very short TR and a large number of timepoints, this may result in an unusually high 
#      number of components.
#
#    - By default, dimensionality is limited to a maximum of 200 components. To override this upper limit one may 
#      specify the number of components to be extracted with --aroma-melodic-dimensionality
#
#    NOTE : non-aggressive AROMA denoising is a fundamentally different procedure from its “aggressive” counterpart 
#           and cannot be performed only by using a set of noise regressors (a separate GLM with both noise and signal 
#           regressors needs to be used). Therefore instead of regressors FMRIPREP produces non-aggressive denoised 4D 
#           NIFTI files in the MNI space:
#
#           *bold_space-MNI152NLin2009cAsym_variant-smoothAROMAnonaggr_brainmask.nii.gz
#
#    - Additionally, the MELODIC mix and noise component indices will be generated, so non-aggressive denoising can be 
#      manually performed in the T1w space with fsl_regfilt:
#
#      fsl_regfilt -i sub-<subject_label>_task-<task_id>_bold_space-T1w_preproc.nii.gz \
#                  -f $(cat sub-<subject_label>_task-<task_id>_bold_AROMAnoiseICs.csv) \
#                  -d sub-<subject_label>_task-<task_id>_bold_MELODICmix.tsv \
#                  -o sub-<subject_label>_task-<task_id>_bold_space-<space>_AromaNonAggressiveDenoised.nii.gz
#
#    NOTE : The non-steady state volumes are removed for the determination of components in melodic. Therefore 
#           *MELODICmix.tsv may have zero padded rows to account for the volumes not used in melodic’s estimation 
#           of components.
#
#    - A visualization of the AROMA component classification is also included in the HTML reports
#
# 11. T2* Driven Coregistration (fmriprep.workflows.bold.t2s.init_bold_t2s_wf)
# -----------------------------
#    - If multi-echo BOLD data is supplied, this workflow uses the tedana T2* workflow to generate an adaptive T2* map 
#      and optimally weighted combination of all supplied single echo time series.
#
#    - This optimaly combined time series is then carried forward for all subsequent preprocessing steps. 
#
#    - Optionally, if the --t2s-coreg flag is supplied, the T2* map is then used in place of the BOLD reference image 
#      to register the BOLD series to the T1w image of the same subject.
#