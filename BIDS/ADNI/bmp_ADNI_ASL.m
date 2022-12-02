%
% STRATEGY TO GET BIDS SESSION LABEL
% ==============================================================================================================
%
% [DICOM]:PatientID/PatientName.FamilyName                    <->  SUBJECT:[MRILIST.csv]:SERIESID <->  LONIUID:[UCSF FS ASL 15/22]:VISCODE2  <-> [session label in BIDS]
%                                                                          [MRILIST.csv]:IMAGEUID <-> IMAGEUID:[UCSF FS ASL 15/22]                          /\
%                                                                          [MRILIST.csv]                                                                    ||
%                                                                                                                                               explanation of session
% [DICOM]:StudyDate/SeriesDate/AcquisitionDate/ContentDate     <-------------------------------------> EXAMDATE:[UCSF FS ASL 15/22]              label code can be found
%                                                                                                                                               in [VISITS.csv].
%
%
%
% KNOWN ISSUES
% ==============================================================================================================
%
% - How to use UCSFASLQC.csv?
%
% ==============================================================================================================

% MRI list (MRILIST.csv)
mri_list_opts = detectImportOptions ('CSV_files_from_ADNI_website/MRILIST.csv');

mri_list_opts.ImportErrorRule = 'error';
mri_list_opts.ExtraColumnsRule = 'error';

mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'STUDYID'))) = {'char'};
mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'SERIESID'))) = {'char'};
mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'IMAGEUID'))) = {'char'};

mri_list = readtable ('CSV_files_from_ADNI_website/MRILIST.csv', mri_list_opts);


% UCSF ASL QC
ucsf_asl_qc_opts = detectImportOptions ('CSV_files_from_ADNI_website/UCSFASLQC_Jmod2.csv');

ucsf_asl_qc_opts.VariableTypes{1,2} = 'char';
ucsf_asl_qc_opts.VariableTypes{1,3} = 'char';

ucsf_asl_qc_opts.MissingRule = 'error';
ucsf_asl_qc_opts.ImportErrorRule = 'error';
ucsf_asl_qc_opts.ExtraColumnsRule = 'error';

ucsf_asl_qc = readtable ('CSV_files_from_ADNI_website/UCSFASLQC_Jmod2.csv', ucsf_asl_qc_opts);


% UCSF ASL FreeSurfer 11_02_15 V2 (UCSFASLFS_11_02_15_V2.csv)
ucsf_asl_fs_15_opts = detectImportOptions ('CSV_files_from_ADNI_website/UCSFASLFS_11_02_15_V2.csv');

ucsf_asl_fs_15_opts.ImportErrorRule = 'error';
ucsf_asl_fs_15_opts.ExtraColumnsRule = 'error';

ucsf_asl_fs_15_opts.VariableTypes(find(strcmp(ucsf_asl_fs_15_opts.VariableNames,'LONIUID'))) = {'char'};
ucsf_asl_fs_15_opts.VariableTypes(find(strcmp(ucsf_asl_fs_15_opts.VariableNames,'IMAGEUID'))) = {'char'};

ucsf_asl_fs_15 = readtable ('CSV_files_from_ADNI_website/UCSFASLFS_11_02_15_V2.csv', ucsf_asl_fs_15_opts);
ucsf_asl_fs_15_useful = ucsf_asl_fs_15(:,1:10);


% UCSF ASL FreeSurfer CBF 08_17_22 (UCSFASLFSCBF_08_17_22.csv)
ucsf_asl_fs_22_opts = detectImportOptions ('CSV_files_from_ADNI_website/UCSFASLFSCBF_08_17_22.csv');

ucsf_asl_fs_22_opts.ImportErrorRule = 'error';
ucsf_asl_fs_22_opts.ExtraColumnsRule = 'error';

ucsf_asl_fs_22_opts.VariableTypes(find(strcmp(ucsf_asl_fs_22_opts.VariableNames,'LONIUID'))) = {'char'};
ucsf_asl_fs_22_opts.VariableTypes(find(strcmp(ucsf_asl_fs_22_opts.VariableNames,'IMAGEUID'))) = {'char'};

ucsf_asl_fs_22 = readtable ('CSV_files_from_ADNI_website/UCSFASLFSCBF_08_17_22.csv', ucsf_asl_fs_22_opts);
ucsf_asl_fs_22_useful = ucsf_asl_fs_22(:,1:11);



% % ADNIMERGE
% adni_merge_opts = detectImportOptions ('CSV_files_from_ADNI_website/ADNIMERGE_Jmod.csv');

% adni_merge_opts.ExtraColumnsRule = 'error';
% adnimerge_opts.VariableTypes(find(strcmp(adnimerge_opts.VariableNames, 'IMAGEUID'))) = {'char'};

% adni_merge = readtable ('CSV_files_from_ADNI_website/ADNIMERGE_Jmod.csv', adni_merge_opts);


% extract columns to use and merge
mri_list_2use = table (mri_list.('SUBJECT'), mri_list.('SCANDATE'), mri_list.('SERIESID'), mri_list.('IMAGEUID'));
mri_list_2use.Properties.VariableNames = {'SUBJECT_ID', 'SCANDATE', 'LONIUID', 'IMAGEUID'};

ucsf_asl_fs_15_2use = table (ucsf_asl_fs_15_useful.('LONIUID'), ucsf_asl_fs_15_useful.('IMAGEUID'), ucsf_asl_fs_15_useful.('VISCODE2'), ucsf_asl_fs_15_useful.('EXAMDATE'), ucsf_asl_fs_15_useful.('RAWQC'));
ucsf_asl_fs_15_2use.Properties.VariableNames = {'LONIUID', 'IMAGEUID', 'VISCODE', 'EXAMDATE', 'QC'};  % both UCSF ASL files in year 15 and 22 are QC'ed on perfusion-weighted image.

ucsf_asl_fs_22_2use = table (ucsf_asl_fs_22_useful.('LONIUID'), ucsf_asl_fs_22_useful.('IMAGEUID'), ucsf_asl_fs_22_useful.('VISCODE2'), ucsf_asl_fs_22_useful.('EXAMDATE'), ucsf_asl_fs_22_useful.('CBFQC'));
ucsf_asl_fs_22_2use.Properties.VariableNames = {'LONIUID', 'IMAGEUID', 'VISCODE', 'EXAMDATE', 'QC'};

ucsf_asl_fs_all_2use = [ucsf_asl_fs_15_2use; ucsf_asl_fs_22_2use]; % vertical concatenation

ucsf_asl_fs_all_2use.('QC')(find(strcmp(ucsf_asl_fs_all_2use.('QC'), 'FALSE'))) = {'Fail'}; 	% Replace FALSE/TRUE with Fail/True
																								% according to the DICT file, 0=Fail, 1=Pass
ucsf_asl_fs_all_2use.('QC')(find(strcmp(ucsf_asl_fs_all_2use.('QC'), 'TRUE')))  = {'Pass'};

% 2 duplicated LONIUID's : 141087, 156391
%
% IMAGEUID's are all unique.
%
% >> ucsf_asl_fs_all_2use(find(strcmp(ucsf_asl_fs_all_2use.('LONIUID'), '141087')),:)

% ans =

%   2×4 table

%      LONIUID       IMAGEUID     VISCODE       QC   
%     __________    __________    _______    ________

%     {'141087'}    {'285352'}    {'m12'}    {'Fail'}
%     {'141087'}    {'285359'}    {'m12'}    {'Pass'}

% >> ucsf_asl_fs_all_2use(find(strcmp(ucsf_asl_fs_all_2use.('LONIUID'), '156391')),:)

% ans =

%   2×4 table

%      LONIUID       IMAGEUID      VISCODE        QC   
%     __________    __________    _________    ________

%     {'156391'}    {'314050'}    {'scmri'}    {'Pass'}
%     {'156391'}    {'314044'}    {'scmri'}    {'Pass'}
%
%
% THEREFORE, USE IMAGEUID AS THE MAIN KEY TO MATCH.
%

asl_final_table = outerjoin (mri_list_2use, ucsf_asl_fs_all_2use, 	'Keys', 		'IMAGEUID', ...
																	'Mergekeys',	true, ...
																	'Type',			'right');


%
% There are 2 entries with empty SUBJECT_ID and SCANDATE from MRILIST.csv
%
%
% >> asl_final_table(find(strcmp(asl_final_table.('SUBJECT_ID'),'')),:)

% ans =

%   2×8 table

%     SUBJECT_ID    SCANDATE    LONIUID_mri_list_2use     IMAGEUID      LONIUID_ucsf_asl_fs_all_2use    VISCODE     EXAMDATE        QC   
%     __________    ________    _____________________    ___________    ____________________________    _______    __________    ________

%     {0×0 char}      NaT            {0×0 char}          {'1021030'}             {'704606'}             {'sc' }    2018-07-13    {'Pass'}
%     {0×0 char}      NaT            {0×0 char}          {'1224549'}             {'871489'}             {'m78'}    2019-09-06    {'Pass'}
%
%
% THEREFORE, USE EXAMDATE FROM UCSF_ASL_FS FILES AS PRIMARY FIELD TO MATCH DICOM, SUPPLEMENTED BY SUBJECT_ID
%

save ('bmp_asl_final.mat', 'asl_final_table');