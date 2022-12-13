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




% ++++++++++++++++++
% LOAD ALL CSV FILES
% ++++++++++++++++++

BMP_PATH = getenv('BMP_PATH');
cd (fullfile(BMP_PATH,'BIDS','ADNI'));

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



% ADNI ASL QC
ADNI_ASLqc = outerjoin (ucsf_asl_fs_15,	ucsf_asl_fs_22,...
						'Keys',			{'COLPROT','RID','VISCODE','VISCODE_v','SCANDATE','VERSION','LONIUID','IMAGEUID','RUNDATE','QC'},...
						'MergeKeys',	true);

ADNI_ASLqc = outerjoin (ADNI_ASLqc,			ucsf_asl_qc,...
						'Keys',			{'LONIUID','IMAGEUID','QC'},...
						'MergeKeys',	true);

ADNI_ASLqc = outerjoin (ADNI_ASLqc,			mri_list,...
						'Keys',			{'LONIUID','IMAGEUID'},...
						'MergeKeys',true);

ADNI_ASLqc.Properties.VariableNames(find(strcmp(ADNI_ASLqc.Properties.VariableNames,'SCANDATE_mri_list'))) = {'SCANDATE'};
ADNI_ASLqc.('SCANDATE')(find(strcmp(cellstr(ADNI_ASLqc.('SCANDATE')),'NaT'))) = ADNI_ASLqc.('SCANDATE_ADNI_ASLqc')(find(strcmp(cellstr(ADNI_ASLqc.('SCANDATE')),'NaT')));
ADNI_ASLqc = removevars (ADNI_ASLqc, 'SCANDATE_ADNI_ASLqc');

ADNI_ASLqc.Properties.VariableNames(find(strcmp(ADNI_ASLqc.Properties.VariableNames,'SID_mri_list'))) = {'SID'};
ADNI_ASLqc.('SID')(find(cellfun(@isempty,ADNI_ASLqc.('SID')))) = ADNI_ASLqc.('SID_ADNI_ASLqc')(find(cellfun(@isempty,ADNI_ASLqc.('SID'))));
ADNI_ASLqc = removevars (ADNI_ASLqc, 'SID_ADNI_ASLqc');

ADNI_ASLqc = outerjoin (ADNI_ASLqc,		adni_merge, ...
						'Keys',		{'SID','SCANDATE'},...
						'MergeKeys',true);

ADNI_ASLqc.Properties.VariableNames(find(strcmp(ADNI_ASLqc.Properties.VariableNames,'COLPROT_adni_merge'))) = {'COLPROT'};
ADNI_ASLqc.COLPROT(find(cellfun(@isempty, ADNI_ASLqc.COLPROT))) = ADNI_ASLqc.COLPROT_ADNI_ASLqc(find(cellfun(@isempty, ADNI_ASLqc.COLPROT)));
ADNI_ASLqc = removevars (ADNI_ASLqc, 'COLPROT_ADNI_ASLqc');

ADNI_ASLqc.Properties.VariableNames(find(strcmp(ADNI_ASLqc.Properties.VariableNames,'RID_adni_merge'))) = {'RID'};
ADNI_ASLqc.RID(find(isnan(ADNI_ASLqc.RID))) = ADNI_ASLqc.RID_ADNI_ASLqc(find(isnan(ADNI_ASLqc.RID)));
ADNI_ASLqc = removevars (ADNI_ASLqc, 'RID_ADNI_ASLqc');

ADNI_ASLqc.Properties.VariableNames(find(strcmp(ADNI_ASLqc.Properties.VariableNames,'VISCODE_adni_merge'))) = {'VISCODE'};
ADNI_ASLqc.VISCODE(find(cellfun(@isempty, ADNI_ASLqc.VISCODE))) = ADNI_ASLqc.VISCODE_ADNI_ASLqc(find(cellfun(@isempty, ADNI_ASLqc.VISCODE)));
ADNI_ASLqc = removevars (ADNI_ASLqc, 'VISCODE_ADNI_ASLqc');

ADNI_ASLqc.Properties.VariableNames(find(strcmp(ADNI_ASLqc.Properties.VariableNames,'QC'))) = {'QC_ASL'};
ADNI_ASLqc.Properties.VariableNames(find(strcmp(ADNI_ASLqc.Properties.VariableNames,'QCDate'))) = {'QC_ASL_date'};

save ('bmp_ADNI_all_mergeASLqc.mat', 'ADNI_ASLqc');



% for DICOM-to-BIDS mapping purpose
ADNI_forDicom2BidsMapping = table(ADNI_ASLqc.SID,...
										ADNI_ASLqc.SCANDATE,...
										ADNI_ASLqc.VISCODE,...
										ADNI_ASLqc.SEQUENCE,...
										ADNI_ASLqc.IMAGEUID);
ADNI_forDicom2BidsMapping.Properties.VariableNames = {'SID','SCANDATE','VISCODE','SEQUENCE','IMAGEUID'};

ADNI_forDicom2BidsMapping(find (cellfun(@isempty,ADNI_forDicom2BidsMapping.SID)),:)=[];
ADNI_forDicom2BidsMapping(find(cellfun(@isempty,cellstr(ADNI_forDicom2BidsMapping.SCANDATE))),:) =[];
ADNI_forDicom2BidsMapping(find (cellfun(@isempty,ADNI_forDicom2BidsMapping.VISCODE)),:)=[];
ADNI_forDicom2BidsMapping(find(cellfun(@isempty,ADNI_forDicom2BidsMapping.SEQUENCE)),:)=[];
ADNI_forDicom2BidsMapping(find(cellfun(@isempty,ADNI_forDicom2BidsMapping.IMAGEUID)),:)=[];

ADNI_forDicom2BidsMapping = unique (ADNI_forDicom2BidsMapping); % there were duplicates.

save ('bmp_ADNI_forDicom2BidsMapping.mat', 'ADNI_forDicom2BidsMapping');




% for participants.tsv

ADNI_all = load ('bmp_ADNI_all.mat').ADNI_all;
ADNI_ppt_tsv = table (ADNI_all.SID, ADNI_all.AGE, ADNI_all.PTGENDER, ADNI_all.DX_bl);
ADNI_ppt_tsv.Properties.VariableNames = {'participant_id';'baseline_age';'gender';'baseline_diagnosis'};

ADNI_ppt_tsv (find (cellfun (@isempty, ADNI_ppt_tsv.participant_id    )),:) = [];
ADNI_ppt_tsv (find (isnan (ADNI_ppt_tsv.baseline_age)),:)                   = [];
ADNI_ppt_tsv (find (cellfun (@isempty, ADNI_ppt_tsv.gender            )),:) = [];
ADNI_ppt_tsv (find (cellfun (@isempty, ADNI_ppt_tsv.baseline_diagnosis)),:) = [];

ADNI_ppt_tsv_deduplicate = unique(ADNI_ppt_tsv);

ADNI_ppt_tsv_deduplicate.participant_id = strcat('sub-ADNI', strrep(ADNI_ppt_tsv_deduplicate.participant_id,'_',''));

save ('bmp_ADNI_BIDSpptsTSV.mat', 'ADNI_ppt_tsv_deduplicate');



% ADNI3 only - T1w, FLAIR, ASL, PET, DWI

ADNIwithASLqc = load('ADNI/bmp_ADNI_all_mergeASLqc.mat').ADNI_ASLqc;
ADNI3withASLqc = ADNIwithASLqc(find(contains(ADNIwithASLqc.VISIT,'ADNI3')),:);