function H_lv_metaICA_spatialCorrelationWithKnownRSNs_disp   (fsl_spatial_corr_txt, ...
															  sptCorrCalcMethod, ...
															  N_vol_metaICmap, ...
															  N_vol_resampledKnownRSN)

fileID = fopen (fsl_spatial_corr_txt, 'r');

% these variables are passed from shell, therefore are string
N_vol_metaICmap = str2num (N_vol_metaICmap);
N_vol_resampledKnownRSN = str2num (N_vol_resampledKnownRSN);

switch sptCorrCalcMethod

	case 'fsl_web'
		spt_corr_data = fscanf (fileID, '%f');
		fclose (fileID);

		% reshape to (N_vol_resampledKnownRSN * N_vol_metaICmap) matrix
		spt_corr_mtx = reshape (spt_corr_data, [N_vol_metaICmap, N_vol_resampledKnownRSN]);

		spt_corr_mtx = spt_corr_mtx';

	case 'fsl_fslcc'
		spt_corr_data = fscanf (fileID, '  %d   %d %f', [3 Inf]);
		fclose (fileID);
		spt_corr_data = spt_corr_data';

		spt_corr_mtx = zeros (N_vol_resampledKnownRSN, N_vol_metaICmap);

		[Nrows_spt_corr_data, ~] = size (spt_corr_data);

		for i = 1 : Nrows_spt_corr_data
			spt_corr_mtx (spt_corr_data(i,1), spt_corr_data(i,2)) = spt_corr_data (i,3);
		end

end

% display matrix
imagesc (spt_corr_mtx)
colormap jet
colorbar
xlabel ('melodic IC')
ylabel ('known RSNs')
xticks (1 : size (spt_corr_mtx, 2))
yticks (1 : size (spt_corr_mtx, 1))


% save the spatial correlation figure
[fsl_spatial_corr_txt_dir, fsl_spatial_corr_txt_filename, ~] = fileparts (fsl_spatial_corr_txt);
savefig ([fsl_spatial_corr_txt_dir '/' fsl_spatial_corr_txt_filename '.fig']);