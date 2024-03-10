% function varargout = bmp_VCI (operation_mode, varargin)
%
% DESCRIPTION
%
%   This script converts DICOM files acquired from the Siemens
%   Prisma scanner at Research Imaging NSW to BIDS-compatible
%   NIFTI files.
%
% ==============================================================
%                             USAGE
% ==============================================================

%   

individual_original_DICOM_directory = '/data/vci/pilotPS/Carbogen_volunteer_PS/DICOM';
cohort_BIDS_directory = '/data/vci/pilotPS/Carbogen_volunteer_PS/BIDS';
BIDS_subject_label = 'pilotPS';


BMP_VCI = bmp_VCI_initialiseBmpVci (individual_original_DICOM_directory, cohort_BIDS_directory, BIDS_subject_label, 'notRunningDicomCollection'); % 'notRunningDicomCollection' for internal testing.
BMP_VCI.BIDS.dicomCollection = load('/data/vci/pilotPS/Carbogen_volunteer_PS/dcm_collection.mat').dcm_coll2; % for testing

BMP_VCI = bmp_VCI_organiseDicomDir (BMP_VCI);

BMP_VCI = bmp_VCI_generateDcm2niixCmd (BMP_VCI, 'runDcm2niix');



