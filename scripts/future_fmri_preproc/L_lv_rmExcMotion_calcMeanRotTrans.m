

% DESCRIPTION
% ----------------------------------------------------------------------------------------------------------------------
% This script has two functions:
%
% 1) removes motion (transition/rotation) exceeds defined threshold (thr). Note that for simplicity, transition
% and rotation should be set to the same threshold value (e.g. 2 mm and 2 degrees). Because this function is called by
% shell, thr is passed as text.
%
% 2) For those motion did not exceed threshold, calculate average motion for each subject, to compare between groups.
%
%
% REFERENCES
% ----------------------------------------------------------------------------------------------------------------------
% 1) Schumacher et al. "Functional connectivity in dementia with Lewy bodies : A within- and between-network analysis"
% Human Brain Mapping 2018. NOTE THAT THE EQUATION HAS TYPO. see 2nd ref for details
%
% 2) https://www.sciencedirect.com/science/article/pii/S1053811910007160?via%3Dihub
%
% 3) https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;2af6a053.1011



function L_lv_rmExcMotion_calcMeanRotTrans (cleanup_mode, studyFolder, thr)

	[cohortFolder, subjID, ~] = fileparts (studyFolder);

	switch cleanup_mode
		case 'aroma'
			six_motion_param_file = [studyFolder '/' subjID '_func.feat/mc/prefiltered_func_data_mcf.par'];
		case 'fix'
			six_motion_param_file = [studyFolder '/' subjID '_func.ica/mc/prefiltered_func_data_mcf.par'];
	end
	
	six_motion_param = dlmread (six_motion_param_file);

	if any (six_motion_param (:) > str2num (thr))

		fprintf ('%s is removed due to excessive motion.\n', subjID);
		movefile (studyFolder, [cohortFolder '/excessive_motion']);

	else

		%
		% Calculate average motion/rotation
		% The order of the 6 columns is Rx Ry Rz Tx Ty Tz
		%
		% Ref : https://www.sciencedirect.com/science/article/pii/S1053811910007160?via%3Dihub
		%       https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;2af6a053.1011
		% 
		mean_rotation = 0;
		mean_transition = 0;
		for i = 2 : size (six_motion_param,1)
		mean_rotation = mean_rotation + sqrt (abs (six_motion_param(i,1) - six_motion_param((i-1),1)) ^ 2 ...
							   				  + abs (six_motion_param(i,2) - six_motion_param((i-1),2)) ^ 2 ...
							   				  + abs (six_motion_param(i,3) - six_motion_param((i-1),3)) ^ 2);

		mean_transition = mean_transition + sqrt (abs (six_motion_param(i,4) - six_motion_param((i-1),4)) ^ 2 ...
										          + abs (six_motion_param(i,5) - six_motion_param((i-1),5)) ^ 2 ...
										          + abs (six_motion_param(i,6) - six_motion_param((i-1),6)) ^ 2);
		end
		mean_rotation = mean_rotation / (size (six_motion_param,1) - 1);
		mean_transition = mean_transition / (size (six_motion_param,1) - 1);

		% write to output
		csvwrite ([cohortFolder '/confounds/motion_params/' subjID '.mean.rot.trans'], [mean_rotation mean_transition]);
		
	end

	

