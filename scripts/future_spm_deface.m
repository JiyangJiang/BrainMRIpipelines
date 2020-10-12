function defaced_nii = future_spm_deface (folder)

if 7==exist(fullfile(folder,'future_spm_deface'),'dir')
	st = rmdir(fullfile(folder,'future_spm_deface'),'s');
end

if size(dir(fullfile(folder,'*.gz')),1) == 0
	mkdir (fullfile(folder,'future_spm_deface'));
else
	gunzipped_nii = future_io_gunzip ('dir',folder,fullfile(folder,'future_spm_deface'));
end

nii = dir (fullfile(folder,'*.nii'));

for i = 1 : size(nii,1)
	copyfile (fullfile(folder,nii(i).name),fullfile(folder,'future_spm_deface'));
end

all_nii = dir (fullfile(folder,'future_spm_deface','*.nii'));

all_nii_cellArr = cell (size(all_nii,1),1);

for i = 1 : size(all_nii,1)
	all_nii_cellArr{i,1} = fullfile(folder,'future_spm_deface',all_nii(i).name);
end

% auto reorient
future_spm12_autoReorient (all_nii_cellArr);

% deface
job.images = all_nii_cellArr; % same path and filenames after auto reorient
defaced_nii = spm_deface (job.images);

% visualise
future_io_visualiseImg (fullfile(folder,'future_spm_deface','anon_*.nii'));
