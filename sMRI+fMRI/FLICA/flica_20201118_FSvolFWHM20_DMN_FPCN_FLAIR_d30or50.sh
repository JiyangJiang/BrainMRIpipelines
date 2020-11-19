addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/Software/flica_Jmod');

% note / in the end of outdir path
outdir = '/data4/jiyang/MW24+SCS_FLICA/flica/flica_20201118_FSvolFWHM20_DMN_FPCN_FLAIR_d50/';
outdir = '/data4/jiyang/MW24+SCS_FLICA/flica/flica_20201118_FSvolFWHM20_DMN_FPCN_FLAIR_d30/';

Yfiles = {
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.volume.20.mgh']
	['/data4/jiyang/MW24+SCS_FLICA/flica/DMN_Zmap_N310.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/FPCN_Zmap_N310.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/NBTRwrFLAIRrestore_N310_fwhm5.nii.gz']
};

[Y,fileinfo] = flica_load(Yfiles);
fileinfo.shortNames = {'FSvol','dmn','fpcn','flair'};

opts = struct();
opts.num_components = 50;
opts.num_components = 30;
opts.maxits = 1000;
opts.calcFits = 'all';

Morig = flica(Y, opts);