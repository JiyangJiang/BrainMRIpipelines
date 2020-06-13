function H_lv_coactivationWithCognition_calcCorr (resultFolder)

all_ic_res_meants_txt = dir ([resultFolder '/coactivationWithPhenotype/*_ic_res_meants.txt']);

system (['rm -f ' resultFolder '/coactivationWithPhenotype/corr_coeff.txt']);

for i = 1 : size (all_ic_res_meants_txt, 1)

	subjID = strsplit (all_ic_res_meants_txt(i).name, '_');
	subjID = subjID{1};

	M = dlmread (all_ic_res_meants_txt(i).name);

	corr_mat = corr (M);

	corrcoeff = corr_mat (1,2);

	corrcoeff_fisherZ = atanh (corrcoeff);

	fid = fopen ([resultFolder '/coactivationWithPhenotype/corr_coeff.txt'], 'a');
	fprintf (fid, '%s,%.5f,%.5f\n', subjID, corrcoeff, corrcoeff_fisherZ);
	fclose (fid);
end