function bmp_BIDSparser (BIDS_directory)
%
% DESCRIPTION
% ======================================================
% This MATLAB script aims to call BIDS-MATLAB functions
% to parse BIDS directory, and generate csv files
% for BMP to use through shell commands.
%
% HISTORY
% ======================================================
% 28 Nov 2022 - Written by Jiyang Jiang

BMP_PATH     = getenv ('BMP_PATH');
BMP_3RD_PATH = getenv ('BMP_3RD_PATH');
addpath (fullfile (BMP_3RD_PATH, 'bids-matlab'));
addpath (fullfile (BMP_PATH, 'BIDS'));

BIDS_directory_layout = bids.layout('root', BIDS_directory, ...
				                   'use_schema', true, ...
				                   'index_derivatives', false, ... % 'derivatives' folder not to be parsed.
				                   'tolerant', true, ...
				                   'verbose', true);