#!/bin/bash

# - eddy is a new tool for correcting both eddy current-induced distortion and SUBJECT MOVEMENTS
#
# - able to work with higher b-values than eddy_correct (earlier tool for eddy current corr)
#
# - it also, optionally, performs outlier detection to identify slices where signal has been 
#   lost as a consequence of subject movement during the diffusion encoding. These slices are
#   replaced by non-parametric predictions by the Gaussian Process
#
# - the set of diffusion encoding directions should span the entire sphere, not just a half-sphere
#
# !!! - sampling along vector v and -v have the same signal from diffusion perspective
#
# !!! - eddy can also work well with aquisitions without reversed phase encoding directions or the vectors
#       not covering a whole sphere. need to add --slm=linear parameter.
#     - slm = second level model.
#     - For high quality data with 60+ directions sampled on the whole sphere, use "--slm none" which
#       is default.
#     - For data with fewer directions and/or not sampled on the whole sphere, use "--slm linear".
#     - use FUTURE/DWI/General/view_bvec.m to visualise bvec to see whether it was sampled on the whole
#       sphere.
#
# - For eddy to work well there also needs to be a minimum number of diffusion directions. The reason 
#   for this is that the concept of "close" and "distant" vectors becomes a little pointless when there 
#   are only a handful of vectors. The "minimum number" will depend on the b-value (with a larger number 
#   of directions needed for higher b-values), but it appears that the minimum is ~10-15 directions for 
#   a b-value of 1500 and ~30-40 directions for a b-value of 5000.
#
# !!! - a larger number of directions needs for higher b-values.
#
# - acquisition recommendations
#
#   if N of volumes < 80, acquire all DWI in a single phase encoding direction. acquire 2-3 opposite phase
#                         encoding b0's for topup, and they should be acquired immediately prior to the full
#                         data set.
#   if N of volumes > 120, acquire N/2 unique diffusion gradiants/directions in one phase encoding direction, 
#                          and the other N/2 with opposing phase encoding direction.
#   if 80 < N of volumes < 120, depending on the model for tractography, and how many fibres to model per voxel.
#
# !!! - 60 directions are sufficient angular resolution for most applications.
#
# !!! - The opposing-PE acquisitions offer the option to use a different type of "interpolation" called
#       "least-squares reconstruction". It works by combining data acquired with two PE-directions to solve
#       the problem of "which might the truth look like that produce these two distorted datasets".
#
# - eddy 5.0.11 can perform slice-to-volume (i.e. inter- and intra-volume) MOTION CORRECTION.
#
# - New in 6.0.1
#
#    eddy 6.0.1 adds the ability to model how the susceptibility induced field changes when someone moves 
#    in the scanner. If you think of the main magnetic as a slowly flowing river (with the magnetic flux 
#    	being the flow) and think of the head as an object that you insert into that river, then the 
#    disruption of the flow corresponds to the susceptibility induced field. If you translate that object 
#    across the river or upstream/downstream that river the disruption will move with the object, but its 
#    nature will be the same. This corresponds to the implicit assumption in most/all susceptibility 
#    correction methods, i.e. that as a first approximation the susceptibility field moves with the subject.

#       But if you now imagine rotating that object in the river (around an axis that is non-parallel with the 
#    	main flux) you quickly realise that will now change the disruption it causes in a more fundamental 
#    way. The consequence of that is that a susceptibility field that you acquired/measured with the subject 
#    in one position will no longer be valid after a rotational change. The change is not big, so this is 
#    very much a "second order" correction. But in subjects/cohorts where there are lots of movement (babies, 
#    	children, patients with dementia etc) it becomes important.
#
#     In order to correct for this alteration, all you need to do as a user is to include the 
#    '--estimate_move_by_susceptibility' flag in the eddy call
#
#
# - More description about the acqparams.txt can be found at 
#   https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/eddy/Faq#How_do_I_know_what_to_put_into_my_--acqp_file
#
# !!! - Regarding the problem of misalignment between the b0 and rest of data (with b > 0), there can be two possible
#       causes :
#   
#       1. misalignment along PE-direction caused by difficulty to disentangle a constant eddy-current field from
#          subject's translation along PE-direction. it is likely to occur for most data. It is solved with "separating
#          the offset (constant eddy current field) from movement". This is done by default. --dont_sep_offs_move
#          can disable this function which is NOT recommended.
#
#       2. subject's movement between b0 and first non-b0 dwi data, where it can be any combination of translations
#          and rotations occur if long gap between b0 and dwi or uncooperative subjects. This is solved by Mutual
#          Information-based rigid-body registration between the mean b0 volume and mean volume for each dwi shell.
#          This registration is always run, and rigid-body parameters are saved to a text file. If --dont_peas is set,
#          these parameters are not applied to data (PEAS = post eddy alignment of shells)
#
#       if you have a large number of subjects and you are not sure if maybe some of those subjects moved between the 
#       first b=0 and the first dwi volumes, then using PEAS on your entire cohort ensures that you are at least never 
#       "more wrong" than the uncertainty of the Mutual Information registration (~0.15 mm and ~0.15 degrees).
#
#       If I was tasked with analysing a data set like for example the HCP, where the first dwi volume is acquired a few 
#       seconds after the first b=0 volume and were the subjects are cooperative healthy adult, I would assume that the 
#       subject had lied still and use the --dont_peas flag. But I would also inspect the file with the PEAS parameters 
#       to ensure that there were no subjects that moved excessively in that period.
#
#
# - eddy needs to be informed with
#   - results from topup (which is used to calculate the susceptibility distortions)
#   - diffusion direction / weighting of each volume
#   - phase encoding direction of each volume
#   - which slices are acquired together (multi-band) and the order of acquisition
#
# - when (not if) a subject makes a movement that coincides in time with the diffusion encoding part of the sequence,
#   there will be partial or complete signal dropout. eddy 5.0.10 can detect these dropout slices and replace them with
#   Gaussian Process predictions. This is done with --repol option.
#
# !!! - The zig-zag pattern associated with within-plane movement and interleaved acquisition is due to signal being
#       rotated in or out of the mid-sagittal plane. The signal is not loast, and only needs to be relocated to its
#       "proper" location. eddy 5.0.11 is able for within-volume (or "slice-to-volume") movement correction. This is
#       done with --mporder and a value greater than 0. if --mporder=4, the movement within volume is modelled by the 5
#       first terms of a DCT basis-set, and is hence defined by 6*5=30 parameters instead of the usual 6 rigid-body 
#       parameters.
#
# !!! - Regarding acqparams.txt, it is almost does not matter what to put in acqparams.txt. If the opposite PE images were
#       not acquired in a special way, use the following strategies :
# 
#       1) Run a movie for the 4D image that you input into topup (i.e. the PE and inverse PE (blip-up and blip-down)).
#
#       2) if the brain jumps up and down in the movie, then set acqparams.txt as
#     
#              0 1 0 0.05
#              0 -1 0 0.05
#
#       3) if the brain bounces from side to side in the movie, then use the following in acqparams.txt
#
#              1 0 0 0.05
#              -1 0 0 0.05
#
#       4) if the brain stays still in the movie, there may be some error in the acquisition - the images were acquired with
#          the same PE direction - not able to use topup.
#
#       For details, refer to https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/eddy/Faq#How_do_I_know_what_to_put_into_my_--acqp_file

study_dir=/data2/jiyang/MW4_DWI_eddy




while read id
do

	cd ${study_dir}/mrtrix/${id}/eddy

	# prepare acqparams.txt
	echo "0 1 0 0.05" > acqparams.txt
	acqparamsTXT=acqparams.txt

	# prepare index.txt (MW4 DWI seems to be PA)
	indx=""
	for ((i=1; i<=$(fslval mrdegibbs dim4); i+=1)); do indx="${indx} 1"; done
	echo $indx > index.txt

# eddy
cat << EOT > ../cmd/eddy.cmd
eddy_cuda9.1 --imain=mrdegibbs \
			 --mask=mask \
			 --acqp=acqparams.txt \
			 --index=index.txt \
			 --slm=linear \
			 --bvecs=bvec \
			 --bvals=bval \
			 --repol \
			 --out=out \
			 --niter=8 \
			 --fwhm=10,8,4,2,0,0,0,0 \
			 --ol_type=sw \
			 --mporder=8 \
			 --s2v_niter=8 \
			 --verbose
EOT

chmod +x ../cmd/eddy.cmd
sh ../cmd/eddy.cmd > ../cmd/oe/eddy.out

done < ${study_dir}/mrtrix/list

# ================================================================== #
#                            eddy output                             #
# ================================================================== #
#
# assuming user specified --out=my_eddy_output
#
# 
# my_eddy_output.nii.gz
# -------------------------------------------------------------------
# input data after correction for eddy currents and subject movement,
# and for susceptibility if --topup or --field was specified, and for
# signal dropout if --repol was set.
#
# my_eddy_output.eddy_parameters
# -------------------------------------------------------------------
# text file with one row for each volume in --imain and one column for
# each parameter. First siz columns are 3 translations followed by 3
# rotations. The remaining columns are eddy current-induced fields.
#
# my_eddy_output.rotated_bvecs
# -------------------------------------------------------------------
# remedied bvec after correcting for rotation movement.
#
# my_eddy_output.eddy_movement_rms
# -------------------------------------------------------------------
# summary of total movement (i.e. average displacement across all
# intracerebral voxels). Two columns - 1st column is movement relative
# to the first volume, and 2nd column is relative to the previous
# volume.
#
# my_eddy_output.eddy_restricted_movement_rms
# -------------------------------------------------------------------
# movement summary disregarding translation in PE direction. The eddy 
# current component that has a non-zero mean across FOV, and 
# subject movement (translation) in the PE direction, affect image in
# the same way. Therefore, it is ambiguous to distinguish. Regarding
# data correction, it makes no difference if we estimate more EC but
# less movement component, or vice versa. But it matters if we want
# the estimate of movement parameters.
#
# my_eddy_output.eddy_shell_alignment_parameters
# -------------------------------------------------------------------
# text file of rigid-body movement parameters between different shells
# estimated by mutual information based registration. if --dont_peas,
# my_eddy_output.nii.gz is not corrected for these movement parameters.
#
# my_eddy_output.eddy_post_eddy_shell_PE_translation_parameters
# -------------------------------------------------------------------
# text file of translation along the PE-direction between different
# shells estimated by mutual information based registration. if
# --dont_sep_offs_move, my_eddy_output.nii.gz is not corrected for
# this translation.
#
# my_eddy_output.eddy_outlier_*
# -------------------------------------------------------------------
# text file reporting outlier. one row for each volume and one column
# for each slice. b0 has all zeros since eddy does not consider outliers
# in there.
#
#       .eddy_outlier_map : 0 if slice is not outlier, 1 if it is.
#       .eddy_outlier_n_stdev_map : how many SD off the mean difference
#                                   between observation and prediction.
#       .eddy_outlier_n_sqr_stdev_map : how many SD off the square root
#                                       of the mean squared difference
#                                       between observation and prediction.
#
# if --repol, my_eddy_output.eddy_outlier_free_data.nii.gz
# -------------------------------------------------------------------
# --imain NOT corrected for susceptibility or EC-induced distortion,
# or movement, but with outlier slices replaced by Gaussian Process
# prediction.
#
# if --mporder with value >0, my_eddy_output.eddy_movement_over_time
# -------------------------------------------------------------------
# each row for each excitation. six columns are translation in x,y,z
# followed by rotations around x,y,z.
#
# my_eddy_output.eddy_cnr_maps 
# my_eddy_output.eddy_residuals
# refer to https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/eddy/UsersGuide/#A--slm






























































