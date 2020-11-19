addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/Software/flica_Jmod');

outdir = '/data4/jiyang/MW24+SCS_FLICA/flica/flica_20201118_FSthickAreaFWHM20_DMN_FPCN_FLAIR_d50/';
outdir = '/data4/jiyang/MW24+SCS_FLICA/flica/flica_20201118_FSthickAreaFWHM20_DMN_FPCN_FLAIR_d30/';

Yfiles = {
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.thickness.20.mgh']
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.area.pial.20.mgh']
	['/data4/jiyang/MW24+SCS_FLICA/flica/DMN_Zmap_N310.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/FPCN_Zmap_N310.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/NBTRwrFLAIRrestore_N310_fwhm5.nii.gz']
};

[Y,fileinfo] = flica_load(Yfiles);
fileinfo.shortNames = {'thickness','area','dmn','fpcn','flair'};

opts = struct();
opts.num_components = 50;
opts.num_components = 30;
opts.maxits = 1000;
opts.calcFits = 'all';

Morig = flica(Y, opts);
[M,weights] = flica_reorder(Morig); % Sort components sensibly
flica_save_everything(outdir, M, fileinfo);