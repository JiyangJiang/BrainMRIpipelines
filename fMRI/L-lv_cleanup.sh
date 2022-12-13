#!/bin/bash

# =================================================================================================================
# DESCRIPTION : This script does cleanup after the preprocessing (with feat commandline).
# -----------------------------------------------------------------------------------------------------------------
# USAGE :
#        $1 = cleanup mode - 'fix' or 'aroma'.
#        $2 = cohort folder (e.g. /Users/z3402744/Work/datasets/2_SCS_rs_fMRI)
#        $3 = high pass threshold (e.g. 100)
#        $4 = 'par_Mcore' (multi-core parallel processing)
#             'par_cluster' (SGE cluster-based parallel processing)
#             'sin' (single processing)
#             Recommend 'par_cluster' as 'sin' and 'par_Mcore' will cause the processing stuck if
#             there is any bad fMRI data.
#
#        - if using 'fix' cleanup
#            $5 = path to FIX installation folder (e.g. /Applications/fsl/FIX/fix1.066)
#            $6 = name of built-in training data (e.g. Standard.RData).
#            $7 = FIX threshold (e.g. 10). Read notes below for explanations.
#
#        - if using 'aroma' cleanup
#            $5 = path to ICA-AROMA (e.g. /Applications/fsl/ICA-AROMA)
# -----------------------------------------------------------------------------------------------------------------


cleanup(){

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
	# -----------------



	case ${cleanup_mode} in



	# ======================
	# Option 1 : FIX cleanup
	# ======================

	fix)

		echo "FIX cleanup selected."

		echo "Performing FIX cleanup ..."

		# Run FIX cleanup
		${currdir}/L-lv_fsl_fix_cleanup.sh --ica ${studyFolder}/${epi_filename}.ica \
		                                   --fixdir ${fixdir} \
		                                   --Tdata ${Tdata} \
		                                   --thr ${fix_thr} \
		                                   --Hpass ${Hpass_thr}

		;;

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

	esac




		# --------------------------------------------------------------------------------
		#                                      FIX
		# --------------------------------------------------------------------------------
		# - If using FEAT GUI to do first-level, turn on ICA in Prestats.
		#
		# - If using MELODIC GUI to do first-level (single-subject ICA), apply MELODIC's
		#   "automatic dimensionality estimation", which creates the subfolder
		#   "<mel.ica>/filtered_func_data.ica".
		#
		# - Threshold is sensible in the range 5-20.
		#
		# - It's important to make sure almost no good components are removed. Hence, you
		#   would prefer to leave in the data a larger number of bad components, then
		#   use a low threshold (1-5).
		#
		# - Strongly recommended to look at the ICA components for at least a few subjects
		#   in the file called sth like "fix4melview_Standard_thr20.txt". The final line
		#   lists the components regarded as noise to be removed (with counting starting
		#	from 1 not 0).
		#
		# - final output is <mel.ica>/filtered_func_data_clean.nii.gz
		#
		# Example
		# -------
		#
		#   fix <mel.ica> /path/to/fix/training_files/Standard.RData 20
		#
		# Alternatively, the processing can be splitted into three stages
		#   
		#   1) Extract features (for later training and/or classifying)
		#
		#      fix -f <mel.ica>
		#
		#   2) Classify ICA components using a specific training dataset (<thresh> in the
		#      range of 0-100, typically 5-20)
		#
		#      fix -c <mel.ica> <training.RData> <thresh>
		#
		#   3) Apply cleanup, using artefacts listed in the .txt file, to the data inside 
		#      the enclosing Feat/Melodic directory. This text file can be the output from 
		#      the step above or can be created manually, in case you want to manually remove 
		#      the artefactual components. In the second case make sure that the txt file 
		#      contains a single line (or, at least, should have as its final line) with a 
		#      list of the bad components only, with the format (for example): [1, 4, 99, ... 140]
		#      - note that the square brackets, and use of commas, is required. Also, make sure 
		#      there is an empty line at the end (i.e. hit return after writing the list). Counting
		#      starts at 1, not 0.
		#      
		#      fix -a <mel.ica/fix4melview_TRAIN_thr.txt>  [-m [-h <highpass>]]  [-A]
		#
		#      where -m : optionally also cleanup motion confounds (24 regressors)
		#            -h <highpass> : highpass filtering.
		#                            -h is omitted : FIX will look at if design.fsf is present, and 
		#                                            find highpass cutoff. if no design.fsf, no 
		#                                            filtering of motion confounds.
		#							 -h -1         : no filtering to motion confounds.
		#                            -h 0          : linear detrending only.
		#                            -h <highpass> : with a positive <highpass> value, apply highpass 
		#                                            with <highpass> being full-width (2*sigma) in seconds.
		#            -A : apply aggressive (full variance) cleanup, instead of the default less-aggressive 
		#                 (unique variance) cleanup.
		#
		#      --==J==-- : highpass is for motion correction?
		#
		# Training datasets
		# -----------------
		#
		# - Trained-weights files
		#
		#   - it is recommended to hand-train FIX with your data.
		#
		#   - at least hand classify 10 subjects.
		#
		#   - built-in trained-weights files:
		#
		#     - Standard.RData : for use in more "standard" FMRI datasets/analyses. e.g., TR=3s, 
		#                        Resolution=3.5x3.5x3.5mm, Session=6mins, default FEAT preprocessing 
		#                        (including default spatial smoothing).
		#
		#     - HCP_hp2000.RData : for use on "minimally-preprocessed" 3T HCP-like datasets, 
		#                          e.g., TR=0.7s, Resolution=2x2x2mm, Session=15mins, no spatial smoothing, 
		#                          minimal (2000s FWHM) highpass temporal filtering.
		#
		#     - HCP7T_hp2000.RData : for use on "minimally-preprocessed" 7T HCP-like datasets, 
		#                            e.g., TR=1.0s, Resolution=1.6x1.6x1.6mm, Session=15mins, 
		#                            no spatial smoothing, minimal (2000s FWHM) highpass temporal filtering.
		#
		#     - WhII_MB6.RData : derived from the Whitehall imaging study, 
		#                        using multiband x6 EPI acceleration: TR=1.3s, Resolution=2x2x2mm, 
		#                        Session=10mins, no spatial smoothing, 100s FWHM highpass temporal filtering.
		#
		#     - WhII_Standard.RData : derived from more traditional early parallel scanning in the Whitehall 
		#                             imaging study, using no EPI acceleration: TR=3s, Resolution=3x3x3mm, 
		#                             Session=10mins, no spatial smoothing, 100s FWHM highpass temporal filtering.
		#
		#     - UKBiobank.RData : derived from fairly HCP-like scanning in the UK Biobank imaging study: 
		#                         40 subjects, TR=0.735s, Resolution=2.4x2.4x2.4mm, Session=6mins, 
		#                         no spatial smoothing, 100s FWHM highpass temporal filtering.
		#
		#   - hand-labelling examples can be found at http://www.fmrib.ox.ac.uk/datasets/FIX-training/
		#
		# - Create and use a new trained-weights file
		#
		#   - To do your own training, for each FEAT/MELODIC output directory, you will need to create 
		#     a hand_labels_noise.txt file in the output directory. This text file should contain a single 
		#     line (or, at least, should have as its final line), a list of the bad components only, with 
		#     the format (for example): [1, 4, 99, ... 140] - note that the square brackets, and use of commas,
		#     is required. Counting starts at 1, not 0. Once you have created all of the hand label files, you 
		#     can then train the classifier (creating the trained-weights file <Training>.RData) using the -t option.
		#
		#     fix -t <Training> [-l]  <Melodic1.ica> <Melodic2.ica> ...
		#
		#   - If you include the -l option after the trained-weights output filename, a full leave-one-out test will 
		#     be run; the results file that gets created at the end has a set of numbers at the end of it that tell 
		#     you the true-positive-rate (TPR, proportion of "good" components correctly labelled) and the 
		#     true-negative-rate (TNR, proportion of "bad" components correctly labelled) for a wide range of thresholds.
		#
		#   - The output from this command are: 
		#        Training.RData - your new trained-weights file to be used for subsequent classification.
		#        Training - a folder with a copy of the labels and the features of the subjects used to build the 
		#                   training dataset.
		#        Traning_LOO - a folder containing the intermediate files for the leave-one-out test (if you used the 
		#                      -l option).
		#        Traning_LOO_results - a file with the results of the leave-one-out test (if you used the -l option)
		#
		# - You can now use your new trained-weights file to classify components in new datasets and then run the 
		#   cleanup on the new data
		#
		#   fix -c <Melodic-output.ica> <Training.RData> <thresh>
		#   fix -a <mel.ica/fix4melview_TRAIN_thr.txt> [-m [-h <highpass>]] [-A] [-x <confound>] [-x <confound2>]
		#
		# - If you want to test the accuracy of an existing training dataset on a set of hand-labelled subjects 
		#   (e.g. to test whether an existing trained-weights file is suitable to be used for your study or if 
		#   it’s better to create a new one), you can run the following command:
		#
		#   fix -C <training.RData> <output> <mel1.ica> <mel2.ica> ...
		#   
		#   which classifies the components for all listed Melodic directories over a range of thresholds and 
		#   produce LOO-style accuracy testing using existing hand classifications. Every Melodic directory must 
		#   contain hand_labels_noise.txt listing the artefact components, e.g.: [1, 4, 99, ... 140].
		#   --==J==--: meaning all listed Melodic directories are hand trained.
		#
		#
		#
		#
		#
		# folder structure
		# ----------------
		# filtered_func_data.nii.gz          preprocessed 4D data
		# filtered_func_data.ica             melodic (command-line program) full output directory
		# mc/prefiltered_func_data_mcf.par   motion parameters created by mcflirt (in mc subdirectory)
		# mask.nii.gz                        valid mask relating to the 4D data
		# mean_func.nii.gz                   temporal mean of 4D data
		# reg/example_func.nii.gz            example image from 4D data
		# reg/highres.nii.gz                 brain-extracted structural
		# reg/highres2example_func.mat       FLIRT transform from structural to functional space
		# design.fsf                         FEAT/MELODIC setup file; if present, this controls the
		#                                    default temporal filtering of motion parameters






		# --------------------------------------------------------------------------
		#                                ICA-AROMA
		# --------------------------------------------------------------------------
		#
		# INTRO
		#
		# - ICA-based Automatic Removal Of Motion Artifacts (ICA-AROMA)
		#
		# - it exploits ICA to decompose the data into a set of independent
		#   components.
		#
		# - subsequently, ICA-AROMA automatically identifies which of these
		#   components are related to head motion, by using four robust and standardised
		#   features.
		#
		# - the identified components are then removed from the data through linear
		#   regression as implemented in fsl_regfilt.
		#
		# - !!! ICA-AROMA has to be applied after spatial smoothing, but prior to
		#   temporal filtering within the typical fMRI preprocessing pipeline.
		#
		# GENERAL INFO
		#
		# - ICA_AROMA.py : the main script to be called by the user.
		#
		# - ICA_AROMA_functions.py : the functions used by ICA_AROMA.py.
		#
		# - The package furthermore contains three spatial maps (CSF, edge &
		#	out-of-brain masks) which are required to derive the spatial
		#   features used by ICA-AROMA.
		#
		# RUN ICA-AROMA - GENERIC
		#
		# - For standard use, ICA_AROMA.py requires the following five inputs:
		#
		#   1) -i|-in       Input file name of fMRI data (.nii.gz).
		#
		#   2) -o|-out      Output directory name.
		#
		#   3) -a|-affmat   File name of the mat-file describing the affine
		#                   registration (e.g. FSL FLIRT) of the functional
		#                   data to structural space (.mat file).
		#
		#   4) -w|-warp     File name of the warp-file describing the non-linear
		#                   registration (e.g. FSL FNIRT) of the structural data
		#                   to MNI152 space (.nii.gz).
		#
		#   5) -mc          File name of the text file containing the six
		#                   (column-wise) realignment parameters time-courses
		#                   derived from volume-realignment (e.g. MCFLIRT).
		#
		# - Example
		#   -------
		#
		#   python2.7 /path/to/ICA_AROMA.py -in func_smoothed.nii.gz
		#                                   -out ICA_AROMA
		#                                   -affmat reg/func2highres.mat
		#                                   -warp reg/highres2standard_warp.nii.gz
		#                                   -mc mc/rest_mcf.par
		#
		# - Of note, the registration files are required to transform the
		#   obtained ICA components to the MNI152 2mm template in order to
		#   derive standardised spatial feature scores. The fMRI data itself
		#   will not be subjected to any registration, transformation or
		#   reslicing.
		#
		# MASKING
		#
		# - either the input fMRI data should be masked (i.e. brain-extracted)
		#   or a specific mask has to be specified (-m|-mask) when running
		#   ICA-AROMA.
		#
		# - Example
		#   -------
		#   
		#   python2.7 /path/to/ICA_AROMA.py -in func_smoothed.nii.gz
		#                                   -out ICA_AROMA
		#                                   -mc mc/rest_mcf.par
		#                                   -affmat reg/example_func2highres.mat
		#                                   -warp reg/highres2standard_warp.nii.gz
		#                                   -m mask_aroma.nii.gz
		#
		# - !!! We recommend not to use the mask determined by FEAT. This mask
		#   is optimised to be used for first-level analysis, as has been dilated
		#   to ensure that all "active" voxels are included. We advise to create
		#   a mask using the Brain Extraction Tool of FSL (fractional intensity
		#   of 0.3), on a non-brain-extracted example or mean functinal image
		#   (e.g. example_func within the FEAT directory).
		#
		#   bet <input> <output> -f 0.3 -n -m -R
		#
		#   -f 0.3 : fractional intensity = 0.3.
		#
		#   -n     : do not generate segmented brain image output.
		#
		#   -m     : generate binary brain mask.
		#
		#   -R     : robust brain centre estimation (iterates BET several times).
		#
		# - Of note, the specified mask will only be used at the first stage
		#   (ICA) of ICA-AROMA. The output fMRI data-file is not masked.
		#
		# RUN ICA-AROMA - AFTER FEAT
		#
		# - ICA-AROMA is optimised for usage:
		#   
		#   - after preprocessing fMRI data with FSL FEAT.
		#   - the directory meets the standardised folder/file-structure.
		#   - NO temporal filtering has been applied.
		#   - it was run including registration to the MNI152 template.
		#
		# - In this case, only the FEAT directory has to be specified (-f|-feat)
		#   next to an output directory. ICA-AROMA will automatically define the
		#   appropriate files, create an appropriate mask (the "MASKING" section)
		#   and use the "melodic.ica" directory if available (in case "MELODIC
		#   ICA data exploration" was checked in FEAT).
		#
		# - !! We RECOMMEND NOT to run MELODIC within FEAT such that MELODIC
		#   will be run within ICA-AROMA using appropriate mask. Moreover, this
		#   option in FEAT is meant for data exploration after full data
		#   preprocessing, as such it can be applied after ICA-AROMA, temporal
		#   high-pass filtering, etc.
		#
		# - Example
		#   -------
		#
		#   python2.7 /path/to/ICA_AROMA.py -feat rest.feat
		#                                   -out rest.feat/ICA_AROMA/
		#
		#   ---=== J ===---
		#   FEAT preprocessing (no temporal filtering, no MELODIC) -->
		#   ICA-AROMA (including MELODIC) --> temporal highpass filtering.
		#
		#
		# OUTPUT
		#
		# denoised_func_data           Denoised fMRI data, suffix with "_nonaggr.
		#                              nii.gz" or "_aggr.nii.gz" depending on the
		#                              requested type of denoising (see the
		#                              following section).
		# classification_overview.txt  Complete overview of the classification
		#                              results.
		# classified_motion_ICs.txt    List with the indices of the components
		#                              classified as motion/noise.
		# feature_scores.txt           File containing the four feature scores
		#                              of all components.
		# melodic_IC_thr_MNI2mm.nii.gz Spatial maps resulting from MELODIC, after
		#                              mixture modelling thresholding and
		#                              registered to the MNI152 2mm template.
		# mask.nii.gz                  Mask used for MELODIC.
		# melodic.ica                  MELODIC output directory.
		#
		# ADDITIONAL OPTIONS
		#
		# - Optional settings
		#
		#   -tr                   TR in seconds. If this is not specified, the
		#                         TR will be extracted from the header of the
		#                         fMRI file using 'fslinfo'. In that case, make
		#                         sure the TR in the header is correct!
		#
		#   -d|-dim               Dimensionality reduction into a defined number
		#                         of dimensions when running MELODIC (default
		#                         is 0; automatic estimation).
		#
		#   -den                  Type of denoising strategy (default is nonaggr)
		#
		#                         no : only classification, no denoising.
		#                         nonaggr : non-aggressive denoising, i.e.
		#                                   partial component regression (default).
		#                         aggr : aggressive denoising, i.e., full
		#                                component regression.
		#                         both : both aggressive and non-aggressive
		#                                denoising (two outputs).
		#
		# - MELODIC
		#   
		#   - When you have already run MELODIC you can specify the melodic
		#     directory as additional input (-md|-meldir) to avoid running
		#     MELODIC again.
		#
		#   - Note that MELODIC should have been run on fMRI data PROIOR TO
		#     temporal filtering, and AFTER spatial smoothing.
		#
		#   - Preferably, it has been run with the recommended mask (see the
		#     "MASKING" section).
		#
		#   - !!! Unless you have a good reason for doing otherwise, we advise
		#     to run MELODIC as part of ICA-AROMA so that it runs with
		#     optimal settings.
		#
		#   - Example (previously run MELODIC)
		#
		#     python2.7 /path/to/ICA_AROMA.py -in filtered_func_data.nii.gz
		#                                     -out ICA_AROMA
		#                                     -mc mc/rest_mcf.par
		#                                     -m mask_aroma.nii.gz
		#                                     -affmat reg/func2highres.mat
		#                                     -warp reg/highres2standard_warp.nii.gz
		#                                     -md filtered_func_data.ica
		#
		#     -md|-meldir : MELODIC directory name, in case MELODIC has been
		#                   run previously.
		#
		# - Registration
		#
		#   - ICA-AROMA is designed and validated to run on data in native
		#     space, hence the requested 'affmat' and 'warp' files.
		#
		#   - However, ICA-AROMA can also be applied on data within structual
		#     or standard space. In these cases, just do not specify the
		#     'affmat' and/or 'warp' file.
		#
		#   - if you applied linear instead of non-linear registration of the
		#     functional data to standard space (J: this can be done in FEAT GUI)
		#     , you only have to specify the affmat file 
		#     (e.g. example_func2standard.mat).
		#
		#   - in other words, depending on which registration files you specify,
		#     ICA-AROMA assumes the data to be in native, structural, or standard
		#     space, and run the spcified registration.
		#
		#   - Example (for data in MNI152 space)
		#     ----------------------------------
		#
		#     python2.7 /path/to/ICA_AROMA.py -in filtered_func_data2standard.nii.gz
		#                                     -out ICA_AROMA
		#                                     -mc mc/rest_mcf.par
		#                                     -m mask_aroma.nii.gz
		#
		#   - Example (in case LINEAR registration to MNI152 space was applied)
		#     -----------------------------------------------------------------
		#   
		#     python2.7 /path/to/ICA_AROMA.py -in func_smoothed.nii.gz
		#                                     -out ICA_AROMA
		#                                     -mc mc/rest_mcf.par
		#                                     -affmat reg/func2standard.mat
		#                                     -m mask_aroma.nii.gz


		
}


main(){
	cleanup_mode=$1
	cohortFolder=$2
	Hpass_thr=$3
	proc_mode=$4

	case ${cleanup_mode} in
		fix)
			fixdir=$5
			Tdata=$6
			fix_thr=$7
			;;
		aroma)
			aroma_path=$5
			;;
	esac


	mkdir -p ${cohortFolder}/SGE_commands/oe

	while read Sfolder
	do
		case ${cleanup_mode} in

			fix)
				
				case ${proc_mode} in

					par_Mcore)

						cleanup ${cleanup_mode} \
								${Sfolder} \
								$(basename ${Sfolder})_func \
								${Hpass_thr} \
								${fixdir} \
								${Tdata} \
								${fix_thr} \
								&
						;;

					par_cluster)

						$(dirname $(which $0))/L-lv_cleanup_SGE.sh ${cohortFolder}/SGE_commands/$(basename ${Sfolder})_L-lv_cleanup.sge \
																	${cleanup_mode} \
																	${Sfolder} \
																	$(basename ${Sfolder})_func \
																	${Hpass_thr} \
																	${fixdir} \
																	${Tdata} \
																	${fix_thr}

						;;

					sin)

						cleanup ${cleanup_mode} \
								${Sfolder} \
								$(basename ${Sfolder})_func \
								${Hpass_thr} \
								${fixdir} \
								${Tdata} \
								${fix_thr}
						;;
				esac

				;;

			aroma)

				case ${proc_mode} in

					par_Mcore)
						
						cleanup ${cleanup_mode} \
								${Sfolder} \
								$(basename ${Sfolder})_func \
								${Hpass_thr} \
								${aroma_path} \
								&
						;;

					par_cluster)

						$(dirname $(which $0))/L-lv_cleanup_SGE.sh ${cohortFolder}/SGE_commands/$(basename ${Sfolder})_L-lv_cleanup.sge \
																	${cleanup_mode} \
																	${Sfolder} \
																	$(basename ${Sfolder})_func \
																	${Hpass_thr} \
																	${aroma_path}

						;;

					sin)

						cleanup ${cleanup_mode} \
								${Sfolder} \
								$(basename ${Sfolder})_func \
								${Hpass_thr} \
								${aroma_path}
						;;

				esac

				;;
		esac



		# check to make sure not exceeding the number of CPU cores
		# if using multi-core parallel processing
		# ---------------------------------------------------------
		if [ "${proc_mode}" = "par_Mcore" ]; then
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
		fi
		
	done < ${cohortFolder}/studyFolder.list


}

main $1 $2 $3 $4 $5 $6 $7