%
% DESCRIPTION
% ==============================================================================================================
%
% This script manipulates CSV files of ADNI study data downloaded from ADNI website
% https://ida.loni.usc.edu/pages/access/studyData.jsp?project=ADNI, for generating DICOM-to-BIDS mappings and
% clinical data for statistical analyses.
% --------------------------------------
%                  ^
%                  |
%                  ------------- To be developed.
%
%
%
% STRATEGY TO GET BIDS SESSION LABEL
% ==============================================================================================================
%
% [DICOM]:PatientID/PatientName.FamilyName <----------->  SUBJECT:[MRILIST.csv]:SERIESID <--> LONIUID:[UCSF FS ASL 15/22]:VISCODE2  <-> [session label in BIDS]
%                                                                 [MRILIST.csv]:IMAGEUID <-> IMAGEUID:[UCSF FS ASL 15/22]                          /\
%                                                                                                     [UCSF FS ASL 15/22]                          ||
% [DICOM]:StudyDate/SeriesDate/AcquisitionDate/ContentDate <-------------------------------> EXAMDATE:[UCSF FS ASL 15/22]              explanation of session
%                                                                                                                                      label code can be found
%                                                                                                                                      in [VISITS.csv].
%
%
%
%
% HISTORY
% ==============================================================================================================
%
% 02 December 2022 - first version, considering MRLIST.csv, UCSFASLFS_11_02_15_V2.csv, and 
%                    UCSFASLFSCBF_08_17_22.csv.
%
% 04 December 2022 - Taking UCSFASLQC.csv into consideration.
%
%
% KNOWN ISSUES
% ==============================================================================================================
%
% - UCSFASLQC.csv has PTID (i.e., SUBJECT_ID), LONIUID, IMAGEUID, and QCRating, but not VISCODE or scan date. 
%   How should session label be identified? Perhaps need to decide possible session label depending on QCDate.
%
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

ucsf_asl_qc.Properties.VariableNames(find(strcmp(ucsf_asl_qc.Properties.VariableNames,'PTID'))) = {'SUBJECT_ID'};
ucsf_asl_qc.Properties.VariableNames(find(strcmp(ucsf_asl_qc.Properties.VariableNames,'QCRating'))) = {'QC'};


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

ASL_table_temp = outerjoin (mri_list_2use, ucsf_asl_fs_all_2use, 	'Keys', 		{'IMAGEUID','LONIUID'}, ...
																		'MergeKeys',	true, ...
																		'Type',			'right');

ASL_table = outerjoin (ucsf_asl_qc, ASL_table_temp, 	'Keys',		{'IMAGEUID', 'LONIUID', 'SUBJECT_ID'}, ...
																	'MergeKeys',true);

%
% There are 2 entries with empty SUBJECT_ID and SCANDATE
%
%
%  >> find(cellfun(@isempty,ASL_table.('SUBJECT_ID')))

% ans =

%     22
%    126



% >> ASL_table(find(cellfun(@isempty,ASL_table.('SUBJECT_ID'))),:)

% ans =

%   2×9 table

%     SUBJECT_ID     LONIUID       IMAGEUID      QC_ucsf_asl_qc    QCDate    SCANDATE    VISCODE     EXAMDATE     QC_ASL_table_temp
%     __________    __________    ___________    ______________    ______    ________    _______    __________    _________________

%     {0×0 char}    {'704606'}    {'1021030'}      {0×0 char}       NaT        NaT       {'sc' }    2018-07-13        {'Pass'}     
%     {0×0 char}    {'871489'}    {'1224549'}      {0×0 char}       NaT        NaT       {'m78'}    2019-09-06        {'Pass'} 
%
%
% THEREFORE, USE EXAMDATE FROM UCSF_ASL_FS FILES AS PRIMARY FIELD TO MATCH DICOM, SUPPLEMENTED BY SUBJECT_ID
%
%
% 04Dec2022 update : These two subjects do not exist in UCSFASLQC.csv file either.
%

SID_arr = ASL_table.('SUBJECT_ID');
SID_arr(find(strcmp(SID_arr,''))) = {'UNKNOWN'};

LONIUID_arr = ASL_table.('LONIUID');

IMAGEUID_arr = ASL_table.('IMAGEUID');

QC_arr = ASL_table.('QC_ASL_table_temp');
QC_arr(find(cellfun(@isempty,QC_arr))) = ASL_table.('QC_ucsf_asl_qc')(find(cellfun(@isempty,QC_arr)));

QCDATE_arr = erase(cellstr(ASL_table.('QCDate')),'-');
QCDATE_arr(find(strcmp(QCDATE_arr,'NaT'))) = {'UNKNOWN'};

SCANDATE_arr = erase(cellstr(ASL_table.('SCANDATE')),'-'); 	% SCANDATE is datetime array
																	% therefore cellstr() to convert to string
																	% erase '-' as scandate in DICOM header does not have '-'
SCANDATE_arr(find(strcmp(SCANDATE_arr,'NaT'))) = cellstr(ASL_table.('EXAMDATE')(find(strcmp(SCANDATE_arr,'NaT'))));
SCANDATE_arr(find(strcmp(SCANDATE_arr,'NaT'))) = {'UNKNOWN'};

VISCODE_arr = ASL_table.('VISCODE');
VISCODE_arr(find(strcmp(VISCODE_arr,''))) = {'UNKNOWN'};

ADNI_ASL_table = table (SID_arr, LONIUID_arr, IMAGEUID_arr, SCANDATE_arr, QC_arr, QCDATE_arr, VISCODE_arr);

ADNI_ASL_table.Properties.VariableNames = {'SID','LONIUID','IMAGEUID','SCANDATE','QC','QCDATE','VISCODE'};

save ('bmp_ADNI_ASL.mat', 'ADNI_ASL_table');