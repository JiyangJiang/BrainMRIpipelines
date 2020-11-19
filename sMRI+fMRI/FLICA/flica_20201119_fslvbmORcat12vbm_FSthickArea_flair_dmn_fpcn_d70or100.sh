addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/Software/flica_Jmod');

outdir = '/data4/jiyang/MW24+SCS_FLICA/flica/flica_20201119_fslvbmS2_FSthickAreaFWHM10_flair_dmn_fpcn_d100/';

## fslvbm
Yfiles = {
	['/data4/jiyang/MW24+SCS_FLICA/flica/GM_mod_merg_s2_N310_brain.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.thickness.10.mgh']
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.area.pial.10.mgh']
	['/data4/jiyang/MW24+SCS_FLICA/flica/DMN_Zmap_N310.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/FPCN_Zmap_N310.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/NBTRwrFLAIRrestore_N310_fwhm5_MNI2mm.nii.gz']
};

# cat12 vbm
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# I used FLAIR and CAT12 VBM in DARTEL space
Yfiles = {
	['/data4/jiyang/MW24+SCS_FLICA/flica/cat12vbm_N310.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.thickness.10.mgh']
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.area.pial.10.mgh']
	['/data4/jiyang/MW24+SCS_FLICA/flica/DMN_Zmap_N310.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/FPCN_Zmap_N310.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/NBTRwrFLAIRrestore_N310_fwhm5.nii.gz']
};

[Y,fileinfo] = flica_load(Yfiles);
fileinfo.shortNames = {'vbm','thickness','area','dmn','fpcn','flair'};

opts = struct();
opts.num_components = 100;
opts.maxits = 5000;
opts.calcFits = 'all';

Morig = flica(Y, opts);

[M,weights] = flica_reorder(Morig); % Sort components sensibly
flica_save_everything(outdir, M, fileinfo);

clear des
des.Subject_Index = (1:size(Y{1},2))';
des.Age = load('/data4/jiyang/MW24+SCS_FLICA/flica/covariates/age_N310.txt');
des.Sex = load('/data4/jiyang/MW24+SCS_FLICA/flica/covariates/sex_N310.txt');
des.Edu = load('/data4/jiyang/MW24+SCS_FLICA/flica/covariates/edu_N310.txt');
des.ICV = load('/data4/jiyang/MW24+SCS_FLICA/flica/covariates/TIVfromCAT12_N310.txt');
flica_posthoc_correlations(outdir, des)