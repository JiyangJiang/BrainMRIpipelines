addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/Software/flica_Jmod');

flica_dir= '/data4/jiyang/MW24+SCS_FLICA/new_flica';
outdir = '/data4/jiyang/MW24+SCS_FLICA/new_flica/d100/';

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
opts.num_components = 100;
opts.maxits = 5000;
opts.calcFits = 'all';

Morig = flica(Y, opts);