% This script distributes commands in cmdTXT to all CPU cores
% varargin{1} = $FREESURFER_HOME (default = /data_int/jiyang/freesurfer (GRID))

function runReconall (cmdTXT, subjectsDir, varargin)

cmdTBL = readtable (cmdTXT, 'ReadVariableNames', false, ...
				   		    'ReadRowNames', false, ...
				   		    'Delimiter', '\n');

cmdCellArr = table2cell (cmdTBL);

Ncmd = size (cmdCellArr, 1);

if nargin == 3
	freesurferHome = varargin{1};
elseif nargin == 2
	freesurferHome = '/data_pub/Software/FreeSurfer/FS-6.0.0';
end

parfor i = 1:Ncmd
	system (['export FREESURFER_HOME=' freesurferHome ';' ...
			 'source ${FREESURFER_HOME}/SetUpFreeSurfer.sh;' ...
			 'export SUBJECTS_DIR=' subjectsDir ';' ...
			 'rm -f ' subjectsDir '/*/scripts/IsRunning.lh+rh;' ...
			 cmdCellArr{i} ' > ' subjectsDir '/reconall_logfile_' num2str(i) '.txt']);
end