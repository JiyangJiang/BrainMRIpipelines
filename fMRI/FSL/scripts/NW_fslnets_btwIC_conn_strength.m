function NW_fslnets_btwIC_conn_strength (dr_stage1_subjectXXXXX_txt_folder,...
									     idx1_startingFrom1,...
									     idx2_startingFrom1)

dr_stage1_subjectXXXXX_txt_list = dir ([dr_stage1_subjectXXXXX_txt_folder ...
										'/dr_stage1_subject*.txt']);

cd (dr_stage1_subjectXXXXX_txt_folder);

for i = 1 : size (dr_stage1_subjectXXXXX_txt_list,1)

	dr_stage1_subjectXXXXX_txt = dr_stage1_subjectXXXXX_txt_list(i).name;

	data = dlmread (dr_stage1_subjectXXXXX_txt);
	% size(data)

	corr_mtx = corrcoef (data (:,idx1_startingFrom1), ...
						 data (:,idx2_startingFrom1));

	corr_coefficient = corr_mtx (1,2);

	z_conn_strength = atanh (corr_coefficient);

	fid = fopen ('btwIC_conn_strength.txt','a');
	fprintf (fid, '%.4f\n', z_conn_strength);
	fclose (fid);
end