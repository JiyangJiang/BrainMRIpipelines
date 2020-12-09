# demean + varnorm
# +++++++++++++++++
# fslmaths 4d -Tmean -mul -1 -add 4d demeaned_4d
# fslmaths 4d -Tstd 4d_Tstd
# fslmaths demeaned_4d -div 4d_Tstd 4d_demean_varnorm
#
# for vbm map, apply MNI_2mm brain mask to 4d_demean_varnorm.
# otherwise, variance also exist outside of brain.
#
# For FreeSurfer mgh files :
#
# mri_concat 4d.mgh --o avg.mgh --mean
# mri_concat 4d.mgh --o std.mgh --std
# mri_convert 4d.mgh 3d.mgh --split
# for i in 3d????.mgh;do fscalc --o $(echo $i | cut -d. -f1)_demean.mgh $i sub avg.mgh;done
# for i in 3d????.mgh;do fscalc --o $(echo $i | cut -d. -f1)_demean_varnorm.mgh $(echo $i | cut -d. -f1)_demean.mgh div std.mgh;done
# mri_concat 3d*_demean_varnorm.mgh --o 4d_demean_varnorm.mgh

addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/Software/flica_Jmod');

% note / in the end of outdir path
outdir = '/data4/jiyang/MW24+SCS_FLICA/flica/flica_20201207_cat12vbmFWHM10_FSthickAreaFWHM10_flair_dmn_fpcn_allDemeanVarnorm_d100/';

Yfiles = {
	['/data4/jiyang/MW24+SCS_FLICA/flica/cat12vbm_N310_FWHM10mm_demeaned_varnorm_MNI2mm.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.thickness.10.demeanVarnorm.mgh']
	['/data4/jiyang/MW24+SCS_FLICA/flica/?h.g1v0.area.pial.10.demeanVarnorm.mgh']
	['/data4/jiyang/MW24+SCS_FLICA/flica/NBTRwrFLAIRrestore_N310_fwhm5_demean_varnorm_MNI2mm.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/DMN_Zmap_N310_demean_varnorm.nii.gz']
	['/data4/jiyang/MW24+SCS_FLICA/flica/FPCN_Zmap_N310_demean_varnorm.nii.gz']
};

[Y,fileinfo] = flica_load(Yfiles);
fileinfo.shortNames = {'vbm','thickness','area','flair','dmn','fpcn'};

opts = struct();
opts.num_components = 100;
opts.maxits = 1000;
opts.calcFits = 'all';

Morig = flica(Y, opts);
[M,weights] = flica_reorder(Morig);
flica_save_everything(outdir, M, fileinfo);

clear des
des.Subject_Index = (1:size(Y{1},2))';
des.Age = load('/data4/jiyang/MW24+SCS_FLICA/flica/covariates/age_N310.txt');
des.Sex = load('/data4/jiyang/MW24+SCS_FLICA/flica/covariates/sex_N310.txt');
des.Edu = load('/data4/jiyang/MW24+SCS_FLICA/flica/covariates/edu_N310.txt');
des.ICV = load('/data4/jiyang/MW24+SCS_FLICA/flica/covariates/eTIVfromFreeSurfer_N310.txt');
flica_posthoc_correlations(outdir, des)


# SHELL
# ++++++++++++++++++++++++++++++++++++++++++++++++++
# resample to MNI 2mm
mv niftiOut_mi2.nii.gz niftiOut_mi2_4mm.nii.gz
flirt -in niftiOut_mi2_4mm.nii.gz -ref ../MNI152_T1_2mm_brain.nii.gz -applyisoxfm 2 -init ../eye.mat -out niftiOut_mi2
mv niftiOut_mi3.nii.gz niftiOut_mi3_4mm.nii.gz
flirt -in niftiOut_mi3_4mm.nii.gz -ref ../MNI152_T1_2mm_brain.nii.gz -applyisoxfm 2 -init ../eye.mat -out niftiOut_mi3

export PATH=/home/jiyang/Software/flica_Jmod:$PATH
render_lightboxes_all.sh
flica_html_report.sh