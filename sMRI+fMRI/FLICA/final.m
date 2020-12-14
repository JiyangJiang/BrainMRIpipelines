addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/Software/flica_Jmod');

flica_dir= '/data4/jiyang/MW24+SCS_FLICA/new_flica';
outdir = '/data4/jiyang/MW24+SCS_FLICA/new_flica/d70/';

Yfiles = {
	[flica_dir '/all_cat12vbm_N295_4D_demeanVarnorm.nii.gz']
	[flica_dir '/?h.g1v0.thickness.10_demeanVarnorm.mgh']
	[flica_dir '/?h.g1v0.area.pial.10_demeanVarnorm.mgh']
	[flica_dir '/all_FLAIR_N295_4D_fwhm5_demeanVarnorm.nii.gz']
	[flica_dir '/all_FA_skeletonised_demeanVarnorm.nii.gz']
	[flica_dir '/all_MD_skeletonised_demeanVarnorm.nii.gz']
	[flica_dir '/all_MO_skeletonised_demeanVarnorm.nii.gz']
	[flica_dir '/all_dmn_N295_4D_demeanVarnorm.nii.gz']
	[flica_dir '/all_fpcn_N295_4D_demeanVarnorm.nii.gz']
};

[Y,fileinfo] = flica_load(Yfiles);
fileinfo.shortNames = {'vbm','thickness','area','flair','fa','md','mo','dmn','fpcn'};

opts = struct();
opts.num_components = 70;
opts.maxits = 5000;
opts.calcFits = 'all';

Morig = flica(Y, opts);
[M,weights] = flica_reorder(Morig);
flica_save_everything(outdir, M, fileinfo);

clear des
des.Subject_Index = (1:size(Y{1},2))';
des.Age = load('/data4/jiyang/MW24+SCS_FLICA/new_flica/covariates/age_N295.txt');
des.Sex = load('/data4/jiyang/MW24+SCS_FLICA/new_flica/covariates/sex_N295.txt');
des.Edu = load('/data4/jiyang/MW24+SCS_FLICA/new_flica/covariates/edu_N295.txt');
des.ICV = load('/data4/jiyang/MW24+SCS_FLICA/new_flica/covariates/cat12icv_N295.txt');
flica_posthoc_correlations(outdir, des)