% this script display the IDs with motion outliers
% defined by > 2 mm/degrees in traslation/rotation

folder_6motionParams = '/data3/imaging/UKBB/for_heidi/rs/Jmod/6motionParams';

all = dir ([folder_6motionParams '/*.6motionParams']);

fprintf ('EXCLUSION LIST:\n');

for i = 1:19825
	data=dlmread ([all(i).folder '/' all(i).name]);

	tmp = strsplit (all(i).name, '.');

	subjID = tmp{1};

	if sum(sum(data > 2 |data < -2)) > 1
		fprintf ('%s\n', subjID);
	end
end