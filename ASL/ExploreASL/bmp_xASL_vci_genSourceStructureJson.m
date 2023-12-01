function [vci_ss] = bmp_xASL_vci_genSourceStructureJson (BIDS_dir)
% DESCRIPTION:
% ============================================================================
% This script generate sourcestructure.json file for processing VCI
% ASL data from RINSW Siemens Prisma scanner using ExploreASL.
%
% REFERENCES:
% ============================================================================
% 1. https://exploreasl.github.io/Documentation/1.11.0/Tutorials-Import/
%
% AUTHOR:
% ============================================================================
% Jiyang Jiang, PhD
%
% HISTORY:
% ============================================================================
% 
% 2023.12.01 - 1st version 
% 

% Example sourcestructure.json
% {  
%        "folderHierarchy": ["^(\\d{3}).*", "^Session([12])$","^(PSEUDO_10_min|T1-weighted|M0)$"],
%        "tokenOrdering": [ 1 0 2 3],
%        "tokenSessionAliases": ["^1$", "ASL_1", "^2$", "ASL_2"],
%        "tokenVisitAliases": ["", ""],
%        "tokenScanAliases": [ "^PSEUDO_10_min$", "ASL4D", "^M0$", "M0", "^T1-weighted$", "T1w"],
%        "bMatchDirectories": true,
%        "dcm2nii_version":"20220720",
% }

vci_ss.folderHierarchy(1) = "^(vci\d{3})$";
vci_ss.folderHierarchy(2) = "^(MEMPRAGE_RMS|ASL_ASL)$";

vci_ss.tokenOrdering = [1 0 0 2];

vci_ss.tokenScanAliases(1) = "^MEMPRAGE_RMS$";
vci_ss.tokenScanAliases(2) = "T1w";
vci_ss.tokenScanAliases(3) = "^ASL_ASL$";
vci_ss.tokenScanAliases(4) = "ASL4D";

% 2023.12.01 - 	what if M0 within ASL?
%				add FLAIR
%				add WMH

vci_ss.bMatchDirectories = true;

fid = fopen(fullfile(BIDS_dir, 'sourcestructure.json'), 'w');
fprintf(fid,'%s', jsonencode(vci_ss, PrettyPrint=true));
fclose(fid);