Processing multi PLD ASL data from VCI and MAS2 studies using ExploreASL
------------------------------------------------------------------------

..  code-block::

	## in Shell
	## ++++++++++++++++++++++
	module load matlab/R2019a
	matlab &   # OR matlab -nodesktop -nodisplay

	%% in MATLAB
	%% ++++++++++++++++++++++
	addpath('/srv/scratch/cheba/Imaging/software/ExploreASL-1.10.1')

	% 1. Convert DICOM to BIDS
	DatasetRoot = '/srv/scratch/cheba/Imaging/mas2/ppt1/dnld_from_flywheel/asl/dicom/mTI16_800-3800_tgse_pcasl_3.4x3.4x4_14_31_2_24slc';
	ImportModules = [1 1 0 0]; % yes DCM2NII, no NII2BIDS, no DEFACE, no BIDS2LEGACY
	ProcessModules = [0 0 0]; % no structural processing, no ASL processing, no population processing
	bPause = 0; % not pause workflow before ExploreASL pipeline
	iWorker = 8;
	nWorkers = 8;

	[x] = ExploreASL([DatasetRoot, ImportModules, ProcessModules, bPause, iWorker, nWorkers])