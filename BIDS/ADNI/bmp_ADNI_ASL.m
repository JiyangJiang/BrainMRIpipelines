%
% STRATEGY TO GET BIDS SESSION LABEL
% ==============================================================================================================
%
% [DICOM]:PatientID/PatientName.FamilyName                    <->  SUBJECT:[MRILIST.csv]:SERIESID <->  LONIUID:[UCSF FS ASL 15/22]:VISCODE2  <-> [session label in BIDS]
%                                                                          [MRILIST.csv]:IMAGEUID <-> IMAGEUID:[UCSF FS ASL 15/22]:VISCODE2  <-> [session label in BIDS]
% [DICOM]:StudyDate/SeriesDate/AcquisitionDate/ContentDate    <-> SCANDATE:[MRILIST.csv]
%
%
% KNOWN ISSUES
% ==============================================================================================================
%
% - How to use UCSFASLQC.csv?
%
% ==============================================================================================================

% MRI list (MRILIST.csv)
mri_list_opts = detectImportOptions ('MRILIST.csv');

mri_list_opts.ImportErrorRule = 'error';
mri_list_opts.ExtraColumnsRule = 'error';

mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'STUDYID'))) = {'char'};
mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'SERIESID'))) = {'char'};
mri_list_opts.VariableTypes(find(strcmp(mri_list_opts.VariableNames,'IMAGEUID'))) = {'char'};

mri_list = readtable ('MRILIST.csv', mri_list_opts);


% UCSF ASL QC
ucsf_asl_qc_opts = detectImportOptions ('UCSFASLQC_Jmod2.csv');

ucsf_asl_qc_opts.VariableTypes{1,2} = 'char';
ucsf_asl_qc_opts.VariableTypes{1,3} = 'char';

ucsf_asl_qc_opts.MissingRule = 'error';
ucsf_asl_qc_opts.ImportErrorRule = 'error';
ucsf_asl_qc_opts.ExtraColumnsRule = 'error';

ucsf_asl_qc = readtable ('UCSFASLQC_Jmod2.csv', ucsf_asl_qc_opts);


% UCSF ASL FreeSurfer 11_02_15 V2 (UCSFASLFS_11_02_15_V2.csv)
ucsf_asl_fs_15_opts = detectImportOptions ('UCSFASLFS_11_02_15_V2.csv');

ucsf_asl_fs_15_opts.ImportErrorRule = 'error';
ucsf_asl_fs_15_opts.ExtraColumnsRule = 'error';

ucsf_asl_fs_15_opts.VariableTypes(find(strcmp(ucsf_asl_fs_15_opts.VariableNames,'LONIUID'))) = {'char'};
ucsf_asl_fs_15_opts.VariableTypes(find(strcmp(ucsf_asl_fs_15_opts.VariableNames,'IMAGEUID'))) = {'char'};

ucsf_asl_fs_15 = readtable ('UCSFASLFS_11_02_15_V2.csv', ucsf_asl_fs_15_opts);
ucsf_asl_fs_15_useful = ucsf_asl_fs_15(:,1:10);


% UCSF ASL FreeSurfer CBF 08_17_22 (UCSFASLFSCBF_08_17_22.csv)
ucsf_asl_fs_22_opts = detectImportOptions ('UCSFASLFSCBF_08_17_22.csv');

ucsf_asl_fs_22_opts.ImportErrorRule = 'error';
ucsf_asl_fs_22_opts.ExtraColumnsRule = 'error';

ucsf_asl_fs_22_opts.VariableTypes(find(strcmp(ucsf_asl_fs_22_opts.VariableNames,'LONIUID'))) = {'char'};
ucsf_asl_fs_22_opts.VariableTypes(find(strcmp(ucsf_asl_fs_22_opts.VariableNames,'IMAGEUID'))) = {'char'};

ucsf_asl_fs_22 = readtable ('UCSFASLFSCBF_08_17_22.csv', ucsf_asl_fs_22_opts);
ucsf_asl_fs_22_useful = ucsf_asl_fs_22(:,1:11);



% % ADNIMERGE
% adni_merge_opts = detectImportOptions ('ADNIMERGE_Jmod.csv');

% adni_merge_opts.ExtraColumnsRule = 'error';
% adnimerge_opts.VariableTypes(find(strcmp(adnimerge_opts.VariableNames, 'IMAGEUID'))) = {'char'};

% adni_merge = readtable ('ADNIMERGE_Jmod.csv', adni_merge_opts);