
% DESCRIPTION:
% ============================================================================
% This script generate dataPar.json file for processing OATS Wave 4
% ASL data from Sydney Philips scanner using ExploreASL.
%
% REFERENCES:
% ============================================================================
% 1. https://exploreasl.github.io/Documentation/1.10.0/ProcessingParameters/
%
% AUTHOR:
% ============================================================================
% Jiyang Jiang, PhD
%
% HISTORY:
% ============================================================================
% 20230616 - Created 1st version.
%
% 

% environment
x.external.bAutomaticallyDetectFSL = true;

% study
x.SESSIONS = {'OW4_Syd'};
x.session.options = {'ow4'};

% dataset
x.dataset.subjectRegexp = '^\d{6}$';
% x.dataset.exclusion = {''};
% x.dataset.ForceInclusionList = 

% M0
x.modules.asl.M0_conventionalProcessing = 0;
x.modules.asl.M0_GMScaleFactor = 1;              % <-- need further intention
x.modules.asl.M0PositionInASL4D = []; % M0 is separate from ASL4D.
x.modules.asl.DummyScanPositionInASL4D = [];

% quantification
x.Q.bUseBasilQuantification = true;
x.Q.Lambda = 0.9;
% x.Q.T2art = ;
x.Q.BloodT1 = 1650;
x.Q.TissueT1 = 1240;
x.Q.nCompartments = 1;
x.Q.SaveCBF4D = true;