
# create brain mask in T1 space with c1/c2/c3
for i in SCS.list W2.list W4.list
do
	while read id
	do
		fslmaths c123/c1sub-${id}*_anat.nii \
				 -add c123/c2sub-${id}*_anat.nii \
				 -add c123/c3sub-${id}*_anat.nii \
				 -thr 0.3 \
				 -bin \
				 -fillh \
				 -ero \
				 -ero \
				 ${id}_T1_brainmask
	done < ${i}
done


# create spherical ROI from published world-coordinate for fMRI
# --------------------------------------------------------------
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



# ++++++++++++++++++++++++++++++++++
#              FLICA
# ++++++++++++++++++++++++++++++++++
#
# MATLAB code
#
addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/Software/flica_Jmod');

% note / in the end of outdir path
outdir = '/data_int/jiyang/FLICA/no_dementia/output_FSLVBMs2_FLAIR_DMN_FPCN_d100_5000perm_onGRID/';

% DMN and FPCN using seed
Yfiles = {
['/data_int/jiyang/FLICA/no_dementia/GM_mod_merg_s2_N319.nii.gz'],
['/data_int/jiyang/FLICA/no_dementia/NBTRwrFLAIRrestore_N319.nii.gz'],
['/data_int/jiyang/FLICA/no_dementia/DMN_Zmap_N319.nii.gz'],
['/data_int/jiyang/FLICA/no_dementia/FPCN_Zmap_N319.nii.gz']
};

[Y,fileinfo] = flica_load(Yfiles);
fileinfo.shortNames = {'fslvbm_s2','FLAIRintensity','DMNactivationMap','FPCNactivationMap'};

opts = struct();
opts.num_components = 100;
opts.maxits = 5000;
opts.calcFits = 'all'; % Be more careful, check F increases every iteration.

% Run FLICA
Morig = flica(Y, opts);
[M,weights] = flica_reorder(Morig); % Sort components sensibly
flica_save_everything(outdir, M, fileinfo);

% post hoc correlation
% Jmod - this part is different from Smith 2019 code.
%        this part is according to online FLICA instruction.
clear des
des.Subject_Index = (1:size(Y{1},2))';
des.Age = load('/data_int/jiyang/FLICA/no_dementia/age_N319.txt');
des.Sex = load('/data_int/jiyang/FLICA/no_dementia/sex_N319.txt');
des.Edu = load('/data_int/jiyang/FLICA/no_dementia/edu_N319.txt');
des.ICV = load('/data_int/jiyang/FLICA/no_dementia/TIVfromCAT12_N319.txt');
flica_posthoc_correlations(outdir, des)


# SHELL
# generate reports (using high resolution output)
#
cd /data_int/jiyang/FLICA/no_dementia/output_FSLVBMs2_FLAIR_DMN_FPCN_d100_5000perm_onGRID
export PATH=/home/jiyang/Software/flica_Jmod:$PATH
mv niftiOut_mi2.nii.gz niftiOut_mi2_DARTEL.nii.gz
flirt -in niftiOut_mi2_DARTEL -ref ../DARTEL2MNI/MNI152_T1_2mm_brain.nii.gz -init ../DARTEL2MNI/dartel2mni.mat -applyxfm -out niftiOut_mi2
# Ref : https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;32d186a0.0812
mv niftiOut_mi3.nii.gz niftiOut_mi3_4mm.nii.gz;flirt -in niftiOut_mi3_4mm.nii.gz -ref ../DARTEL2MNI/MNI152_T1_2mm_brain.nii.gz -init ../eye.mat -applyxfm -out niftiOut_mi3
mv niftiOut_mi4.nii.gz niftiOut_mi4_4mm.nii.gz;flirt -in niftiOut_mi4_4mm.nii.gz -ref ../DARTEL2MNI/MNI152_T1_2mm_brain.nii.gz -init ../eye.mat -applyxfm -out niftiOut_mi4
render_lightboxes_all.sh
flica_html_report.sh


# SHELL
# Calculation of the variance explained
#
cd /data_int/jiyang/FLICA/no_dementia/output_FSLVBMs2_FLAIR_DMN_FPCN_d100_5000perm_onGRID
fslmaths niftiOut_mi1.nii.gz -sqr tmp1.nii.gz;fslstats -t tmp1.nii.gz -m > energy1.txt;fslmaths niftiOut_mi2.nii.gz -sqr tmp2.nii.gz;fslstats -t tmp2.nii.gz -m > energy2.txt;fslmaths niftiOut_mi3.nii.gz -sqr tmp3.nii.gz;fslstats -t tmp3.nii.gz -m > energy3.txt;paste energy1.txt energy2.txt energy3.txt > energy_tmp.txt

%% In MATLAB
cd /data_int/jiyang/FLICA/no_dementia/output_FSLVBMs2_FLAIR_DMN_FPCN_d100_5000perm_onGRID
energy_tmp = load ('energy_tmp.txt');
energy = energy_tmp * diag(1./sum(energy_tmp)) * 100;
fid_energy = fopen('energy.txt','w');
for i = 1:size(energy,1)
	fprintf(fid_energy,'%.5f\t%.5f\t%.5f\n',energy(i,1),energy(i,2),energy(i,3));
end

% save environment/variables in MATLAB
cd /data_int/jiyang/FLICA/no_dementia
save ('output_FSLVBMs2_FLAIR_DMN_FPCN_d100_5000perm_onGRID', '-v7.3');