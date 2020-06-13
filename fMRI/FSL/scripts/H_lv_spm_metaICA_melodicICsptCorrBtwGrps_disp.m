function H_lv_metaICA_spatialCorrelationWithKnownRSNs_disp   (fsl_spatial_corr_txt, ...
															  N_vol_metaICmap)

fileID = fopen (fsl_spatial_corr_txt, 'r');

% these variables are passed from shell, therefore are string
N_vol_metaICmap = str2num (N_vol_metaICmap);


spt_corr_data = fscanf (fileID, '  %d   %d %f', [3 Inf]);
fclose (fileID);
spt_corr_data = spt_corr_data';

spt_corr_mtx = zeros (N_vol_metaICmap);

[Nrows_spt_corr_data, ~] = size (spt_corr_data);

for i = 1 : Nrows_spt_corr_data
	spt_corr_mtx (spt_corr_data(i,1), spt_corr_data(i,2)) = spt_corr_data (i,3);
end


% display matrix
imagesc (spt_corr_mtx)
colormap jet
colorbar
xlabel ('grp2 melodicIC')
ylabel ('grp1 melodicIC')
xticks (1 : size (spt_corr_mtx, 2))
yticks (1 : size (spt_corr_mtx, 1))


% save the spatial correlation figure
[fsl_spatial_corr_txt_dir, fsl_spatial_corr_txt_filename, ~] = fileparts (fsl_spatial_corr_txt);
savefig ([fsl_spatial_corr_txt_dir '/' fsl_spatial_corr_txt_filename '.fig']);