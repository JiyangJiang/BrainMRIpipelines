
% 
% (run_id=0) means there's only one run. (run_id=1 and run_id=2) means there're
% two runs.

bmp_oasis3_dir = fullfile (getenv ('BMP_PATH'), 'ASL', '202403_proc_OASIS3_ASL');
addpath (bmp_oasis3_dir);
oasis3_asl_nii_list_txt = fileread (fullfile (bmp_oasis3_dir,'asl_nii_list.txt'));

% % XPS13 only
bmp_oasis3_dir = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\BrainMRIpipelines\ASL\202403_proc_OASIS3_ASL';
addpath (bmp_oasis3_dir);
oasis3_asl_nii_list_txt = fileread (fullfile (bmp_oasis3_dir,'asl_nii_list.txt'));

% Tower
oasis3_asl_nii_list_txt = fileread ('/d/oasis/3/downloadWithOasisScripts/bids-oasis/asl_nii_list.txt');


oasis3_asl_nii_list = regexp(oasis3_asl_nii_list_txt, '\r?\n', 'split')';
oasis3_asl_nii_list = oasis3_asl_nii_list (~cellfun(@isempty, oasis3_asl_nii_list)); % remove empty cells

oasis3_asl_nii_list_parts = cellfun(@(x) strsplit(x,'/'), oasis3_asl_nii_list, 'UniformOutput', false);

tmp1 = cellfun(@(x) strsplit(x{:,1},'-'), oasis3_asl_nii_list_parts, 'UniformOutput', false);
subj_id = cellfun(@(x) x{2}, tmp1, 'UniformOutput', false);

tmp2 = cellfun(@(x) strsplit(x{:,2},'-'), oasis3_asl_nii_list_parts, 'UniformOutput', false);
sess_id = cellfun(@(x) x{2}, tmp2, 'UniformOutput', false);

tmp3 = cellfun(@(x) strsplit(x{:,4},'run-'), oasis3_asl_nii_list_parts, 'UniformOutput', false);
run_id = zeros(length(oasis3_asl_nii_list),1);
for i = 1:length(oasis3_asl_nii_list)
	if length(tmp3{i}) == 2
		if strcmp(tmp3{i}{2},'01_asl.nii.gz')
			run_id(i,1) = 1;
		elseif strcmp(tmp3{i}{2},'02_asl.nii.gz')
			run_id(i,1) = 2;
		end
	end
end
