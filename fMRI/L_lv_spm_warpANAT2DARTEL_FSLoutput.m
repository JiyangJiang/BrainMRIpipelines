function L_lv_spm_warpANAT2DARTEL_FSLoutput (cohortFolder, N_grps, CNSpath, SPMpath, N_cpucores)

addpath (SPMpath, [CNSpath '/Scripts']);

for i = 1 : N_grps

	list_c1 = dir ([cohortFolder '/spm/grp' num2str(i) '/c1*_anat.nii']);

	[N_subj, ~] = size (list_c1);

	parfor (j = 1 : N_subj, N_cpucores)
	
		c1subjID = strsplit (list_c1(j).name, '_');
		c1subjID = c1subjID{1};
		subjID = strsplit (c1subjID, 'c1');
		subjID = subjID{2};

		rfunc = [cohortFolder '/spm/coreg_epi_anat/r' subjID '_preproc_func_indSpace.nii'];
		anat  = [cohortFolder '/spm/grp' num2str(i) '/' subjID '_anat.nii'];
		c2    = [cohortFolder '/spm/grp' num2str(i) '/c2' subjID '_anat.nii'];
		c3    = [cohortFolder '/spm/grp' num2str(i) '/c3' subjID '_anat.nii'];

		flowmap = [cohortFolder '/spm/grp' num2str(i) '/u_rc1' subjID '_anat_Template.nii'];

		wrfunc = CNSP_nativeToDARTEL (rfunc, flowmap);
		wc1    = CNSP_nativeToDARTEL ([list_c1(j).folder '/' list_c1(j).name], flowmap);
		wc2    = CNSP_nativeToDARTEL (c2, flowmap);
		wc3    = CNSP_nativeToDARTEL (c3, flowmap);
		wanat  = CNSP_nativeToDARTEL (anat, flowmap);
		% wc2    = CNSP_nativeToDARTEL ([list_c1(j).folder '/c2' subjID '_anat.nii'], flowmap);
		% wc3    = CNSP_nativeToDARTEL ([list_c1(j).folder '/c3' subjID '_anat.nii'], flowmap);

	end
end