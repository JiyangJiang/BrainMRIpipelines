function bmp_BIDSgenerator (varargin)
%
% DESCRIPTION
% ======================================================================================
%   BrainMRIpipelines BIDS converter (bmp_BIDSgenerator) aims to convert DICOM files to 
%   NIFTI files and store them in BIDS folder structure with BIDS-compliant filenames.
%














% FOR DATASET-LEVEL/SUBGROUP-LEVEL MAPPING, IGNORE 'session' AND/OR 'run' IF THERE IS
% ONLY ONE SESSION LABEL AND/OR ONE RUN INDEX SPECIFIED IN DICOM2BIDS.
% ###################################################################################

% FOR DATASET-/SUBGROUP-LEVEL MAPPINGS, USE SUB-FOLDER NAMES IN DICOM DIRECTORY
% AS SUBJECT LABEL.
% ####################################################################################