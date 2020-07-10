#!/bin/bash

# ==============================================================
# DESCRIPTION : This is the main script to run group ICA, dual
#               regression, and group comparison with randomise.
# ==============================================================



# ========================   USAGE   ============================
#
# $1 : cohort folder that contains all study folders.
#
# $2 : 'genList' or 'noGenList'. better 'genList' with grp1.list
#      and grp2.list present in groupICA folder which can enable
#      conducting group ICA in grp1 or grp2.
#
# $3 : lower level cleanup method - 'fix' or 'aroma'.
#
# $4 : 'yesGrpICA' or 'noGrpICA'. whether implement group ICA.
#
# $5 : 'yesDualReg' or 'noDualReg'. whether dual regression and
#      randomise permutation.
#
# ---------------- 'yesGrpICA' + 'noDualReg' --------------------
#
# $6 : isotropic resampling scale
#
# $7 : do group ICA in 'grp1', 'grp2', or 'all' participants.
#
# $8 : number of components to decompose (dimensionality).
#      'auto' if using automated estimation (through PCA?)
#
# 
# ---------------- 'yesGrpICA' + 'yesDualReg' --------------------
#
# $6 : isotropic resampling scale
#
# $7 : do group ICA in 'grp1', 'grp2', or 'all' participants.
#
# $8 : number of components to decompose (dimensionality).
#      'auto' if using automated estimation (through PCA?).
#
# $9 : the base filename of the design matrix. Pass any string
#      if testing grp_mean - only as output dir name in this case.
#
# $10 : number of randomise permutations. set to 1 for just raw
#      tstat output. set to 0 to not run randomise at all.
#
# $11 : 'grp_mean' for group-mean (one-group t-test) modelling.
#      'grp_cmp' if testing other hypotheses. Only affecting
#      *randomise*.
#
# $12 : 'predef_20_rsns', 'predef_10_rsns', or 'grp_ICs'
#
# ---------------- 'noGrpICA' + 'yesDualReg' --------------------
#
# $6 : Dimensionality.NEEDED TO CHOOSE WHICH MELODIC_IC IF 
#      template_flag (${10}) = grp_ICs.
#      IF template_flag=predef_*_rsns PASS ANY STRING.
#      number of components to decompose (dimensionality).
#      'auto' if using automated estimation (through PCA?).
#
# $7 : the base filename of the design matrix. Pass any string
#      if testing grp_mean - only as output dir name in this case.
#
# $8 : number of randomise permutations. set to 1 for just raw
#      tstat output. set to 0 to not run randomise at all.
#
# $9 : 'grp_mean' for group-mean (one-group t-test) modelling.
#      'grp_cmp' if testing other hypotheses. Only affecting
#      *randomise*.
#
# $10 : 'predef_20_rsns', 'predef_10_rsns', or 'grp_ICs'
#
# ===============================================================



H_lv_processing(){

	# --------------------
	# Compulsory arguments
	# --------------------
	cohortFolder=$1
	genList=$2
	L_lv_type=$3
	grpICA_flag=$4
	dualReg_flag=$5

	# ------------------
	# Optional arguments
	# ------------------
	if [ "${grpICA_flag}" = "yesGrpICA" ] && [ "${dualReg_flag}" = "noDualReg" ]; then

		resample_scale=$6
		grpICA_subsample=$7
		Ndim=$8

		echo "H-lv_grpICA_dualReg_grpComp.sh -- $(date) -- ${grpICA_flag}+${dualReg_flag}+${grpICA_subsample}+${Ndim}" >> ${cohortFolder}/LOG


	elif [ "${grpICA_flag}" = "yesGrpICA" ] && [ "${dualReg_flag}" = "yesDualReg" ]; then

		resample_scale=$6
		grpICA_subsample=$7
		Ndim=$8
		des_mtx_basename=$9
		Nperm=${10}
		test_mode=${11}
		template_flag=${12}

		echo "H-lv_grpICA_dualReg_grpComp.sh -- $(date) -- ${grpICA_flag}+${dualReg_flag}+${Ndim}+${des_mtx_basename}+${Nperm}+${test_mode}+${template_flag}" >> ${cohortFolder}/LOG


	elif [ "${grpICA_flag}" = "noGrpICA" ] && [ "${dualReg_flag}" = "yesDualReg" ]; then

		# Ndim is needed to choose which melodic_IC if template_flag='grp_ICs'
		Ndim=$6
		des_mtx_basename=$7
		Nperm=$8
		test_mode=$9
		template_flag=${10}

		echo "H-lv_grpICA_dualReg_grpComp.sh -- $(date) -- ${grpICA_flag}+${dualReg_flag}+${Ndim}+${des_mtx_basename}+${Nperm}+${test_mode}+${template_flag}" >> ${cohortFolder}/LOG


	elif [ "${grpICA_flag}" = "noGrpICA" ] && [ "${dualReg_flag}" = "noDualReg" ]; then

		echo "H-lv_grpICA_dualReg_grpComp.sh -- $(date) -- ${grpICA_flag}+${dualReg_flag}" >> ${cohortFolder}/LOG
		# no group ICA + no dual regression
		# nothing to do
	fi
	


	# -----------------
	# Some preparations
	# -----------------
	currdir=$(dirname $(which $0))
	FUTUREdir=$(dirname $(dirname $(dirname ${currdir})))

	case ${template_flag} in

		predef_20_rsns)

			templete="${FUTUREdir}/Atlas/FSL_known_RSNs/all20ics_fMRI_2009PNAS.nii.gz"

		;;

		predef_10_rsns)

			templete="${FUTUREdir}/Atlas/FSL_known_RSNs/10rsns_20ics_rsfMRI_2009PNAS.nii.gz"

		;;

		grp_ICs)

			templete="${cohortFolder}/groupICA/d${Ndim}/melodic_IC.nii.gz"

		;;

	esac


	# ---------------------------------
	# generate input list for group ICA
	# ---------------------------------
	case ${genList} in

		genList)
			${currdir}/Ini_genLists.sh ${cohortFolder} \
									   ${L_lv_type}
			;;

		noGenList)
			echo "Not generating input list. This might have already been done at the beginning."
			;;
	esac


	# ---------------------------------------------
	#                   get TR
	# ---------------------------------------------
	# - assuming all func imgs in the cohort have the
	#.  same TR as the first func.
	eg_func=`ls $(head -n 1 ${cohortFolder}/studyFolder.list)/*_func.nii*`
	tr=`fslval ${eg_func} pixdim4`


	# ---------
	# group ICA
	# ---------
	#
	# Some info on melodic command line
	# ---------------------------------
	# - To run Mixture Model based inference on estimated ICs:
	#       melodic -i <filename> \
	#               --ICs=melodic_IC \
	#               --mix=melodic_mix \
	#               <options>
	#
	#
	# Some info on group ICA
	# ----------------------
	# - Why not just run ICA on each subject separately?
	#   - Correspondence problem (e.g. RSNs across subjects).
	#   - Different splittings sometimes are caused by small changes
	#     in the data.
	#   - Instead, start with a "group-average" ICA.
	#   - But then need to relate group maps back to the individual
	#     subjects.
	#

	# -------------------------------------------------------------------------
	# Sep 25, 2018 - Script is modified according to the run_groupICA.sh
	#                distributed with the FSL course example data. Added
	#                --bgthreshold=1 : brain / non-brain threshold.
	#                --bgimage=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
	#                                : specify background image for report
	#                                  (default = mean image).
	# -------------------------------------------------------------------------

	case ${grpICA_flag} in

		yesGrpICA)

			if [ -d "${cohortFolder}/groupICA/d${Ndim}" ]; then
				rm -fr ${cohortFolder}/groupICA/d${Ndim}
			fi

			mkdir ${cohortFolder}/groupICA/d${Ndim}


			# resample MNI brain and mask
			mkdir -p ${cohortFolder}/groupICA/resampled_MNI

			flirt -in $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
				  -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
				  -omat ${cohortFolder}/groupICA/resampled_MNI/MNI2MNI.mat \
				  -dof 6 \
				  -nosearch

			flirt -in $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
				  -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
				  -applyisoxfm ${resample_scale} \
				  -init ${cohortFolder}/groupICA/resampled_MNI/MNI2MNI.mat \
				  -out ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${resample_scale}mm

			flirt -in ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask.nii.gz \
				  -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
				  -applyisoxfm ${resample_scale} \
				  -init ${cohortFolder}/groupICA/resampled_MNI/MNI2MNI.mat \
				  -out ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${resample_scale}mm

				  

			# running group ICA in subsample or whole sample
			case ${grpICA_subsample} in

				grp1)
					
					echo "Running group ICA in grp1 ..."

					grpICA_subsample_list="${cohortFolder}/groupICA/input.list.grp1"

					;;

				grp2)

					echo "Running group ICA in grp2 ..."

					grpICA_subsample_list="${cohortFolder}/groupICA/input.list.grp2"

					;;

				all)

					echo "Running group ICA in the whole sample ..."

					grpICA_subsample_list="${cohortFolder}/groupICA/input.list"

					;;

			esac
			
			if [ "${Ndim}" = "auto" ]; then
				melodic -i ${grpICA_subsample_list} \
						-o ${cohortFolder}/groupICA/d${Ndim} \
						--tr=${tr} \
						--nobet \
						--bgthreshold=1 \
						-a concat \
						--bgimage=${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${resample_scale}mm \
						-m ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${resample_scale}mm \
						--report \
						--mmthresh=0.5 \
						--Oall
			else
				melodic -i ${grpICA_subsample_list} \
						-o ${cohortFolder}/groupICA/d${Ndim} \
						--tr=${tr} \
						--nobet \
						--bgthreshold=1 \
						-a concat \
						--bgimage=${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${resample_scale}mm \
						-m ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${resample_scale}mm \
						--report \
						--mmthresh=0.5 \
						--Oall \
						-d ${Ndim}
			fi

			# mixture-model-based thresholding
			# ${currdir}/H-lv_threshold_grpICs.sh ${cohortFolder} \
			# 									${Ndim} \
			# 									0.5

		;;

		noGrpICA)

			echo "noGrpICA set, not implementing group ICA."

		;;
	esac


	# ---------------
	# Dual regression
	# ---------------
	#
	# Running dual regression
	# -----------------------
	# - Run MELODIC on your group data in concat-ICA mode ("Multi-session
	#	temporal concatenation"). Find the file containing the ICA spatial
	#   maps output by the group-ICA; this will be called something like
	#   melodic_IC.nii.gz and will be inside a something.ica MELODIC output
	#   directory.
	#
	# - Use GLM (or any other method) to create your multi-subject design
	#   matrix and contrast files (design.mat/design.con).
	#
	# - Run dual-regression.
	#
	#   - The 4D group spatial IC maps file will be something like
	#     somewhere.ica/melodic_IC.
	#
	#   - !!! The des_norm option determines whether to variance-normalise the
	#     timecouses created by Stage 1 of the dual regression; it is these
	#     that are used as the regressor in Stage 2. If you do not normalise
	#     them, then you will only test for RSN "shape" in your cross-subject
	#     testing. If you do normalise them, you are testing for RSN "shape"
	#     and "amplitude".
	#
	#   - One easy way to get the list of outputs (all subjects' standard
	#     space 4D timeseries files) at the end of the command is to use the
	#     following (instead of listing the files explicitly, by hand), to get
	#     the list of files that was fed into your group-ICA:
	#        `cat somewhere.gica/.filelist`
	#
	# Three stages
	# ------------
	# - Stage 1 : Regress group maps (or templates) into each subject's
	#             4D data to find subject-specific timecourses.
	# 
	# - Stage 2 : Regress these timecourses back into the 4D data to
	#             find subject-specific spatial maps.
	#
	# - Stage 3 : Group comparison using Randomise.
	#
	#
	# Dual regression outputs
	# -----------------------
	# - dr_stage1_subject[#SUB].txt : the timeseries outputs of stage 1
	#                                 of the dual-regression. One text file
	#                                 per subject, each containing columns
	#                                 of timeseries - one timeseries per
	#                                 group-ICA component. These timeseries
	#                                 can be fed into further network modelling,
	#                                 e.g., taking the N timeseries and generate
	#                                 an N*N correlation matrix
	#
	# - dr_stage2_subject[#SUB].nii.gz : the spatial maps outputs of
	#                                    stage 2 of the dual-regression. One 4D
	#                                    image file per subject, and within each,
	#                                    one timepoint (3D image) per original
	#                                    group-ICA component. These are the GLM
	#                                    "parameter estimate" (PE) images, i.e.,
	#                                    are not normalised by the residual within-
	#                                    subject noise. By default, we recommend
	#                                    that it is these that are fed into stage 3
	#                                    (the final cross-subject modelling).
	#
	# - dr_stage2_subject[#SUB]_Z.nii.gz : the Z-stat version of the above, which could
	#                                      be fed into the cross-subject modelling, but
	#                                      in general does not seem to work as well as
	#                                      using the PEs.
	#
	# - dr_stage2_ic[#ICA].nii.gz : the same as the PE images described above, but re-organised
	#                               into being one 4D image file per group-ICA component, and,
	#                               within each, having one timepoint (3D image) per subject.
	#                               This re-organisation is to allow stage 3, the cross-subject
	#                               modelling for each group-ICA component - so it is these files
	#                               that would normally be fed into "randomise".
	#
	# - dr_stage3_ic[#ICA]_tstat[#CON].nii.gz : the output of "Stage 3" (randomise). i.e. files
	#                                           created by running randomise, doing cross-subject
	#                                           statistics separately for each group-ICA component.
	#                                           You'll get one set of statistical output files per
	#                                           group-ICA component, and, within that set of
	#                                           statistical output files, one t-stat (etc.) per
	#                                           contrast in the cross-subject contrast file (design.con).
	#                                           The corresponding corrected (1-p) p-value images are
	#                                           called *corrp*.
	#
	#
	#
	# Multiple-comparison correction across all RSNs
	# ----------------------------------------------
	# - The need for correction, and correction via Bonferroni
	#   The corrected p-values output by the final randomise (*corrp*) are fully corrected for multiple
	#   comparisons across voxels, but only for each RSN in its own right, and only doing one-tailed
	#   testing (for t-contrasts specified in design.con). This means that if you test (with randomise)
	#   all components found by the initial group-ICA, and you do not have a prior reason for only
	#   considering one of them, you should correct your correced p-values by a further factor. For
	#   example, let's say that your group-ICA found 30 components, and you decided to ignore 18 of
	#   them as being artefact. You therefore only considered 12 RSNs as being of potential interest,
	#   and looked at the outputs of randomise for these 12, with your model being a two-group test
	#   (controls and patients). However, you did not know whether you were looking for increases
	#   or decreases in RSN connectivity, and so you ran the two-group contrast both ways for each
	#   RSN. In this case, instead of your corrected p-values needing to be <0.5 for full significance,
	#   they really need to be <0.05/(12*2) = 0.002.
	#
	#
	# Other info about dual-regression
	# --------------------------------
	# - correct for multiple comparisons across voxels, but not acrosss
	#   #components.
	#
	# - existing templates : http://www.fmrib.ox.ac.uk/datasets/brainmap+rsns/
	#
	#
	# Some info on group comparison
	# -----------------------------
	# - Randomisation test on GLM
	#   - collected maps (individual maps from dual-regression) = design matrix * group differences
	#
	# - Can now do voxelwise testing across subjects, separately for
	#   each original group ICA map.
	#
	# - Can choose to look at strength-and-shape differences


	# -------------------------------------------------
	# prepare the input list string for dual_regression
	# -------------------------------------------------
	in_str=""
	while read input
	do
		in_str="${in_str} ${input}"
	done < ${cohortFolder}/groupICA/input.list


	# -------------------------------------------
	# run dual regression and randomise modelling
	# -------------------------------------------
	case ${dualReg_flag} in

		noDualReg)
			echo "noDualReg set, not implementing dual regression."
		;;

		yesDualReg)

			if [ -d "${cohortFolder}/groupICA/dualReg_rand_results/${des_mtx_basename}/d${Ndim}" ]; then
				rm -fr ${cohortFolder}/groupICA/dualReg_rand_results/${des_mtx_basename}/d${Ndim}
			fi

			mkdir -p ${cohortFolder}/groupICA/dualReg_rand_results/${des_mtx_basename}/d${Ndim}

			output_folder=${cohortFolder}/groupICA/dualReg_rand_results/${des_mtx_basename}/d${Ndim}

			case ${test_mode} in
				
				grp_cmp)

					${currdir}/dual_regression_Jmod_demean ${templete} \
														   1 \
														   ${cohortFolder}/groupICA/des_mtx/${des_mtx_basename}.mat \
														   ${cohortFolder}/groupICA/des_mtx/${des_mtx_basename}.con \
														   ${Nperm} \
														   ${output_folder} \
														   ${in_str}
				;;


				grp_mean)

					echo "Testing group mean ..."
					${currdir}/dual_regression_Jmod_demean ${templete} \
														   1 \
														   -1 \
														   ${Nperm} \
														   ${output_folder} \
														   ${in_str}
				;;
			esac
		;;
	esac

}

H_lv_processing $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12}