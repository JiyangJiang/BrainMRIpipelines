function L_lv_spm_warpDARTEL2MNI_gmSeg (cohortFolder, N_grps, voxsiz, SPMpath, N_cpucores)

%-----------------------------------------------------------------------
% Note that only c1 is warped to MNI which will also generate Template_6_2mni.mat
% as intermediate output. This is the affine matrix which can be used
% for other DARTEL space images to MNI space, e.g. the spatial maps after
% dual regression.
%-----------------------------------------------------------------------
%
% 2019 April 30 : let preserve = 1 to enable modulation.

for i = 1 : N_grps

    list_flowmap = dir ([cohortFolder '/spm/grp' num2str(i) '/u_rc1*_anat_Template.nii']);
    [N_subj, ~] = size (list_flowmap);

    parfor (j = 1 : N_subj, N_cpucores)

        matlabbatch = [];   % preallocate to enable parfor
        spm('defaults', 'fmri');
        spm_jobman('initcfg');

        temp = strsplit (list_flowmap(j).name, '_');
        temp = temp{2};
        temp = strsplit (temp, 'rc1');
        subjID = temp{2};

        matlabbatch{1}.spm.tools.dartel.mni_norm.template = {[list_flowmap(j).folder '/Template_6.nii']};
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(1).flowfield = {[list_flowmap(j).folder '/' list_flowmap(j).name]};
        
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(1).images = {
                                                                        [list_flowmap(j).folder '/c1' subjID '_anat.nii']
                                                                        };
        matlabbatch{1}.spm.tools.dartel.mni_norm.vox = voxsiz;
        matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                                       NaN NaN NaN];
        matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 1;
        matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [8 8 8];

        output = spm_jobman ('run',matlabbatch);
    end
end

