%-----------------------------------------------------------------------
% Job saved on 18-Apr-2019 12:28:01 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

function L_lv_spm_runDARTELc (cohortFolder, N_grps, SPMpath)

addpath (SPMpath);


for i = 1 : N_grps

  spm('defaults', 'fmri');
  spm_jobman('initcfg');

  rc1_list = dir ([cohortFolder '/spm/grp' num2str(i) '/rc1*.nii']);
  rc2_list = dir ([cohortFolder '/spm/grp' num2str(i) '/rc2*.nii']);
  rc3_list = dir ([cohortFolder '/spm/grp' num2str(i) '/rc3*.nii']);


  rcALL_cellArr = cell (3,1);

  rc1_cellArr = cell (size (rc1_list,1), 1);
  rc2_cellArr = cell (size (rc2_list,1), 1);
  rc3_cellArr = cell (size (rc3_list,1), 1);

  for j = 1 : size (rc1_list,1)
    rc1_cellArr{j} = [rc1_list(j).folder '/' rc1_list(j).name];
    rc2_cellArr{j} = [rc2_list(j).folder '/' rc2_list(j).name];
    rc3_cellArr{j} = [rc3_list(j).folder '/' rc3_list(j).name];
  end

  %%
  matlabbatch{1}.spm.tools.dartel.warp.images = {
                                                 rc1_cellArr
                                                 rc2_cellArr
                                                 rc3_cellArr
                                                 }';
  %%
  matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
  matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
  matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
  matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
  matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
  matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;

  output = spm_jobman ('run',matlabbatch);

end