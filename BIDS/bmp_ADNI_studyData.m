function varargout = bmp_ADNI_studyData
%
% DESCRIPTION
% ==============================================================================================================
%
%   This script manipulates CSV files of ADNI study data downloaded from ADNI website
%   https://ida.loni.usc.edu/pages/access/studyData.jsp?project=ADNI, for generating DICOM-to-BIDS mappings and
%   clinical data for ASL dataset. CSV files considered in this script include:
%
%     - MRILIST.csv
%     - UCSFASLQC.csv
%     - UCSFASLFS_11_02_15_V2.csv
%     - UCSFASLFSCBF_08_17_22.csv
%     - ADNIMERGE.csv
%
%   Some manipulations to the CSV files were done prior to running this script. They can be found in
%   /path/to/BrainMRIpipelines/BIDS/ADNI_study_data/README.md.
%
%
% OUTPUTS
% ==============================================================================================================
%
%   bmp_ADNI_all.mat - All variables for all ADNI ppts. This mat file is constructed by outerjoin
%                      ADNIMERGE.csv and MRILIST.csv. This can be used as the base to merge with
%                      individual imaging modality files, through keywords 'SID' and 'SCANDATE'.
%
%
%   bmp_ADNI_all_mergeASLqc.mat - All variables to map ASL DICOM to BIDS, and conduct clinical studies. The mat 
%                                 file merged UCSFASLQC.csv, UCSFASLFS_11_02_15_V2.csv, and UCSFASLFSCBF_08_17_22.csv, 
%                                 with MRILIST.csv and ADNIMERGE.csv. Note that code to generate this mat was 
%                                 written before the one for generating bmp_ADNI_all.mat. Therefore, bmp_ADNI_all.mat 
%                                 was not used as base to create this mat. Also note that this mat file was 
%                                 NOT filtered by contains(SEQUENCE,'ASL').
%
%
%   bmp_ADNI_forDicom2BidsMapping.mat - A mat of table with 'SID', 'SCANDATE', 'VISCODE', and 
%                                       'SEQUENCE' extracted from bmp_ADNI_all_mergeASLqc.mat. Only 
%                                       entries with non-empty values for 'SID', 'SCANDATE',  
%                                       'VISCODE', and 'SEQUENCE' were included. This file is for 
%                                       creating DICOM-to-BIDS mapping in bmp_ADNI.m. Note that this mat 
%                                       file was filtered by contains (SEQUENCE, 'ASL').
%
%
% HISTORY
% ==============================================================================================================
%
%   02 December 2022 - first version, considering MRLIST.csv, UCSFASLFS_11_02_15_V2.csv, and 
%                      UCSFASLFSCBF_08_17_22.csv.
%
%   04 December 2022 - Taking UCSFASLQC.csv into consideration.
%
%   05 December 2022 - Taking ADNIMERGE.csv into consideration to construct 
%                      bmp_ADNI_ASL_subsetWithClinicalData.mat.
%
%   05 December 2022 - Re-write to include all 4 documents together.
%
%   06 December 2022 - Include SEQUENCE in bmp_ADNI_forDicom2BidsMapping.mat. Update
%                      output MAT filenames.
%
%


	BMP_PATH = getenv('BMP_PATH');



	% ++++++++++++++++++
	% LOAD CSV FILES
	% ++++++++++++++++++

	% MRI list (MRILIST.csv)
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mri_list_opts = detectImportOptions (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'MRILIST.csv'));

	mri_list_opts.ImportErrorRule = 'error';
	mri_list_opts.ExtraColumnsRule = 'error';

	mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'STUDYID'))) = {'char'};
	mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'SERIESID'))) = {'char'};
	mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'IMAGEUID'))) = {'char'};

	mri_list = readtable (fullfile(BMP_PATH,'BIDS','ADNI', 'CSV_files_from_ADNI_website', 'MRILIST.csv'), mri_list_opts);

	mri_list.Properties.VariableNames(find(strcmp(mri_list.Properties.VariableNames,'SUBJECT'))) = {'SID'};
	mri_list.Properties.VariableNames(find(strcmp(mri_list.Properties.VariableNames,'SERIESID'))) = {'LONIUID'};


	% UCSF ASL QC (UCSFASLQC.csv)
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	ucsf_asl_qc_opts = detectImportOptions (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'UCSFASLQC_Jmod2.csv'));

	ucsf_asl_qc_opts.VariableTypes{1,2} = 'char';
	ucsf_asl_qc_opts.VariableTypes{1,3} = 'char';

	ucsf_asl_qc_opts.MissingRule = 'error';
	ucsf_asl_qc_opts.ImportErrorRule = 'error';
	ucsf_asl_qc_opts.ExtraColumnsRule = 'error';

	ucsf_asl_qc = readtable (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'UCSFASLQC_Jmod2.csv'), ucsf_asl_qc_opts);

	ucsf_asl_qc.Properties.VariableNames(find(strcmp(ucsf_asl_qc.Properties.VariableNames,'PTID'))) = {'SID'};
	ucsf_asl_qc.Properties.VariableNames(find(strcmp(ucsf_asl_qc.Properties.VariableNames,'QCRating'))) = {'QC_ASL'};


	% UCSF ASL FreeSurfer 11_02_15 V2 (UCSFASLFS_11_02_15_V2.csv)
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	ucsf_asl_fs_15_opts = detectImportOptions (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'UCSFASLFS_11_02_15_V2.csv'));

	ucsf_asl_fs_15_opts.ImportErrorRule = 'error';
	ucsf_asl_fs_15_opts.ExtraColumnsRule = 'error';

	ucsf_asl_fs_15_opts.VariableTypes(find(strcmp(ucsf_asl_fs_15_opts.VariableNames,'LONIUID'))) = {'char'};
	ucsf_asl_fs_15_opts.VariableTypes(find(strcmp(ucsf_asl_fs_15_opts.VariableNames,'IMAGEUID'))) = {'char'};

	ucsf_asl_fs_15 = readtable (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'UCSFASLFS_11_02_15_V2.csv'), ucsf_asl_fs_15_opts);

	ucsf_asl_fs_15 = ucsf_asl_fs_15(:,1:10);
	ucsf_asl_fs_15.Properties.VariableNames(find(strcmp(ucsf_asl_fs_15.Properties.VariableNames,'EXAMDATE'))) = {'SCANDATE'};
	ucsf_asl_fs_15.Properties.VariableNames(find(strcmp(ucsf_asl_fs_15.Properties.VariableNames,'VISCODE'))) = {'VISCODE_v'};
	ucsf_asl_fs_15.Properties.VariableNames(find(strcmp(ucsf_asl_fs_15.Properties.VariableNames,'VISCODE2'))) = {'VISCODE'};
	ucsf_asl_fs_15.Properties.VariableNames(find(strcmp(ucsf_asl_fs_15.Properties.VariableNames,'RAWQC'))) = {'QC_ASL'};


	% UCSF ASL FreeSurfer CBF 08_17_22 (UCSFASLFSCBF_08_17_22.csv)
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	ucsf_asl_fs_22_opts = detectImportOptions (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'UCSFASLFSCBF_08_17_22.csv'));

	ucsf_asl_fs_22_opts.ImportErrorRule = 'error';
	ucsf_asl_fs_22_opts.ExtraColumnsRule = 'error';

	ucsf_asl_fs_22_opts.VariableTypes(find(strcmp(ucsf_asl_fs_22_opts.VariableNames,'LONIUID'))) = {'char'};
	ucsf_asl_fs_22_opts.VariableTypes(find(strcmp(ucsf_asl_fs_22_opts.VariableNames,'IMAGEUID'))) = {'char'};

	ucsf_asl_fs_22 = readtable (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'UCSFASLFSCBF_08_17_22.csv'), ucsf_asl_fs_22_opts);

	ucsf_asl_fs_22 = ucsf_asl_fs_22(:,1:11);
	ucsf_asl_fs_22.Properties.VariableNames(find(strcmp(ucsf_asl_fs_22.Properties.VariableNames,'VISCODE'))) = {'VISCODE_v'};
	ucsf_asl_fs_22.Properties.VariableNames(find(strcmp(ucsf_asl_fs_22.Properties.VariableNames,'VISCODE2'))) = {'VISCODE'};
	ucsf_asl_fs_22.Properties.VariableNames(find(strcmp(ucsf_asl_fs_22.Properties.VariableNames,'EXAMDATE'))) = {'SCANDATE'};
	ucsf_asl_fs_22.Properties.VariableNames(find(strcmp(ucsf_asl_fs_22.Properties.VariableNames,'CBFQC'))) = {'QC_ASL'};
	ucsf_asl_fs_22.('QC_ASL')(find(strcmp(ucsf_asl_fs_22.('QC_ASL'), 'FALSE'))) = {'Fail'};
	ucsf_asl_fs_22.('QC_ASL')(find(strcmp(ucsf_asl_fs_22.('QC_ASL'), 'TRUE'))) = {'Pass'};



	% MAYO IMAGE QC (MAYOADIRL_MRI_IMAGEQC_12_08_15.csv)
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mayo_imgqc_120815_opts = detectImportOptions (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'MAYOADIRL_MRI_IMAGEQC_12_08_15.csv'));

	mayo_imgqc_120815_opts.ImportErrorRule = 'error';
	mayo_imgqc_120815_opts.ExtraColumnsRule = 'error';

	mayo_imgqc_120815_opts.VariableTypes(find(strcmp(mayo_imgqc_120815_opts.VariableNames,'loni_study'))) = {'char'};
	mayo_imgqc_120815_opts.VariableTypes(find(strcmp(mayo_imgqc_120815_opts.VariableNames,'series_date'))) = {'char'};
	mayo_imgqc_120815_opts.VariableTypes(find(strcmp(mayo_imgqc_120815_opts.VariableNames,'series_time'))) = {'char'};
	mayo_imgqc_120815_opts.VariableTypes(find(strcmp(mayo_imgqc_120815_opts.VariableNames,'series_quality'))) = {'char'};
	mayo_imgqc_120815_opts.VariableTypes(find(strcmp(mayo_imgqc_120815_opts.VariableNames,'series_selected'))) = {'char'};

	mayo_imgqc_120815 = readtable (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'MAYOADIRL_MRI_IMAGEQC_12_08_15.csv'), mayo_imgqc_120815_opts);

	mayo_imgqc_120815.Properties.VariableNames(find(strcmp(mayo_imgqc_120815.Properties.VariableNames,'loni_study'))) = {'STUDYID'};

	mayo_imgqc_120815.Properties.VariableNames(find(strcmp(mayo_imgqc_120815.Properties.VariableNames,'loni_series'))) = {'LONIUID'};
	mayo_imgqc_120815.LONIUID = erase(mayo_imgqc_120815.LONIUID,'S');

	mayo_imgqc_120815.Properties.VariableNames(find(strcmp(mayo_imgqc_120815.Properties.VariableNames,'loni_image'))) = {'IMAGEUID'};
	mayo_imgqc_120815.IMAGEUID = erase(mayo_imgqc_120815.IMAGEUID,'I');

	mayo_imgqc_120815.series_date = datetime(mayo_imgqc_120815.series_date,'InputFormat','yyyyMMdd','Format','yyyy-MM-dd');
	mayo_imgqc_120815.Properties.VariableNames(find(strcmp(mayo_imgqc_120815.Properties.VariableNames,'series_date'))) = {'SCANDATE'};

	mayo_imgqc_120815.series_time = datetime(mayo_imgqc_120815.series_time,'InputFormat','HHmmss.SSS','Format','HH:mm:ss.SSS');
	mayo_imgqc_120815.Properties.VariableNames(find(strcmp(mayo_imgqc_120815.Properties.VariableNames,'series_time'))) = {'SCANTIME'};

	mayo_imgqc_120815.series_quality(find(strcmp(mayo_imgqc_120815.series_quality,'1'))) = {'Excellent'};
	mayo_imgqc_120815.series_quality(find(strcmp(mayo_imgqc_120815.series_quality,'2'))) = {'Good'};
	mayo_imgqc_120815.series_quality(find(strcmp(mayo_imgqc_120815.series_quality,'3'))) = {'Fair'};
	mayo_imgqc_120815.series_quality(find(strcmp(mayo_imgqc_120815.series_quality,'4'))) = {'Unusable'};
	mayo_imgqc_120815.series_quality(find(strcmp(mayo_imgqc_120815.series_quality,'-1'))) = {'Not evaluated'}; 	% Note in MAYOADIRL_MRI_IMAGEQC_DICT_07_31_14.csv
																												% it is specified that <blank> represent
																												% 'Not evaluated'. However, there does not seem
																												% to be any <blank>, but over 10k of '-1'. Therefore,
																												% '-1' is interpreted as 'Not evaluated' for now.
	mayo_imgqc_120815.Properties.VariableNames(find(strcmp(mayo_imgqc_120815.Properties.VariableNames,'series_quality'))) = {'QC_MAYO'};

	mayo_imgqc_120815.Properties.VariableNames(find(strcmp(mayo_imgqc_120815.Properties.VariableNames,'series_description'))) = {'SEQUENCE'};

	mayo_imgqc_120815.Properties.VariableNames(find(strcmp(mayo_imgqc_120815.Properties.VariableNames,'field_strength'))) = {'MAGSTRENGTH'};

	mayo_imgqc_120815.series_selected(find(strcmp(mayo_imgqc_120815.series_selected,'1'))) = {'Recommended'};
	mayo_imgqc_120815.series_selected(find(strcmp(mayo_imgqc_120815.series_selected,'0'))) = {'Not recommended'};
	mayo_imgqc_120815.series_selected(find(strcmp(mayo_imgqc_120815.series_selected,''))) = {'Not evaluated'};
	mayo_imgqc_120815.Properties.VariableNames(find(strcmp(mayo_imgqc_120815.Properties.VariableNames,'series_selected'))) = {'QC_MAYO_RECOMMENDATION'}; 	% Assuming 'series_selected' means
																																							% 'recommended' for further analyses?



	% MAYO ADNI 3 QC (MAYOADIRL_MRI_QUALITY_ADNI3.csv)
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mayo_imgqc_adni3_opts = detectImportOptions (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'MAYOADIRL_MRI_QUALITY_ADNI3.csv'));

	mayo_imgqc_adni3_opts.ImportErrorRule = 'error';
	mayo_imgqc_adni3_opts.ExtraColumnsRule = 'error';

	mayo_imgqc_adni3_opts.VariableTypes(find(strcmp(mayo_imgqc_adni3_opts.VariableNames,'LONI_STUDY'))) = {'char'};
	mayo_imgqc_adni3_opts.VariableTypes(find(strcmp(mayo_imgqc_adni3_opts.VariableNames,'LONI_SERIES'))) = {'char'};
	mayo_imgqc_adni3_opts.VariableTypes(find(strcmp(mayo_imgqc_adni3_opts.VariableNames,'LONI_IMAGE'))) = {'char'};

	mayo_imgqc_adni3 = readtable (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'MAYOADIRL_MRI_QUALITY_ADNI3.csv'), mayo_imgqc_adni3_opts);
	%
	% THIS FILE DOES NOT GIVE SID FOR THE MISSING ONES IN MRI_MASTER. THEREFORE, NOT COMBINED WITH MRI_MASTER.




	% MRI QUALITY (MRIQUALITY.csv)   <-- only data for ADNI 1 available.
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	%
	% !!! IDs in this file do not match any of other files.
	%
	mri_quality_opts = detectImportOptions (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'MRIQUALITY.csv'));

	mri_quality_opts.ImportErrorRule = 'error';
	mri_quality_opts.ExtraColumnsRule = 'error';

	mri_quality = readtable (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'MRIQUALITY.csv'), mri_quality_opts);
	%
	% NOT CONTINUE WITH THIS FILE AS THE ID DOES NOT MATCH ANY OTHER FILES.



	% ADNI MERGE (ADNIMERGE.csv)
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	adni_merge_opts = detectImportOptions (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'ADNIMERGE_Jmod.csv'));

	adni_merge_opts.ExtraColumnsRule = 'error';
	adni_merge_opts.VariableTypes(find(strcmp(adni_merge_opts.VariableNames, 'IMAGEUID'))) = {'char'};

	adni_merge = readtable (fullfile(BMP_PATH,'BIDS','ADNI','CSV_files_from_ADNI_website', 'ADNIMERGE_Jmod.csv'), adni_merge_opts);

	adni_merge.Properties.VariableNames(find(strcmp(adni_merge.Properties.VariableNames,'PTID'))) = {'SID'};
	adni_merge.Properties.VariableNames(find(strcmp(adni_merge.Properties.VariableNames,'IMAGEUID'))) = {'IMAGEUID_abnormal'};

	% EXAMDATE in ADNIMERGE is assessment data for demographics, rather than SCANDATE.









	% ++++++++++++
	% MERGE TABLES
	% ++++++++++++


	% MRI MASTER LIST
	% ----------------------------------------------------------------
	MRI_master = mri_list;




	% DEMOGRAPHICS MASTER LIST
	% ----------------------------------------------------------------
	DEM_master = adni_merge;




	% ASL QC
	% ----------------------------------------------------------------
	ASL_QC = outerjoin (ucsf_asl_fs_15,	ucsf_asl_fs_22,...
							'Keys',			{'COLPROT','RID','VISCODE','VISCODE_v','SCANDATE','VERSION','LONIUID','IMAGEUID','RUNDATE','QC_ASL'},...
							'MergeKeys',	true);

	ASL_QC = outerjoin (ASL_QC,			ucsf_asl_qc,...
							'Keys',			{'LONIUID','IMAGEUID','QC_ASL'},...
							'MergeKeys',	true);

	ASL_QC.Properties.VariableNames(find(strcmp(ASL_QC.Properties.VariableNames,'QCDate'))) = {'QC_ASL_date'};




	% all QC
	% ----------------------------------------------------------------
	%
	% !!! SOME ENTRIES IN ASL QC CORRESPOND TO MOCO FMRI IN MAYO QC FILE
	%     AND MRI LIST. THEY ARE KEPT AS THEY WERE FOR NOW.
	%
	all_QC = outerjoin (mayo_imgqc_120815, ASL_QC, ...
						'Keys',		'IMAGEUID',...
						'MergeKeys',true);

	dup_str_fields = {'LONIUID'};
	dup_num_fields = {'RID'};
	dup_dat_fields = {'SCANDATE'};
	tabname1 = 'mayo_imgqc_120815';
	tabname2 = 'ASL_QC';
	in_tab = all_QC;

	all_QC = shuffleAfterJoin (dup_str_fields, dup_num_fields, dup_dat_fields, tabname1, tabname2, in_tab);



	% include all QC in MRI MASTER list
	% ----------------------------------------------------------------
	MRI_master = outerjoin (MRI_master,			all_QC,...
							'Keys',			'IMAGEUID',...
							'MergeKeys',	true);

	dup_str_fields = {'SID';'STUDYID';'LONIUID';'SEQUENCE'};
	dup_num_fields = {'MAGSTRENGTH'};
	dup_dat_fields = {'SCANDATE'};
	tabname1 = 'MRI_master';
	tabname2 = 'all_QC';
	in_tab = MRI_master;

	MRI_master = shuffleAfterJoin (dup_str_fields, dup_num_fields, dup_dat_fields, tabname1, tabname2, in_tab);

	% Note that some entries from ASL_QC cannot find SID in MRI_master (i.e., mri_list). Hopefully,
	% they can be picked up in the 'checkback' mode in bmp_ADNI.m.



	% MRI MASTER borrows COLPROT, VISCODE from DEM MASTER
	MRI_temp = table (MRI_master.SID, MRI_master.SCANDATE, MRI_master.VISIT, MRI_master.MAGSTRENGTH);
	MRI_temp.Properties.VariableNames = {'SID';'SCANDATE';'VISIT';'MAGSTRENGTH'};
	MRI_temp(find(cellfun(@isempty,MRI_temp.SID)),:) = [];
	MRI_temp(find(strcmp(cellstr(MRI_temp.SCANDATE),'NaT')),:) = [];
	MRI_temp(find(cellfun(@isempty,MRI_temp.VISIT)),:) = [];
	MRI_temp=unique(MRI_temp);

	DEM_temp = table (DEM_master.SID, DEM_master.EXAMDATE, DEM_master.COLPROT, DEM_master.VISCODE);
	DEM_temp.Properties.VariableNames = {'SID';'EXAMDATE';'COLPROT';'VISCODE'};
	DEM_temp(find(cellfun(@isempty,DEM_temp.SID)),:)=[];
	DEM_temp(find(strcmp(cellstr(DEM_temp.EXAMDATE),'NaT')),:) = [];
	DEM_temp(find(cellfun(@isempty,DEM_temp.COLPROT)),:)=[];
	DEM_temp(find(cellfun(@isempty,DEM_temp.VISCODE)),:)=[];

	temp = outerjoin(MRI_temp,DEM_temp,'Keys','SID','MergeKeys',true);
	temp.DATEDIFF = calmonths(between(temp.SCANDATE,temp.EXAMDATE)); % difference btw SCANDATE and EXAMDATE in months.
	temp = temp(find(temp.DATEDIFF<3),:);
	temp = temp(find(temp.DATEDIFF>-3),:);

	idx=find(strcmp(temp.VISCODE,'bl') & abs(temp.MAGSTRENGTH - 1.5)<0.1 & contains (temp.VISIT,'screening','IgnoreCase',true));
	for i = 1 : size (idx,1)
		if size(temp(find(strcmp(temp.SID,temp.SID(idx(i)))&strcmp(temp.VISCODE,'bl')&(temp.MAGSTRENGTH==3)),:),1) == 1
			temp.VISCODE(idx(i)) = {'sc'}; 	% VISCODE = 'bl' & MAGSTRENGTH ~ 1.5T & VISIT contains 'screening' 
											% & there is is another 'bl' and MAGSTRENTCH==3 under the same SID
											% => ADNI 1 screening (VISCODE = 'sc').
		end
	end
	temp = table (temp.SID, temp.SCANDATE, temp.VISIT, temp.MAGSTRENGTH, temp.COLPROT, temp.VISCODE);
	temp.Properties.VariableNames = {'SID';'SCANDATE';'VISIT';'MAGSTRENGTH';'COLPROT';'VISCODE'};

	MRI_master = outerjoin (MRI_master, temp, 'Keys', {'SID';'SCANDATE';'VISIT';'MAGSTRENGTH'}, 'MergeKeys', true);

	dup_str_fields = {'COLPROT';'VISCODE'};
	dup_dat_fields = cell(0,1);
	dup_num_fields = cell(0,1);
	tabname1 = 'temp';
	tabname2 = 'MRI_master';
	in_tab = MRI_master;

	MRI_master = shuffleAfterJoin (dup_str_fields, dup_num_fields, dup_dat_fields, tabname1, tabname2, in_tab);



	% DICOM-to-BIDS mapping
	% ----------------------------------------------------------------
	forDICOM2BIDS = table(MRI_master.SID, MRI_master.SCANDATE,...
							MRI_master.VISCODE, MRI_master.SEQUENCE,...
							MRI_master.IMAGEUID);
	forDICOM2BIDS.Properties.VariableNames = {'SID','SCANDATE','VISCODE','SEQUENCE','IMAGEUID'};

	forDICOM2BIDS(find (cellfun(@isempty,forDICOM2BIDS.SID)),:)=[];
	forDICOM2BIDS(find(cellfun(@isempty,cellstr(forDICOM2BIDS.SCANDATE))),:) =[];
	forDICOM2BIDS(find (cellfun(@isempty,forDICOM2BIDS.VISCODE)),:)=[];
	forDICOM2BIDS(find(cellfun(@isempty,forDICOM2BIDS.SEQUENCE)),:)=[];
	forDICOM2BIDS(find(cellfun(@isempty,forDICOM2BIDS.IMAGEUID)),:)=[];




	% for participants.tsv
	% ----------------------------------------------------------------
	forBIDSpptsTsv = table (DEM_master.SID, DEM_master.AGE, DEM_master.PTGENDER, DEM_master.DX_bl);
	forBIDSpptsTsv.Properties.VariableNames = {'participant_id';'baseline_age';'gender';'baseline_diagnosis'};

	forBIDSpptsTsv (find (cellfun (@isempty, forBIDSpptsTsv.participant_id    )),:) = [];
	forBIDSpptsTsv (find (isnan 			(forBIDSpptsTsv.baseline_age)),:)       = [];
	forBIDSpptsTsv (find (cellfun (@isempty, forBIDSpptsTsv.gender            )),:) = [];
	forBIDSpptsTsv (find (cellfun (@isempty, forBIDSpptsTsv.baseline_diagnosis)),:) = [];

	forBIDSpptsTsv.participant_id = strcat('sub-ADNI', strrep(forBIDSpptsTsv.participant_id,'_',''));



	varargout{1} = DEM_master;
	varargout{2} = MRI_master;
	varargout{3} = forDICOM2BIDS;
	varargout{4} = forBIDSpptsTsv;

	save (fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat'), ...
				'DEM_master', 'MRI_master', 'forDICOM2BIDS', 'forBIDSpptsTsv');

end




function out_tab = shuffleAfterJoin (dup_str_fields, dup_num_fields, dup_dat_fields, tabname1, tabname2, in_tab)

	for i = 1 : size (dup_dat_fields,1)
		in_tab.Properties.VariableNames(find(strcmp(in_tab.Properties.VariableNames,[dup_dat_fields{i,1} '_' tabname1]))) = {dup_dat_fields{i,1}};
		in_tab.(dup_dat_fields{i,1})(find(strcmp(cellstr(in_tab.(dup_dat_fields{i,1})),'NaT'))) = in_tab.([dup_dat_fields{i,1} '_' tabname2])(find(strcmp(cellstr(in_tab.(dup_dat_fields{i,1})),'NaT')));
		in_tab = removevars (in_tab, [dup_dat_fields{i,1} '_' tabname2]);
	end

	for i = 1 : size (dup_str_fields,1)
		in_tab.Properties.VariableNames(find(strcmp(in_tab.Properties.VariableNames,[dup_str_fields{i,1} '_' tabname1]))) = {dup_str_fields{i,1}};
		in_tab.(dup_str_fields{i,1})(find(cellfun(@isempty,in_tab.(dup_str_fields{i,1})))) = in_tab.([dup_str_fields{i,1} '_' tabname2])(find(cellfun(@isempty,in_tab.(dup_str_fields{i,1}))));
		in_tab = removevars (in_tab, [dup_str_fields{i,1} '_' tabname2]);
	end

	for i = 1 : size (dup_num_fields,1)
		in_tab.Properties.VariableNames(find(strcmp(in_tab.Properties.VariableNames,[dup_num_fields{i,1} '_' tabname1]))) = {dup_num_fields{i,1}};
		in_tab.(dup_num_fields{i,1})(find(isnan(in_tab.(dup_num_fields{i,1})))) = in_tab.([dup_num_fields{i,1} '_' tabname2])(find(isnan(in_tab.(dup_num_fields{i,1}))));
		in_tab = removevars (in_tab, [dup_num_fields{i,1} '_' tabname2]);
	end

	out_tab = in_tab;
end