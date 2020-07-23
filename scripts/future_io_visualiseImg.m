function future_io_visualiseImg (folder_and_fnamePattern)

% using FSL's slicesdir if in Unix system
if isunix
	[folder,~,~] = fileparts (folder_and_fnamePattern);
	system (['cd ' folder ';slicesdir ' folder_and_fnamePattern]);
end