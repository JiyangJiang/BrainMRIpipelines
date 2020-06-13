function L_lv_spm_regEPI2ANAT_FSLoutput (cohortFolder, N_vol_preproc_epi, CNSpath, SPMpath, N_cpucores)

addpath ([CNSpath '/Scripts'], SPMpath);

list = dir ([cohortFolder '/spm/coreg_epi_anat/*_anat.nii']);

[Nsubj, ~] = size (list);

parfor (i = 1 : Nsubj, N_cpucores)

	temp = strsplit (list(i).name, '_');
	subjID = temp{1};

	eg_func = [list(i).folder '/' subjID '_example_func.nii'];
	anat = [list(i).folder '/' list(i).name];
	preproc_func = [list(i).folder '/' subjID '_preproc_func_indSpace.nii'];

	preproc_func_cellArr = cell (N_vol_preproc_epi, 1);

	for j = 1 : N_vol_preproc_epi
		preproc_func_cellArr{j,1} = [preproc_func ',' num2str(j)];
	end

	matlabbatch = [];   % preallocate to enable parfor
	spm('defaults', 'fmri');
    spm_jobman('initcfg');

	matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[anat ',1']};
	matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[eg_func ',1']};
	%%
	matlabbatch{1}.spm.spatial.coreg.estwrite.other = preproc_func_cellArr;
	%%
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

	output = spm_jobman ('run',matlabbatch);
	
end