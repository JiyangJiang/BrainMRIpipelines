#!/bin/bash

tutorialDir=/Users/jiyang/Desktop/MRtrix3_tutorial_BATMAN

cd ${tutorialDir}/DWI



# ================================================================ #
#                  2. DWI data preprocessing                       #
# ================================================================ #


# 2.1 Preparatory steps
# ---------------------------------------------------------------------------------------
# concatenate all b-images into MRtrix's data format (.mif)
mrcat -force \
	  b1000_AP \
	  b2000_AP \
	  b3000_AP \
	  dwi_raw.mif
# -force to overwrite previous

# 2.2 Denoising
# ---------------------------------------------------------------------------------------
# denoising
# Purpose : estimate the spatially varying noise map
dwidenoise dwi_raw.mif \
		   dwi_den.mif \
		   -noise noise.mif

# inspect the results
# calculate the difference between the raw and denoised images (residual), and mrview them.
# Also mrview the noise map
mrcalc dwi_raw.mif \
	   dwi_den.mif \
	   -subtract residual.mif

mrview residual.mif \
	   noise.mif

# 2.3 Unringing
# ---------------------------------------------------------------------------------------
# unringing
# Purpose : remove Gibb's ringing artefacts
mrdegibbs dwi_den.mif \
		  dwi_den_unr.mif \
		  -axes 0,1
# -axes 0,1 : acquired axial slices
# -axes 0,2 : acquired coronal slices
# -axes 1,2 : acquired sagittal slices

# J : mrdegibbs should be run before any interpolation, before any motion correction,
#     (e.g. should be before dwipreproc), after dwidenoise (since mrdegibbs alters noise
#     structure which would impact on dwidenoise)

# inspect the results
# - residual between denoised and denoised+unringed
# - denoised+unringed
mrcalc dwi_den.mif \
	   dwi_den_unr.mif \
	   -subtract residualUnringed.mif

mrview residualUnringed.mif \
	   dwi_den_unr.mif

# 2.4 Motion and distortion correction
# ---------------------------------------------------------------------------------------
# Purposes:
#
# - susceptibility-induced geometric distortion correction (FSL's topup)
#
# - Eddy-current-induced distortion correction (FSL's eddy)
#
# - inter-volume subject motion correction (done by dwipreproc via passing the first b=0
#                                           volume as the first volume of the image file
#                                           passed to -se_epi option)
#
#
# in tutorial data, several b0 images in both PE directions are acquired in order to take
# the average which will produce a cleaner b0 for each PE direction.
#
# extract b0 from dwi_den_unr.mif
dwiextract dwi_den_unr.mif - -bzero | mrmath - mean mean_b0_AP.mif -axis 3
# "-" is used to transfer data from the front command to the back one, i.e. the output
# from the first command "-" is transfered to the second command as input.
#
# -axis 3 : average image along the third axis (starting from 0). 3 means time axis.
#
# -bzero : Output b=0 volumes

# calculate the mean image of the b0s with revised phase encoding direction
mrconvert b0_PA - | mrmath - mean mean_b0_PA.mif -axis 3

# - further processing requires concatenating the two mean b0s into one file.
# - Note that the order matters !!!
# - MRtrix expects the first image to be the b0 in PE direction, and the last to be the b0
#   in reversed PE direction.
mrcat mean_b0_AP.mif mean_b0_PA.mif -axis 3 b0_pair.mif

# visualise as overlay
mrview mean_b0_AP.mif -overlay.load mean_b0_PA.mif

# - Both motion and distortion correction are done by dwipreproc.
# - specify PE direction with -pe_dir
# - we use the b0-paired option (-rpe_pair) for EPI inhomogeneity correction. Other ways 
#   can refer to help page.
# - b0_pair file is passed via -se_epi option, which will call FSL's topup
# - adjust options on how MRtrix should call FSL's eddy tool via -eddy_options
# - In the case of this tutorial, select option -slm=linear, which will correct for the 
#   fact that in the two shells, b=1000 and b=2000, sampling is moderately asymmetric due
#   to few directions.
dwipreproc dwi_den_unr.mif \
		   dwi_den_unr_preproc.mif \
		   -pe_dir AP \
		   -rpe_pair \
		   -se_epi b0_pair.mif \
		   -eddy_options " --slm=linear"
# Note -eddy_options : options are passed within double quotes
#                      after the opening quote, an empty space must follow
#                      options are called with a double hyphen		   


# 2.5 Bias field correction
# ---------------------------------------------------------------------------------------
# - Purpose : correct for B1 bias field inhomogeneity (i.e. intensity inhomogeneity) (using N4)
#
# - Note this is meant to improve brain mask estimation which will be performed hereafter.
# - if no strong bias field, runing this will deteriorate brain mask estimation, resulting
#   in inferior brain mask estimation.
# !!! always check the subsequently generated brain mask if including dwibiascorrect in the
#     pipeline
#
# - recommend using dwibiascorrect with -ants option
#
# - -bias option will output the estimated bias field

# bias field correction
dwibiascorrect -ants dwi_den_unr_preproc.mif dwi_den_unr_preproc_unbiased.mif -bias bias.mif

# visualise bias field
mrview bias.mif -colourmap 2


# 2.6 Brain mask estimation
# ---------------------------------------------------------------------------------------
# Purpose : create brain binary mask. Downstream analyses will be performed within this
#           mask to improve biological plausibility of streamlines and reduce computation
#           time.
dwi2mask dwi_den_unr_preproc_unbiased.mif \
		 mask_dwi_den_unr_preproc_unbiased.mif

# visualisation and check the brain mask
mrview dwi_den_unr_preproc_unbiased.mif -overlay.load mask_dwi_den_unr_preproc_unbiased.mif





# ================================================================= #
#                  3. Fiber orientation distribution                #
# ================================================================= #

# 3.1 Response function estimation
# ---------------------------------------------------------------------------------------
# - To create the streamlines, we first need to estimate the orientation of the fibers
#   in each voxel. In MRtrix, we do this with constrained spherical deconvolution (CSD),
#   instead of the tensor model, because CSD outperforms DTI in regions of crossing/kissing
#   fibers.
#
# - To perform CSD, response function (RF) is necessary which is used as a kernel for
#   deconvolution.
#
# - For example, the RF in WM models the signal which is expected if there was only a fiber
#   bundle with one coherent orientation present in that voxel.
# - However, there are many voxels that are voxels so-called partial volumes, i.e., voxels
#   containing both WM and GM, or such with WM and CSF. CSD will be flawed in such voxels.
# - We can improve results in such regions if we estimate different RFs for different tissue
#   types.
# - This is best done with DW data with different b-values, since different tissue types
#   are best sensitive for different b-values. This idea is at the core of so-called
#   multi-shell multi-tissue CSD (MSMT, Jeurissen et al., 2014)

# response function estimation
dwi2response dhollander dwi_den_unr_preproc_unbiased.mif \
						wm.txt \
						gm.txt \
						csf.txt \
						-voxels voxels.mif
# - Note that the output order is always WM, GM, CSF
# - -voxels option outputs image of the voxels which are selected for the response function
#   estimation of each tissue type.

# visualisation
mrview dwi_den_unr_preproc_unbiased.mif -overlay.load voxels.mif

# visualise WM response function at different shells (press right arrow)
shview wm.txt
# !!! The flatter the response function, the higher the angular resolution and ultimately, the
#     smaller cross-fiber-angles can be resolved.
#
# However, higher b-values result in lower SNR.

# visualise GM response function at different shells (press right arrow)
shview gm.txt
# - GM always has a spherical shape of response function. This is because GM is by nature
#   isotrophic (water can diffuse freely and is not restricted).
#
# - However, larger b-values correspond to smaller amplitudes. This means that the isotropy
#   of GM can be most sensitively estimated with b0, but with gradient directions (b1000/2000/3000)
#   the algorithm still estimates GM to be isotrophic, although at diminishing amplitudes.

# visualise CSF response function at different shells (press right arrow)
shview csf.txt
# - The response function of CSF is also spherical, as CSF is isotrophic by nature.
#
# - unlike GM, CSF response function can almost only be estimated from the b0 data. When the
#   direction gradients are switched on, the amplitude of the response function gets so small
#   that it is almost invisible. This means that CSF isotropy is only estimated with b0.
#
# - With this information, it is possible to differenciate GM from CSF : although both are
#   isotropic, they show different amplitudes for different b-values.
#
# - With this information, the downstream fiber orientation distribution and tracking are
#   enhanced for those voxels with partial volumes. This is another core idea of MSMT.


# 3.2 Estimation of Fiber Orientation Distributions (FOD)
# ---------------------------------------------------------------------------------------
# Purpose : in every voxel, estimate the orientation of all fibers crossing that voxel.

# estimate FOD
dwi2fod msmt_csd dwi_den_unr_preproc_unbiased.mif \
				 -mask mask_dwi_den_unr_preproc_unbiased.mif \
				 wm.txt wmfod.mif \
				 gm.txt gmfod.mif \
				 csf.txt csffod.mif

# display WM FOD on a map which shows the estimated volume fraction of each tissue type
mrconvert -coord 3 0 wmfod.mif - | mrcat csffod.mif gmfod.mif - vf.mif
# -coord 3 0 : extract the first volume from a 4D image. "-coord 1 24" extract slice
#              number 24 along the y-axis. wmfod.mif has 45 volumes, while gmfod.mif
#              and csffod.mif have only one volume (Why?). This is why extracting the
#              first volume from wmfod.mif, and concatenate with gmfod.mif and csffod.mif.
#
# Note that here mrcat creates a volume fraction map. If there are three mif inputs to
# the 3rd one will be the last volume of the mrcat output, and the second volume of mrcat
# output is 3rd mrcat input plus 2nd mrcat input, and the first volume of mrcat output is
# the sum of 1st, 2nd and 3rd mrcat input.

mrview vf.mif -odf.load_sh wmfod.mif
# -odf.load_sh : load specified SH-based ODF image on the ODF tool
# FOD is almost only performed within WM boundaries (blue areas). CSF (red areas) and GM
# (green areas) are free from FODs.


# 3.3 Intensity Normalisation of the FOD maps
# ---------------------------------------------------------------------------------------
# Purpose : Correct for global intensity differences of FOD maps, especially important
#           when performing group studies.

# FOD intensity normalisation
mtnormalise wmfod.mif wmfod_norm.mif \
			gmfod.mif gmfod_norm.mif \
			csffod.mif csffod_norm.mif \
			-mask mask_dwi_den_unr_preproc_unbiased.mif

# visualise
mrconvert -coord 3 0 wmfod_norm.mif - | mrcat gmfod_norm.mif - csffod_norm.mif vf_norm.mif
mrview vf_norm.mif -odf.load_sh wmfod_norm.mif



# ====================================================================== #
#               4. Creating a whole-brain tractogram                     #
# ====================================================================== #

# 4.1 Preparing for Anatomically Constrained Tractography (ACT)
# ---------------------------------------------------------------------------------------
# Purpose : Increase the biological plausibility of downstream streamline creation

# 4.1.1 Preparing a mask for streamline termination
#
# - ACT is not compulsory. With FOD, we could go straight to creating streamlines. However,
#   ACT will further increase biological plausibility of streamline creation.
# - For example, when we will perform fiber tracking later on, we will use a probabilistic 
#   algorithm which is going to identify streamlines that end, for example, in CSF. However,
#   from anatomy, we know such streamlines do not exist. ACT rejects those streamlines.
#
# - ACT requires T1-weighted data input.
#
# - To make the T1 DICOM data fit for ACT :
#
#   1) create 5tt-image, a 4D preprocessed T1w image with 5 different tissue types (cortical
#      GM, subcortical GM, WM, CSF, and pathological tissue, which is usually just an empty
#      volume).
#
#   2) coregister the 5tt-image to DWI, in order to use the information on 5tt-image to
#      restrict fiber tracking. We use the b0 image as reference, as it is not gradient-
#      weighted. Since we acquired several b0 images, we will simply take the mean. Furthermore,
#      we only need registration with 6 DOF, since the target DW image is already corrected
#      for eddy currents, movements, etc. More DOFs will not be beneficial and might even
#      introduce errors.

# creating 5tt-image
mrconvert ${tutorialDir}/T1 T1_raw.mif
5ttgen fsl T1_raw.mif 5tt_nocoreg.mif

# register 5tt to DWI (DWI -> T1raw, and then inverse and apply to 5tt)
dwiextract dwi_den_unr_preproc_unbiased.mif - -bzero | mrmath - mean mean_b0_preprocessed.mif -axis 3
mrconvert -coord 3 0 5tt_nocoreg.mif 5tt_nocoreg_vol1.mif

mrconvert mean_b0_preprocessed.mif mean_b0_preprocessed.nii.gz
mrconvert 5tt_nocoreg_vol1.mif 5tt_nocoreg_vol1.nii.gz

flirt -in mean_b0_preprocessed.nii.gz \
	  -ref 5tt_nocoreg_vol1.nii.gz \
	  -interp nearestneighbour \
	  -dof 6 \
	  -omat diff2struct_fsl.mat

transformconvert diff2struct_fsl.mat \
				 mean_b0_preprocessed.nii.gz \
				 5tt_nocoreg_vol1.nii.gz \
				 flirt_import \
				 diff2struct_mrtrix.txt

mrtransform 5tt_nocoreg.mif \
			-linear diff2struct_mrtrix.txt \
			-inverse \
			5tt_coreg.mif

# Check results by visualising coregistered and non-coregistered 5tt superimposing onto DWI
mrview dwi_den_unr_preproc_unbiased.mif \
	   -overlay.load 5tt_nocoreg.mif -overlay.colourmap 2 \
	   -overlay.load 5tt_coreg.mif -overlay.colourmap 1
	   # Note that mrview can display images with different dimensions.


# 4.1.2 Preparing a mask of streamline seeding
#
# - From anatomy, we know that the GM/WM boundary should be a reasonable starting point for streamlines.

# create GM/WM boundary as seed for streamlining
5tt2gmwmi 5tt_coreg.mif gmwmSeed_coreg.mif
# > One drawback for streamlining from GM/WM boundary is that streamlines between subcortical regions
#   are missed. This can be solved by either 1) seeding from a binary subcortical mask, and combining
#   results with GM/WM boundary seeding, or 2) start streamlining randomly within a whole-brain mask.
#   You will find details on streamline initialization on the tckgen help page.

# visualisation
mrview dwi_den_unr_preproc_unbiased.mif -overlay.load gmwmSeed_coreg.mif


# 4.2 Creating streamlines (basic options; probabilistic)
# ---------------------------------------------------------------------------------------
#
# - This example will use mostly default parameters to do a probabilistic rather than deterministic
#   tractography

# create streamlines
tckgen -act 5tt_coreg.mif \
	   -backtrack \
	   -seed_gmwmi gmwmSeed_coreg.mif \
	   -select 10000000 \
	   wmfod_norm.mif \
	   track_10mio.tck
	   # -select 10000000 : include 10 million streamlines
	   # -backtrack : an option specific to ACT and probabilistic fiber tracking, which resamples
	   #              rejected streamlines from a defined number of steps back.
	   # wmfod_norm.mif : streamline tracking is based on normalised fiber orientations of WM.
	   # track_10mio.tck : in MRtrix, files with streamlines have ending of .tck (for "tracks")


# visualisation
#
# - You could load all the 10 million streamlines, and superimpose to DW data.
#
#   mrview dwi_den_unr_preproc_unbiased.mif -tractography.load tracks_10mio.tck
#
# - However, this is not recommended as the tck file is really bid (>4.1GB)
#
# - Recommend choose a subset of the 10 million tracks with tckedit

# create a random subset (N = 200k) of the 10 mil streamlines
tckedit tracks_10mio.tck -number 200k smallerTracks_200k.tck

# view this 200k streamlines
mrview dwi_den_unr_preproc_unbiased.mif \
	   -tractography.load smallerTracks_200k.tck
	   # Red : right-left
	   # Green : anterior-posterior
	   # Blue : superior-inferior


# 4.3 Reducing the number of streamlines
# ---------------------------------------------------------------------------------------
#
# Purpose : Filtering the tractograms to reduce CSD-based bias in overestimation of longer
#           tracks compared to shorter tracks; reducing the number of streamlines.
#
# - Problem 1 : One of the pitfalls of CSD is that the density of long tracks is overestimated compared
#   to short tracks.
#
# 	- E.g., imagine two tracks - a short and a long one - but equally thick : The long track
#     will get more "hits" during probabilistic streamline creation, just because it's longer
#     and the probability of a "hit" is more likely - as a result, the thickness of the tracks
#     are overestimated.
#
# - Problem 2 : Similarly, in regions of crossing fibers, most stramlines will follow the straightest
#   path, thereby also generating a bias towards streamline density of that straight track.
#
# - The first problem can be taken care of by seeding only from GM/WM-boundary, which is what
#   we did during ACT.
#
# - The second problem can be solved by using spherical-deconvolution informed filtering of
#   tracks (SIFT).
#   
#   - SIFT filters tracks based on information drawn from CSD.
#
#   - refer to teh red insert in Figure 7 (the fiber orientation distribution in a single voxel).
#     The volume of each of those lobes gives a relative estimation of the volume of the tract
#     passing through each lobe. SIFT uses those relative estimations and filters the tractograms
#     to match those proportions.
#
#   - SIFT reduces the size of the track-file significantly.
#
#   - One problem with SIFT is that there is no straightforward recommendation on hwo long to filter.
#
#   - While SIFT is running, every streamline removal reduces a cost function, which indicates how
#     well the streamline density of the track-file fits the volume estimated from the fiber orientation
#     distribution. The more the cost function is reduced, the better the fit - but at the same time,
#     fewer streamlines mean less differential information.

# reduce 10 mil track-file by a factor of 10 using SIFT. Use ACE option to improve biological plausibility.
tcksift -act 5tt_coreg.mif -term_number 1000000 tracks_10mio.tck wmfod_norm.mif sift_1mio.tck
# - wmfod_norm.mif is used to estimate the density of each tract.
# - warning message of "quantisation error" means MRtrix thinks you are filtering too heavily

# display a random subset
tckedit sift_1mio.mif -number 200k smallerSIFT_200k.tck
mrview dwi_den_unr_preproc_unbiased.mif -tractography.load smallerSIFT_200k.mif


# 4.4 ROI filtering of tractograms
# ---------------------------------------------------------------------------------------
#
# - Sometimes, one may only be interested in the information of a specific tract (e.g.
#   corticospinal tract (CST) in this example).
#
# - This can be donw with tckedit with option -include, which filters a track-file such
#   that only those streamlines crossing the specified region remain.
#
# - You can either provide a binary mask as a ROI, or your ROI can be a coordinate
#   (x,y,z) with a specific radius.
#

# Identify the coordinates of a region within CST
#
# load the SIFT filtered track-file on DW data and find a suited spot
mrview dwi_den_unr_preproc_unbiased.mif -tractography.load smallerSIFT_200k.tck &
# choose "ortho view"
#
# - At bottom left corner, you can see both voxel- and real-world position (i.e. position
#   in millimeters) of the cursor.
#
# - The position information refers to the main image (i.e. the DWI image in this case).
#   But our track-file is in the same space as the DWI.
#
# - !!! tckedit always expect coordinate position in real-world space (i.e. in mm), not
#       in voxel space!
#
# - From visualisation, [-0.6,-16.5,-16.0] is a good spot to filter CST tracks - this is
#   right before where the CST divides into a right and a left part, so that we should
#   get both sides of CST equally well.
#
# - "View Options" from the "Tool" menu can get and set the position of cursor.
#
# ROI filtering
tckedit -include -0.6,-16.5,-16.0,3 sift_1mio.mif cst.tck
# coordinate should be given as a comma-separated list without spaces. The fourth value 
# indicates radius of sphere of ROI in millimeters.
#
# View CST on T1w
mrtransform T1_raw.mif \
			-linear diff2struct_mrtrix.txt \
			-inverse \
			T1_coreg.mif

mrview T1_coreg.mif -tractography.load cst.tck



# ================================================================================= #
#                         5. Connectome construction                                #
# ================================================================================= #
#
# 5.1 Preparing an atlas for structural connectivity analysis
# -----------------------------------------------------------------------------------
#
# Purpose : Obtain a volumetric atlas-based parcellation image, coregistered to diffusion
#           space for downstream structural connectivity (SC) matrix generation.
#
# - This tutorial will use Human Connectome Project Multi-Modal Parcellation 1.0
#   ("HCP MMP 1.0") atlas. In this atlas, regional boundaries are drawn based on
#   integrative information from cortical architecture (cortical thickness, myelin),
#   function (task-fMRI), connectivity and/or topography (rs-fMRI).

$(dirname $(which $0))/BATMAN_fitHCPMMP1toT1w_WORKFLOW.sh


# 5.2 Matrix generation
# -----------------------------------------------------------------------------------
#
# Purpose : Gain quantitative information on how strongly each atlas region is connected
#           to all others; represent it in matrix format
#
# - A straightforward way to determine the connection strength is streamline count.
#
# - Since this metric is highly dependent on the number of streamlines in the track-file
#   as well as the atlas region's volume (the bigger the volume, the more streamlines
#   will be created from that region), it is a good idea to normalise those values.
#
# - MRtrix offers different ways to scale the track count.

# scale by the atlas region's volume
tck2connectome -symmetric \
			   -zero_diagonal \
			   -scale_invnodevol \
			   sift_1mio.tck \
			   hcpmmp1_parcels_coreg.mif \
			   hcpmmp1.csv \
			   -out_assignment assignments_hcpmmp1.csv
# -symmetric : symmetrize the resulting SC matrix. If not specified, the lower triangular
#              will be left blank.
#
# -zero_diagonal : set the diagonal to zero.
#
# -out_assignment : output node assignments of each streamline to a file. This can be used
#                   by subsequent commands, line connectome2tck
#
# - hcpmmp1.csv is 379*379. 180 atlas regions on each cortical hemisphere, based on HCP MMP
#   1.0, plus 19 subcortical regions, based on FreeSurfer segmentation (9*2 homologs plus
#   brainstem)
#
# J : Note that hcpmmp1.csv is not actually a comma-segmented file. It is space-segmented.
#     read with MATLAB

# MATLAB code to read hcpmmp1.csv and display the matrix
M = dlmread ('hcpmmp1.csv', ' ');
imagesc (M)
colormap jet
colorbar
# From anatomy, many cortical regions are not structurally connected at all, but there are
# a few regions which are extremely well connected.
#
# restrict to show a certain range
caxis ([0 0.08])
# You could see :
# - SC is high intra-hemispherically.
# - high SC between spatially close regions.
# - subcortical regions connect well to cortical regions.
# - corresponding regions on left and right hemispheres (homolog) are connected (through corpus callosum)


# 5.3 Selecting connections of interest
# -----------------------------------------------------------------------------------
#
# Two strategies :
#   - selecting all streamlines that connect two regions
#   - selecting all streamlines that emerge from a region of interest
#
# - This is done by connectome2tck

# 5.3.1 Selecting connections of interest
# 
# - In this example, we chose to extract a homolog connection, since such regions should connect
#   strongly. More specifically, we are interested in the motor cortex.
#
# - In HCP MMP 1.0 atlas, motor cortices are subdivided into several subregions. One core
#   region of motor cortex is simply called "4".
#
# - We identify the indices assigned to L_4 and R_4 as 8 and 188 from the color lookup table, 
#   hcpmmp1_ordered.txt. This also corresponds to the indices in atlas-based parcellation image,
#   hcpmmp1_parcels_coreg.mif.
#
# - To identify all tracts that conenct these regions, MRtrix needs the track-file and info on
#   every single streamline about its connecting regions. This is a text file with two columns
#   and as many rows as you have streamlines (i.e. 1 million rows in our case). The first column
#   specifies the index of the starting regions and the second column is the index of the ending
#   region. This can be created with tck2connectome with -out_assignment option.
#
# extract streamlines
connectome2tck -nodes 8,188 -exclusive sift_1mio.tck assignments_hcpmmp1.csv moto
# -exclusive : only select tracks between the two regions.
# The last aregument specifies the prefix that the resultant file will have. The complete filename
# includes by default also the node indices that you are analysing, so that in our case we will get
# a file called moto8-188.tck
#
# visualise
mrview T1_coreg.mif -tractography.load moto8-188.tck

# extract the two ROIs (i.e. bilateral motor cortices)
mrcalc hcpmmp1_parcels_coreg.mif 8 -eq L_4.mif
mrcalc hcpmmp1_parcels_coreg.mif 188 -eq R_4.mif
# These two commands extract voxels that have the index 8 and 188 from parcellation image, which
# in our case corresponds to the left and right region "4" of the motor cortex.
#
# These two images (L_4.mif and R_4.mif) can be overlaid to the display
#
# L_4 and R_4 can be merged using :
# 		mrcalc L_4.mif R_4.mif -max merged_LR_4.mif

# 5.3.2 Extracting streamlines emerging from a ROI
#
# - This example extract streamlines emerging from thalamus
#
# - We analyse left (index = 362) and right (index = 372) thalamus together.
connectome2tck -nodes 362,372 sift_1mio.tck assignments_hcpmmp1.csv -files per_node thalamus
# - must NOT use -exclusive to extract streamlines emerging from ROI.
#
# - -files per_node : we want output to be one file for one ROI that we analysed. otherwise, there
#   will be one file for each ending region, which in the case of thalamus will be hundreds of files.
#
# visualise
mrview T1_coreg.mif -tractography.load thalamus362.mif
# - thalamus connects to many cortical regions, but the connection density on the ipsilateral side
#   is even stronger.


# ==================================================================================== #
#                         6. Connectome visualization tool                             #
# ==================================================================================== #
#
# - To use the connectome visualization tool, we minimally need the following two files:
#
#      1) atlas-based parcellation image
#      2) SC matrix file based on that parcellation
#
mrview hcpmmp1_parcels_coreg.mif -connectome.init hcpmmp1_parcels_coreg.mif -connectome.load hcpmmp1.csv
# - have to specify parcellation image twice
# - hit "M" to remove the 2D-parcellation, which does not make sense with the 3D connectome view.
# - The edges' color represent the connection strength. By default, on a hot colorbar.
#
# - Change color etc. : select "Connectome" option from "Tool" menu.
# 
# - Vector file : define interested nodes; "Colour" and "Transparency" in "Node visualisation" section
#                 can both be specified as "Vector File". Set to "Vector file" in "Transparency" section
#                 alone is enough to hide uninterested nodes.
#
# - To get rid of low connection strength edges, set "Threshold" in "Edge visualisation" section to for
#   example 0.1. Nodes with edges not passing the threshold can be hided by choosing "Degree >= 1" in
#   "Visibility" field in "Node visualisation" section.
#
# - Edge smoothing can give a thicker representation of edges.

# 6.2 Node geometry : Meshes
# -----------------------------------------------------------------------------------
# - MRtrix provides the possibility to represent nodes as a cortical meshes, corresponding to the
#   atlas region which they represent.
label2mesh hcpmmp1_parcels_coreg.mif hcpmmp1_mesh.obj
# Change "Geometry" in "Node visualisation" to "Mesh", and "Visibility" to "All" if necessary.

# 6.3 Edge geometry : Streamlines
# -----------------------------------------------------------------------------------
# - use the actural track route to represent edges.
#
# - To derive a single file with the mean representation of the tracks that connect all possible
#   pairs of atlas regions, we can use connectome2tck with the -exemplars option and provide the
#   atlas-based parcellation image.
connectome2tck sift_1mio.tck \
			   assignments_hcpmmp1.csv \
			   exemplar \
			   -files single \
			   -exemplars hcpmmp1_parcels_coreg.mif
			   # exemplar if the prefix of output, the output will be exemplar.tck
			   # "-file single" tells output is merged into one file
# change "Geometry" in "Edge visualisation" to "Streamline", and "Visibility" to "All"

# 6.4 Manipulating the visualization to match a research question
# -----------------------------------------------------------------------------------
# - matrix file from MATLAB can be passed via "Visibility -> Matrix file" for both nodes and edges.
#
# - To change edge threshold, change edge visibility to Connectome (or others?)
#
# - Best-connected regions of the brain are regions corresponding to vision, motor function, and language.










































































































