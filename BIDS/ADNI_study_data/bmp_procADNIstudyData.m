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
%   bmp_ADNI_ASL.mat - All variables to map ASL DICOM to BIDS, and conduct clinical studies. Note that code
%                      to generate this mat was written before the one for generating bmp_ADNI_all.mat. Therefore,
%                      bmp_ADNI_all.mat was not used as base to create this mat.
%
%   bmp_ADNI_ASL_forDicom2BidsMapping.mat - A mat of table with 'SID', 'SCANDATE', and 'VISCODE'. Only entries
%                                           with non-empty values for all three variables were included. This
%                                           file is for creating DICOM-to-BIDS mapping in bmp_ADNI.m.
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
%
% KNOWN ISSUES
% ==============================================================================================================
%
% ==============================================================================================================




% ++++++++++++++++++
% LOAD ALL CSV FILES
% ++++++++++++++++++


% MRI list (MRILIST.csv)
mri_list_opts = detectImportOptions ('CSV_files_from_ADNI_website/MRILIST.csv');

mri_list_opts.ImportErrorRule = 'error';
mri_list_opts.ExtraColumnsRule = 'error';

mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'STUDYID'))) = {'char'};
mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'SERIESID'))) = {'char'};
mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'IMAGEUID'))) = {'char'};

mri_list = readtable ('CSV_files_from_ADNI_website/MRILIST.csv', mri_list_opts);

mri_list.Properties.VariableNames(find(strcmp(mri_list.Properties.VariableNames,'SUBJECT'))) = {'SID'};
mri_list.Properties.VariableNames(find(strcmp(mri_list.Properties.VariableNames,'SERIESID'))) = {'LONIUID'};


% UCSF ASL QC
ucsf_asl_qc_opts = detectImportOptions ('CSV_files_from_ADNI_website/UCSFASLQC_Jmod2.csv');

ucsf_asl_qc_opts.VariableTypes{1,2} = 'char';
ucsf_asl_qc_opts.VariableTypes{1,3} = 'char';

ucsf_asl_qc_opts.MissingRule = 'error';
ucsf_asl_qc_opts.ImportErrorRule = 'error';
ucsf_asl_qc_opts.ExtraColumnsRule = 'error';

ucsf_asl_qc = readtable ('CSV_files_from_ADNI_website/UCSFASLQC_Jmod2.csv', ucsf_asl_qc_opts);

ucsf_asl_qc.Properties.VariableNames(find(strcmp(ucsf_asl_qc.Properties.VariableNames,'PTID'))) = {'SID'};
ucsf_asl_qc.Properties.VariableNames(find(strcmp(ucsf_asl_qc.Properties.VariableNames,'QCRating'))) = {'QC'};


% UCSF ASL FreeSurfer 11_02_15 V2 (UCSFASLFS_11_02_15_V2.csv)
ucsf_asl_fs_15_opts = detectImportOptions ('CSV_files_from_ADNI_website/UCSFASLFS_11_02_15_V2.csv');

ucsf_asl_fs_15_opts.ImportErrorRule = 'error';
ucsf_asl_fs_15_opts.ExtraColumnsRule = 'error';

ucsf_asl_fs_15_opts.VariableTypes(find(strcmp(ucsf_asl_fs_15_opts.VariableNames,'LONIUID'))) = {'char'};
ucsf_asl_fs_15_opts.VariableTypes(find(strcmp(ucsf_asl_fs_15_opts.VariableNames,'IMAGEUID'))) = {'char'};

ucsf_asl_fs_15 = readtable ('CSV_files_from_ADNI_website/UCSFASLFS_11_02_15_V2.csv', ucsf_asl_fs_15_opts);

ucsf_asl_fs_15 = ucsf_asl_fs_15(:,1:10);
ucsf_asl_fs_15.Properties.VariableNames(find(strcmp(ucsf_asl_fs_15.Properties.VariableNames,'EXAMDATE'))) = {'SCANDATE'};
ucsf_asl_fs_15.Properties.VariableNames(find(strcmp(ucsf_asl_fs_15.Properties.VariableNames,'VISCODE'))) = {'VISCODE_v'};
ucsf_asl_fs_15.Properties.VariableNames(find(strcmp(ucsf_asl_fs_15.Properties.VariableNames,'VISCODE2'))) = {'VISCODE'};
ucsf_asl_fs_15.Properties.VariableNames(find(strcmp(ucsf_asl_fs_15.Properties.VariableNames,'RAWQC'))) = {'QC'};


% UCSF ASL FreeSurfer CBF 08_17_22 (UCSFASLFSCBF_08_17_22.csv)
ucsf_asl_fs_22_opts = detectImportOptions ('CSV_files_from_ADNI_website/UCSFASLFSCBF_08_17_22.csv');

ucsf_asl_fs_22_opts.ImportErrorRule = 'error';
ucsf_asl_fs_22_opts.ExtraColumnsRule = 'error';

ucsf_asl_fs_22_opts.VariableTypes(find(strcmp(ucsf_asl_fs_22_opts.VariableNames,'LONIUID'))) = {'char'};
ucsf_asl_fs_22_opts.VariableTypes(find(strcmp(ucsf_asl_fs_22_opts.VariableNames,'IMAGEUID'))) = {'char'};

ucsf_asl_fs_22 = readtable ('CSV_files_from_ADNI_website/UCSFASLFSCBF_08_17_22.csv', ucsf_asl_fs_22_opts);

ucsf_asl_fs_22 = ucsf_asl_fs_22(:,1:11);
ucsf_asl_fs_22.Properties.VariableNames(find(strcmp(ucsf_asl_fs_22.Properties.VariableNames,'VISCODE'))) = {'VISCODE_v'};
ucsf_asl_fs_22.Properties.VariableNames(find(strcmp(ucsf_asl_fs_22.Properties.VariableNames,'VISCODE2'))) = {'VISCODE'};
ucsf_asl_fs_22.Properties.VariableNames(find(strcmp(ucsf_asl_fs_22.Properties.VariableNames,'EXAMDATE'))) = {'SCANDATE'};
ucsf_asl_fs_22.Properties.VariableNames(find(strcmp(ucsf_asl_fs_22.Properties.VariableNames,'CBFQC'))) = {'QC'};
ucsf_asl_fs_22.('QC')(find(strcmp(ucsf_asl_fs_22.('QC'), 'FALSE'))) = {'Fail'};
ucsf_asl_fs_22.('QC')(find(strcmp(ucsf_asl_fs_22.('QC'), 'TRUE'))) = {'Pass'};


% ADNI MERGE
adni_merge_opts = detectImportOptions ('CSV_files_from_ADNI_website/ADNIMERGE_Jmod.csv');

adni_merge_opts.ExtraColumnsRule = 'error';
adni_merge_opts.VariableTypes(find(strcmp(adni_merge_opts.VariableNames, 'IMAGEUID'))) = {'char'};

adni_merge = readtable ('CSV_files_from_ADNI_website/ADNIMERGE_Jmod.csv', adni_merge_opts);

adni_merge.Properties.VariableNames(find(strcmp(adni_merge.Properties.VariableNames,'PTID'))) = {'SID'};
adni_merge.Properties.VariableNames(find(strcmp(adni_merge.Properties.VariableNames,'EXAMDATE'))) = {'SCANDATE'};
adni_merge.Properties.VariableNames(find(strcmp(adni_merge.Properties.VariableNames,'IMAGEUID'))) = {'IMAGEUID_abnormal'};





% ++++++++++++
% MERGE TABLES
% ++++++++++++

% all ADNI
ADNI_all = outerjoin (mri_list,		adni_merge,...
						'Keys',		{'SID','SCANDATE'},...
						'MergeKeys',true);

save ('bmp_ADNI_all.mat', 'ADNI_all');



% ADNI ASL
ADNI_ASL = outerjoin (ucsf_asl_fs_15,	ucsf_asl_fs_22,...
						'Keys',			{'COLPROT','RID','VISCODE','VISCODE_v','SCANDATE','VERSION','LONIUID','IMAGEUID','RUNDATE','QC'},...
						'MergeKeys',	true);

ADNI_ASL = outerjoin (ADNI_ASL,			ucsf_asl_qc,...
						'Keys',			{'LONIUID','IMAGEUID','QC'},...
						'MergeKeys',	true);

ADNI_ASL = outerjoin (ADNI_ASL,			mri_list,...
						'Keys',			{'LONIUID','IMAGEUID'},...
						'MergeKeys',true);

ADNI_ASL.Properties.VariableNames(find(strcmp(ADNI_ASL.Properties.VariableNames,'SCANDATE_mri_list'))) = {'SCANDATE'};
ADNI_ASL.('SCANDATE')(find(strcmp(cellstr(ADNI_ASL.('SCANDATE')),'NaT'))) = ADNI_ASL.('SCANDATE_ADNI_ASL')(find(strcmp(cellstr(ADNI_ASL.('SCANDATE')),'NaT')));
ADNI_ASL = removevars (ADNI_ASL, 'SCANDATE_ADNI_ASL');

ADNI_ASL.Properties.VariableNames(find(strcmp(ADNI_ASL.Properties.VariableNames,'SID_mri_list'))) = {'SID'};
ADNI_ASL.('SID')(find(cellfun(@isempty,ADNI_ASL.('SID')))) = ADNI_ASL.('SID_ADNI_ASL')(find(cellfun(@isempty,ADNI_ASL.('SID'))));
ADNI_ASL = removevars (ADNI_ASL, 'SID_ADNI_ASL');

ADNI_ASL = outerjoin (ADNI_ASL,		adni_merge, ...
						'Keys',		{'SID','SCANDATE'},...
						'MergeKeys',true);

ADNI_ASL.Properties.VariableNames(find(strcmp(ADNI_ASL.Properties.VariableNames,'COLPROT_adni_merge'))) = {'COLPROT'};
ADNI_ASL.COLPROT(find(cellfun(@isempty, ADNI_ASL.COLPROT))) = ADNI_ASL.COLPROT_ADNI_ASL(find(cellfun(@isempty, ADNI_ASL.COLPROT)));
ADNI_ASL = removevars (ADNI_ASL, 'COLPROT_ADNI_ASL');

ADNI_ASL.Properties.VariableNames(find(strcmp(ADNI_ASL.Properties.VariableNames,'RID_adni_merge'))) = {'RID'};
ADNI_ASL.RID(find(isnan(ADNI_ASL.RID))) = ADNI_ASL.RID_ADNI_ASL(find(isnan(ADNI_ASL.RID)));
ADNI_ASL = removevars (ADNI_ASL, 'RID_ADNI_ASL');

ADNI_ASL.Properties.VariableNames(find(strcmp(ADNI_ASL.Properties.VariableNames,'VISCODE_adni_merge'))) = {'VISCODE'};
ADNI_ASL.VISCODE(find(cellfun(@isempty, ADNI_ASL.VISCODE))) = ADNI_ASL.VISCODE_ADNI_ASL(find(cellfun(@isempty, ADNI_ASL.VISCODE)));
ADNI_ASL = removevars (ADNI_ASL, 'VISCODE_ADNI_ASL');


save ('bmp_ADNI_ASL.mat', 'ADNI_ASL');



% for DICOM-to-BIDS mapping purpose
ADNI_ASL_forDicom2BidsMapping = table(ADNI_ASL.SID,ADNI_ASL.SCANDATE,ADNI_ASL.VISCODE);
ADNI_ASL_forDicom2BidsMapping.Properties.VariableNames = {'SID','SCANDATE','VISCODE'};

ADNI_ASL_forDicom2BidsMapping(find (cellfun(@isempty,ADNI_ASL_forDicom2BidsMapping.SID)),:)=[];
ADNI_ASL_forDicom2BidsMapping(find(cellfun(@isempty,cellstr(ADNI_ASL_forDicom2BidsMapping.SCANDATE))),:) =[];
ADNI_ASL_forDicom2BidsMapping(find (cellfun(@isempty,ADNI_ASL_forDicom2BidsMapping.VISCODE)),:)=[];

ADNI_ASL_forDicom2BidsMapping = unique (ADNI_ASL_forDicom2BidsMapping); % there were duplicates.

save ('bmp_ADNI_ASL_forDicom2BidsMapping.mat', 'ADNI_ASL_forDicom2BidsMapping');