function ADNI3 = bmp_ADNI_pickADNI3 (bmp_ADNI_mat)

	% Pick ADNI3 from bmp_ADNI.mat

	bmp_path = getenv ('BMP_PATH');

	MRI_master = load (fullfile (bmp_path, 'BIDS', 'bmp_ADNI.mat')).MRI_master;

	ADNI3.MRI_master_ADNI3 = MRI_master(find(strcmp(MRI_master.COLPROT,'ADNI3')),:);

	ADNI3.SID_and_sesID = table (strcat('sub-', strrep(ADNI3.MRI_master_ADNI3.SID,'_S_', 'S')), ...
								 strrep(strrep(ADNI3.MRI_master_ADNI3.VISCODE,'bl','M00'),'m','M'));

	ADNI3.SID_and_sesID.Properties.VariableNames={'SID';'sesID'};

	ADNI3.SID_and_sesID	(strcmp (ADNI3.SID_and_sesID.SID,   'sub-'),:) = [];
	ADNI3.SID_and_sesID	(strcmp (ADNI3.SID_and_sesID.sesID, 'sc'),  :) = [];

	ADNI3.SID_and_sesID = unique (ADNI3.SID_and_sesID);

	ADNI3.SID_and_sesID_and_newSesID = table;

	uniq_SID_list = unique(ADNI3.SID_and_sesID.SID);

	for i = 1:size(uniq_SID_list,1)
		currSIDandSESID = ADNI3.SID_and_sesID(find(strcmp(ADNI3.SID_and_sesID.SID,uniq_SID_list(i,1))),:);
		currSIDandSESID_sesIDremoveM = cellfun (@str2num, erase (currSIDandSESID.sesID,'M'));
		currtable = horzcat(currSIDandSESID, table(currSIDandSESID_sesIDremoveM, 'VariableNames',{'new_sesID'}));
		currtable.new_sesID = currtable.new_sesID - min(currtable.new_sesID);
		currtable.new_sesID = strcat('M',strrep(cellstr(num2str(currtable.new_sesID)),' ',''));
		ADNI3.SID_and_sesID_and_newSesID = vertcat (ADNI3.SID_and_sesID_and_newSesID, currtable);
	end

	% generate shell scripts to move ADNI3