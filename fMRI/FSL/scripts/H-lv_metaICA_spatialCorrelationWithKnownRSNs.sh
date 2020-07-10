#!/bin/sh

# DESCRIPITION
# ==========================================================================
#
# This script calculate spatial correlation between melodic_IC.nii.gz from
# meta ICA and known RSNs.
#
# USAGE
# ==========================================================================
#
# $1 = path to cohort folder
#
# $2 = calculating spatial correlation using 'fsl_web', or 'fsl_fslcc'.
#      'fsl_fslcc' recommended. AFNI's 3ddot can do similar thing, but not
#      implemented here.
#
# $3 = which known RSN map is used. 'fsl_8rsns', 'fsl_10rsns', 'fsl_20rsns',
#      'fsl_70rsns', 'yeo_7rsns', or 'yeo_17rsns'. 'fsl_10rsns' and 'yeo_7rsns'
#      are recommended.
#
# $4 = isotropic resampling scale. should be consistent with previous
#      scripts.
#
# $5 = number of individual ICAs that have been conducted.
#
# $6 = dimensionality of the meta ICA.
#
#





fsl_spatialCorr_web(){

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Ref : https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;1057accd.1202
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#
	# fslcc will include voxels with zero intensity. The following script
	# will ignore these voxels with a mask.
	#
	######### Pearson's R correlation between two image volumes #############
	## --- Compute the correlation from 1st principles
	## --- i.e., account for the mask when determining which voxels to include
	## --- in the computation
	# Note that within the mask, we will treat 0's as valid data

	img1=$1
	img2=$2
	mask=$3

	tmp_dir=`mktemp -d`

	M1=`fslstats $img1 -k $mask -m`
	M2=`fslstats $img2 -k $mask -m`

	fslmaths $img1 -sub $M1 -mas $mask ${tmp_dir}/demeaned1 -odt float
	fslmaths $img2 -sub $M2 -mas $mask ${tmp_dir}/demeaned2 -odt float

	fslmaths ${tmp_dir}/demeaned1 -mul ${tmp_dir}/demeaned2 ${tmp_dir}/demeaned_prod
	num=`fslstats ${tmp_dir}/demeaned_prod -k $mask -m`
	fslmaths ${tmp_dir}/demeaned1 -sqr ${tmp_dir}/demeaned1sqr
	fslmaths ${tmp_dir}/demeaned2 -sqr ${tmp_dir}/demeaned2sqr
	den1=`fslstats ${tmp_dir}/demeaned1sqr -k $mask -m`
	den2=`fslstats ${tmp_dir}/demeaned2sqr -k $mask -m`
	denprod=`echo "scale=4; sqrt($den1*$den2)" | bc -l`
	# The mean can be used instead of the sum because the
	# factor N/sqrt(N*N) will cancel


	# since the arguments passed from the main function are in the order of
	# "knownRSN, melodicIC, knownRSN_mask". demeaned1 will always have intensity
	# range being non-zero, where as demeaned2 can be zero if the mask is not
	# overlapping with melodicIC. In this case the correlation should be zero.
	# However, in this case the 'denprod' variable will be zero, causing error
	# due to dividing zero. Therefore, here force correlation to zero if demeaned2
	# has a range of 0-0

	demeaned2_int_min=`fslstats ${tmp_dir}/demeaned2 -R | awk '{print $1}'`
	demeaned2_int_max=`fslstats ${tmp_dir}/demeaned2 -R | awk '{print $2}'`

	if [ $(bc <<< "${demeaned2_int_min} == 0") -eq 1 ] && \
		[ $(bc <<< "${demeaned2_int_max} == 0") -eq 1 ]; then

		true_r=0.0000

	else

		true_r=`echo "scale=4; $num/$denprod" | bc -l`

	fi

	echo ${true_r}

}

afni_spatialCorr(){

	# This function uses 3ddot from AFNI to calculate spatial correlation.
	#
	# Ref : https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;1057accd.1202
	#
	# AFNI has a function called '3ddot' that allows one to specify a mask
	# file.  (Be sure to use its -demean option if you want the correlation).
	# Also, '3ddot' allows one to compute the eta^2 between two images if you
	# are interested in that measure of spatial correspondence.

	img1=$1
	img2=$2
	mask=$3

	mask_maxInt=`echo $(fslstats ${mask} -R) | awk '{print $2}'`

	3ddot -mask ${mask} \
		  -mrange 3.2 ${mask_maxInt} \
		  -demean \
		  -docor \
		  -doeta2 \
		  -dodice \
		  -show_labels \
		  -upper \
		  ${img1} ${img2}

}




#+++++++++++++++++++++#
#                     #
#  The main function  #
#                     #
#+++++++++++++++++++++#

cohortFolder=$1
fsl_or_afni=$2
knownRSN_flag=$3
resample_scale=$4
N_indICA=$5
N_dim_metaICA=$6


FUTUREdir=$(dirname $(dirname $(dirname $(dirname $(which $0)))))
curr_dir=$(dirname $(which $0))

case ${knownRSN_flag} in

	fsl_8rsns)

		knownRSN="${FUTUREdir}/Atlas/FSL_known_RSNs/8rsns_30ics_2005RoyalSociety"

		;;

	fsl_10rsns)

		knownRSN="${FUTUREdir}/Atlas/FSL_known_RSNs/10rsns_20ics_rsfMRI_2009PNAS"

		;;

	fsl_20rsns)

		knownRSN="${FUTUREdir}/Atlas/FSL_known_RSNs/all20ics_fMRI_2009PNAS"

		;;

	fsl_70rsns)

		knownRSN="${FUTUREdir}/Atlas/FSL_known_RSNs/all70ics_fMRI_2009PNAS"

		;;

	yeo_7rsns)

		knownRSN="${FUTUREdir}/Atlas/Yeo_JNeurophysiol11_MNI152/7rsns_Yeo_JNeurophysiol11_MNI2mm"

		;;


	yeo_17rsns)
	
		knownRSN="${FUTUREdir}/Atlas/Yeo_JNeurophysiol11_MNI152/17rsns_Yeo_JNeurophysiol11_MNI2mm"

		;;	

esac

# conduct isotropic resampling
# This code is copied from H-lv_metaICA_individualICA.sh
mkdir -p ${cohortFolder}/groupICA/resampled_MNI

# flirt -in $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
# 	  -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
# 	  -omat ${cohortFolder}/groupICA/resampled_MNI/MNI2MNI.mat \
# 	  -dof 6 \
# 	  -nosearch

flirt -in ${knownRSN} \
	  -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
	  -applyisoxfm ${resample_scale} \
	  -init ${FUTUREdir}/Atlas/MNI2MNI_4resample/MNI2MNI.mat \
	  -out ${cohortFolder}/groupICA/resampled_MNI/$(basename ${knownRSN})_${resample_scale}mm


# calculate spatial correlation between metaICA melodic_IC.nii.gz and resampled known RSNs
resampled_knownRSN="${cohortFolder}/groupICA/resampled_MNI/$(basename ${knownRSN})_${resample_scale}mm"

for i in `ls -d ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_*`
do

	if [ -f "${i}/metaICA/d${N_dim_metaICA}/melodic_IC_noiseRemoved_WMCSFappended.nii.gz" ]; then
		metaICA_melodicIC=${i}/metaICA/d${N_dim_metaICA}/melodic_IC_noiseRemoved_WMCSFappended
	elif [ -f "${i}/metaICA/d${N_dim_metaICA}/melodic_IC_noiseRemoved.nii.gz" ]; then
		metaICA_melodicIC=${i}/metaICA/d${N_dim_metaICA}/melodic_IC_noiseRemoved
	elif [ -f "${i}/metaICA/d${N_dim_metaICA}/melodic_IC.nii.gz" ]; then
		metaICA_melodicIC=${i}/metaICA/d${N_dim_metaICA}/melodic_IC
	fi

	case ${fsl_or_afni} in


		# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
		# An FSL-based method to calculate spatial correlation.                     #
		# ------------------------------------------------------------------------- #
		# Refer to https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;1057accd.1202 #
		# for more details.                                                         #
		# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #


		fsl_web)

			if [ -f "${i}/metaICA/spatialCorrelationWithKnownRSNs/fsl_volume-wise_spatialCorrelation.txt" ]; then
				rm -f ${i}/metaICA/spatialCorrelationWithKnownRSNs/fsl_volume-wise_spatialCorrelation.txt
			fi
			
			mkdir -p ${i}/metaICA/spatialCorrelationWithKnownRSNs/thresholded_knownRSN_mask
			mkdir -p ${i}/metaICA/spatialCorrelationWithKnownRSNs/splitted_knownRSN_and_metaICs_and_mask
			mkdir -p ${i}/metaICA/spatialCorrelationWithKnownRSNs/thresholded_metaICmap_d${N_dim_metaICA}

			# threshold resampled known RSN to generate the mask (z score threshold = 3.2)
			fslmaths ${resampled_knownRSN} \
					 -thr 3.2 \
					 -bin \
					 ${i}/metaICA/spatialCorrelationWithKnownRSNs/thresholded_knownRSN_mask/$(basename ${resampled_knownRSN})_thr3p2

			mask="${i}/metaICA/spatialCorrelationWithKnownRSNs/thresholded_knownRSN_mask/$(basename ${resampled_knownRSN})_thr3p2"

			# threshold melodic_IC.nii.gz from meta ICA (z score threshold = 3.2)
			fslmaths ${metaICA_melodicIC} \
					 -thr 3.2 \
					 ${metaICA_melodicIC}_thr3p2

			# known RSN does not need the same thresholding as meta IC maps because the mask is only covering
			# known RSN regions with z > 3.2



			N_vol_resampledKnownRSN=`fslval ${resampled_knownRSN} dim4`
			N_vol_metaICmap=`fslnvols ${metaICA_melodicIC}`

			# split resampled knownRSN to indiviudal 3D volumes
			for j in $(seq 1 ${N_vol_resampledKnownRSN})
			do
				fslroi ${resampled_knownRSN} \
					   ${i}/metaICA/spatialCorrelationWithKnownRSNs/splitted_knownRSN_and_metaICs_and_mask/resampled_knownRSN_vol${j} \
					   $((j - 1)) \
					   1
			done

			# split IC map from meta ICA
			for k in $(seq 1 ${N_vol_metaICmap})
			do
				fslroi ${metaICA_melodicIC}_thr3p2 \
					   ${i}/metaICA/spatialCorrelationWithKnownRSNs/splitted_knownRSN_and_metaICs_and_mask/$(basename ${metaICA_melodicIC})_thr3p2_vol${k} \
					   $((k - 1)) \
					   1
			done

			# split mask which is derived from thresholded resampled knownRSN
			for l in $(seq 1 ${N_vol_resampledKnownRSN})
			do
				fslroi ${mask} \
					   ${i}/metaICA/spatialCorrelationWithKnownRSNs/splitted_knownRSN_and_metaICs_and_mask/$(basename ${resampled_knownRSN})_thr3p2_vol${l} \
					   $((l - 1)) \
					   1
			done


			# spatial correlation between each volume of resampled knownRSN and each volume of IC map from meta ICA
			# using FSL
			for m in $(seq 1 ${N_vol_resampledKnownRSN})
			do

				for n in $(seq 1 ${N_vol_metaICmap})
				do

					fsl_spatialCorr_web ${i}/metaICA/spatialCorrelationWithKnownRSNs/splitted_knownRSN_and_metaICs_and_mask/resampled_knownRSN_vol${m} \
										${i}/metaICA/spatialCorrelationWithKnownRSNs/splitted_knownRSN_and_metaICs_and_mask/$(basename ${metaICA_melodicIC})_thr3p2_vol${n} \
										${i}/metaICA/spatialCorrelationWithKnownRSNs/splitted_knownRSN_and_metaICs_and_mask/$(basename ${resampled_knownRSN})_thr3p2_vol${m} \
										>> ${i}/metaICA/spatialCorrelationWithKnownRSNs/fsl_web_vol2vol_spatialCorr.txt

				done
			done

			matlab -r "addpath ('${curr_dir}');\
					   H_lv_metaICA_spatialCorrelationWithKnownRSNs_disp   ('${i}/metaICA/spatialCorrelationWithKnownRSNs/fsl_web_vol2vol_spatialCorr.txt', \
												 		 					'fsl_web', \
												 		 					'${N_vol_metaICmap}', \
												 		 					'${N_vol_resampledKnownRSN}'); \
					   exit"

		;;




		# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
		# Calculating spatial correlation based on fslcc.                              #
		# ---------------------------------------------------------------------------- #
		# Refer to 1) https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Fslutils                  #
		#          2) https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;3d638ca1.1006 #
		#          3) http://psych.colorado.edu/~anre8906/guides/01-ica.html           #
		#          4) https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind1607&L=FSL&P   #
		#             =R69257&1=FSL&9=A&J=on&d=No+Match%3BMatch%3BMatches&z=4          #
		#          5) https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind1606&L=FSL&P   #
		#             =R133905&1=FSL&9=A&J=on&d=No+Match%3BMatch%3BMatches&z=4         #
		#                                                                              #
		# To summarise the references, fslcc is commonly used to compare melodic ICs.  #
		# typically mask is not necessary. thresholded IC maps can avoid noise         #
		# reducing correlation.                                                        #
		#                                                                              #
		# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #



		fsl_fslcc)

			mkdir -p ${i}/metaICA/spatialCorrelationWithKnownRSNs/thresholded_knownRSN
			mkdir -p ${i}/metaICA/spatialCorrelationWithKnownRSNs/thresholded_metaICmap_d${N_dim_metaICA}

			if [ "${knownRSN_flag}" = "fsl_8rsns" ] || \
				[ "${knownRSN_flag}" = "fsl_10rsns" ] || \
				 [ "${knownRSN_flag}" = "fsl_20rsns" ] || \
				  [ "${knownRSN_flag}" = "fsl_70rsns" ]; then
				
				# threshold resampled known RSN (z score threshold = 3.2)
				# only threshold FSL predifined RSNs (fsl_*) because they are z-score melodic ICs
				# Yeo atlases are normal atlases which do not need.
				fslmaths ${resampled_knownRSN} \
						 -thr 3.2 \
						 ${i}/metaICA/spatialCorrelationWithKnownRSNs/thresholded_knownRSN/$(basename ${resampled_knownRSN})_thr3p2

				thresholded_resampled_knownRSN="${i}/metaICA/spatialCorrelationWithKnownRSNs/thresholded_knownRSN/$(basename ${resampled_knownRSN})_thr3p2"

			elif [ "${knownRSN_flag}" = "yeo_7rsns" ] || \
					[ "${knownRSN_flag}" = "yeo_17rsns" ]; then

				thresholded_resampled_knownRSN=${resampled_knownRSN}

			fi

			# threshold melodic IC maps (from meta ICA; z-score threshold = 3.2)
			fslmaths ${metaICA_melodicIC} \
					 -thr 3.2 \
					 ${metaICA_melodicIC}_thr3p2

			thresholded_metaICmap="${metaICA_melodicIC}_thr3p2.nii.gz"


			# fslcc to calculate spatial correlation between thresholded known RSN and thresholded melodic_IC (from metaICA)
			fslcc --noabs \
				  -p 4 \
				  -t .204 \
				  ${thresholded_resampled_knownRSN} \
				  ${thresholded_metaICmap} > ${i}/metaICA/spatialCorrelationWithKnownRSNs/fsl_fslcc_vol2vol_spatialCorr.txt


			# display matrix
			N_vol_resampledKnownRSN=`fslval ${resampled_knownRSN} dim4`
			N_vol_metaICmap=`fslnvols ${metaICA_melodicIC}`

			matlab -r "addpath ('${curr_dir}');\
					   H_lv_metaICA_spatialCorrelationWithKnownRSNs_disp   ('${i}/metaICA/spatialCorrelationWithKnownRSNs/fsl_fslcc_vol2vol_spatialCorr.txt', \
												 		 					'fsl_fslcc', \
												 		 					'${N_vol_metaICmap}', \
												 		 					'${N_vol_resampledKnownRSN}'), \
					   exit"
			

		;;


	esac

done
