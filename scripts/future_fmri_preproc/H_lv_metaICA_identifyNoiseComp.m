function H_lv_metaICA_identifyNoiseComp (sptCorrTxt, N_dim_metaICA)

in_fid = fopen (sptCorrTxt, 'r');
spt_corr_data = fscanf (in_fid, '  %d   %d %f', [3 Inf]);
fclose (in_fid);

spt_corr_data = spt_corr_data';

noise_index = int16.empty;

for i = 1 : str2num (N_dim_metaICA)
	idx = find (spt_corr_data (:,1) == i);
	sptCorr_with_currMetaICAcomp = spt_corr_data (idx,:);
	N_sptCorr_lt_0p6 = sum (sptCorr_with_currMetaICAcomp (:,3) > 0.6);

	if N_sptCorr_lt_0p6 == 0
		noise_index (end+1,1) = i;
	end
end

[sptCorrTxt_folder,sptCorrTxt_filename,~] = fileparts (sptCorrTxt);

% write to txt
out_fid = fopen ([sptCorrTxt_folder '/' sptCorrTxt_filename '_excldIDX_startFrom1.txt'], 'w');
fprintf (out_fid, '%d\n', noise_index);
fclose (out_fid);