# FreeSurfer thickness and pial area maps
# ==============================================================

# export SUBJECTS_DIR=/data4/jiyang/MW24+SCS_FLICA/freesurfer
# ln -s /data_pub/Software/FreeSurfer/FS-7.1.0/subjects/fsaverage ${SUBJECTS_DIR}/.
# for i in lh rh
# do
#         for j in thickness area.pial
#         do
#                 mris_preproc --fsgd g1v0.fsgd \
#                                          --target fsaverage \
#                                          --hemi ${i} \
#                                          --meas ${j} \
#                                          --out ${i}.g1v0.${j}.00.mgh
#         done
# done
# for m in lh rh
# do
#         for n in thickness area.pial
#         do
#                 for k in 5 10 15
#                 do
#                         mri_surf2surf --hemi ${m} \
#                                                   --s fsaverage \
#                                                   --sval ${m}.g1v0.${n}.00.mgh \
#                                                   --fwhm ${k} \
#                                                   --cortex \
#                                                   --tval ${m}.g1v0.${n}.${k}.mgh
#                 done
#         done
# done



# FSLVBM
# ==============================================================
# 1. use brainmask.mgz from FreeSurfer's recon-all output
# 2. run from fslvbm step 2



# DMN & FPCN activation maps
# ==============================================================
#
# 1. Open the standard brain (4mm in this case) with FSLVIEW
#
# 2. DMN and FPCN seeds are according to 
#
#
# 		Table 2 of https://www.jneurosci.org/content/35/15/6068#sec-2
#
#										  coordinates (mm)			coordinates (voxel) -- 4mm MNI brain
#                                         ----------------          ------------------------------------
#		DMN (mPFC)							1	40	19							22	41	22
#		DMN (PCC/retrosplenial cortex)		-1	-53	25							22	18	24
#		DMN (L IPL)							-45	-70	24							33	14	24
#		DMN (R IPL)							53	-68	25							9	14	24
#		FPCN (L IPS)						-31	-63	42							30	15	28
#		FPCN (R IPS)						30	-65	39							15	15	27
#		FPCN (L dlPFC)						-43	21	38							33	36	27
#		FPCN (R dlPFC)						43	21	38							11	36	27
#
#
#		Table S3 of https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3222858/
#
#                                                                             coordinates (mm)		coordinates (voxel) -- 4mm MNI brain
#                                                                             ----------------      ------------------------------------
#		Dosenbach et al, 2007	Fronto-parietal task control	R dlPFC			46	28	31						11	38	25
# 		Dosenbach et al, 2007	Fronto-parietal task control	L dlPFC			-44	27	33						33	38	26
# 		Dosenbach et al, 2007	Fronto-parietal task control	R frontal		44	8	34						11	33	26
# 		Dosenbach et al, 2007	Fronto-parietal task control	L frontal		-42	7	36						33	33	27
# 		Dosenbach et al, 2007	Fronto-parietal task control	R IPL			54	-44	43						9	20	28
# 		Dosenbach et al, 2007	Fronto-parietal task control	L IPL			-53	-50	39						35	19	27
# 		Dosenbach et al, 2007	Fronto-parietal task control	R IPS			32	-59	41						14	16	28
# 		Dosenbach et al, 2007	Fronto-parietal task control	L IPS			-32	-58	46						30	17	29
# 		p.c. Marc Raichle		Default mode network			PCC				1	-51	29						22	18	25
# 		p.c. Marc Raichle		Default mode network			mPFC			-1	61	22						22	46	23
# 		p.c. Marc Raichle		Default mode network			L AG			-48	-66	34						34	15	26
# 		p.c. Marc Raichle		Default mode network			R AG			53	-61	35						9	16	26
# 		p.c. Marc Raichle		Default mode network			L lat temp		-65	-23	-9						38	25	15
# 		p.c. Marc Raichle		Default mode network			R lat temp		61	-21	-12						7	26	15
#
#
#		+++ April 20, 2020 - selected LR dlPFC + LR IPS for FPCN, and PCC + mPFC + LR AG for DMN from the second table
#
# 3. In the second column of X/Y/Z coordinate (coordinate in mm), input the above numbers.
#
# 4. Notice the corresponding X/Y/Z coordinate in the first column (voxel coordinate).
#
# 5. For each seed draw the voxel on an image with same dimension as standard brain
#
# 		fslmaths MNI152_T1_4mm_brain -mul 0 -add 1 -roi 11 1 38 1 25 1 0 1 FPCN_r_dlPFC_point_4mm -odt float
#
#		fslmaths MNI152_T1_4mm_brain -mul 0 -add 1 -roi 33 1 38 1 26 1 0 1 FPCN_l_dlPFC_point_4mm -odt float
#
#		fslmaths MNI152_T1_4mm_brain -mul 0 -add 1 -roi 14 1 16 1 28 1 0 1 FPCN_r_IPS_point_4mm -odt float
#
#		fslmaths MNI152_T1_4mm_brain -mul 0 -add 1 -roi 30 1 17 1 29 1 0 1 FPCN_l_IPS_point_4mm -odt float
#
# 6. combine all seed voxels into a single nii
#
# 		fslmaths FPCN_r_dlPFC_point_4mm -add FPCN_l_dlPFC_point_4mm -add FPCN_r_IPS_point_4mm -add FPCN_l_IPS_point_4mm FPCN_point_4mm -odt float
#
# 6. Create 6mm sphere
#
# 		fslmaths FPCN_point_4mm -kernel sphere 6 -fmean -bin FPCN_sphere6mm_bin_4mm -odt float
#
# 7. run dual regression to get individual spatial map
#
# 		dual_regression $(pwd)/RSN_seed/FPCN_sphere6mm_bin_4mm.nii.gz 1 -1 0 $(pwd)/dr $(ls -1 $(pwd)/4mm_preproc_fMRI/* | tr '\n' ' ')
#
# 		+++ do not like the auto mask from dual_regression - use my own mask
#
#		for i in `ls 4mm_preproc_fMRI/*`
#		do
#			fsl_glm -i $i -d RSN_seed/FPCN_sphere6mm_bin_4mm.nii.gz -o dr2/dr_stage1_$(basename $i | awk -F '.' '{print $1}').txt --demean -m $(pwd)/MNI152_T1_4mm_brain_mask_thr0p5_bin.nii.gz
#			fsl_glm -i $i -d dr2/dr_stage1_$(basename $i | awk -F '.' '{print $1}').txt -o dr2/dr_stage2_$(basename $i | awk -F '.' '{print $1}') --out_z=dr2/dr_stage2_$(basename $i | awk -F '.' '{print $1}')_Z --demean -m MNI152_T1_4mm_brain_mask_thr0p5_bin.nii.gz --des_norm
#		done




# 															FLAIR
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# April 23, 2020 - should use NBTR_wrFLAIR_restore which is after bias field correction
#
# 1. copied study_folder/subjects/ID/mri/preprocessing/nonBrainRemoved_wrID_FLAIR_restore.nii.gz from UBO Detector output
#
# 2. intensity normalisation
#
# 	for i in `ls FAST_nonBrainRemoved_wr*_FLAIR_restore.nii.gz`;do fslmaths $i -inm 1 $(echo $i | awk -F '.' '{print $1}')_intensityNormalised -odt float;done
#
# 3. merge into 4D
#
# 	fslmerge -t NBTR_wrFLAIR_inm_4D $(ls -1 *_intensityNormalised.nii.gz | tr '\n' ' ')
#
# 4. 2020 April 23 : Do we need to normalise intensity across 4D as well ??
#
# 5. 2020 Nov 11 : smooth (FWHM = 5 mm)
#
#   3dBlurToFWHM -input flair_4D.nii.gz -prefix flair_4D_fwhm5 -automask -FWHM 5

addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/Software/flica_Jmod');

% note / in the end of outdir path
outdir = '/data4/jiyang/MW24+SCS_FLICA/flica/flica_new20201113_fslvbm_freesurferThickArea/';

Yfiles = {
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.thickness.10.mgh']
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.area.pial.10.mgh'],
	['/data4/jiyang/MW24+SCS_FLICA/flica/GM_mod_merg_s2.nii.gz']
};

% Log-transform area; everything else uses defaults.
% Note that 4 arguments for each Yfiles input - log, subtractThis,
% divideByThis, single/double (refer to the MATLAB code)
transformsIn = {'','','',''; 'log','','',''; '','','',''};

[Y,fileinfo] = flica_load(Yfiles, transformsIn);
fileinfo.shortNames = {'Thickness','Area','VBM'};

%% Non-default option setting (to see a list of options: run flica_parseoptions, with no arguments.)
opts = struct();
opts.num_components = 70; % number of maximum components
opts.maxits = 1000;
opts.calcFits = 'all'; % Be more careful, check F increases every iteration.


% Run FLICA
Morig = flica(Y, opts);