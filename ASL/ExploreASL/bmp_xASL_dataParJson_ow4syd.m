
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
x.external.bAutomaticallyDetectFSL = true;	% Default is false, i.e., not automatically
											% detecting FSL.

% study
x.SESSIONS = {'OW4_Syd'};		% Defined session.
x.session.options = {'ow4'};	% Define how session is called.

% dataset
x.dataset.subjectRegexp = '^\d{6}$';	% String expression to find subjects
% x.dataset.exclusion = {''};
% x.dataset.ForceInclusionList = 

% M0
x.modules.asl.M0_conventionalProcessing = 0;
x.modules.asl.M0_GMScaleFactor = 1;             % M0 GM scaling factor - need further attention
x.modules.asl.M0PositionInASL4D = [];			% M0 is separate from ASL4D.
x.modules.asl.DummyScanPositionInASL4D = [];

% quantification
x.Q.bUseBasilQuantification = false;	% Not using BASIL quantification, instead of ExploreASL's
x.Q.Lambda = 0.9;
x.Q.T2art = 50;
x.Q.BloodT1 = 1650;
x.Q.TissueT1 = 1240;
x.Q.nCompartments = 1;
x.Q.SaveCBF4D = true;	% Save 4D CBF

% ASL processing
x.modules.asl.motionCorrection = 1;
x.modules.asl.SpikeRemovalThreshold = 0.01;
x.modules.asl.bRegistrationContrast = 2;
x.modules.asl.bAffineRegistration = 1; 	% Default is 0 (disable affine after ASL->T1w rigid-body).
										% Here choose 1 to force affine.