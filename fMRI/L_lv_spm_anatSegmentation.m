function L_lv_spm_norm_segmentation (cohortFolder, N_grps, CNSpath, SPMpath, N_cpucores)

addpath ([CNSpath '/Scripts'], SPMpath);

for i = 1 : N_grps
	list = dir ([cohortFolder '/spm/grp' num2str(i) '/*_anat.nii']);
	[N_subj, ~] = size (list);

	parfor (j = 1 : N_subj, N_cpucores)
		[c1,c2,c3,rc1,rc2,rc3] = CNSP_segmentation ([list(j).folder '/' list(j).name], SPMpath);
	end
end