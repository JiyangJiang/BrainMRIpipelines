function ADNI3 = bmp_ADNI_pickADNI3 (bmp_ADNI_mat)

	% Pick ADNI3 from bmp_ADNI.mat

	bmp_path = getenv ('BMP_PATH');

	MRI_master = load (fullfile (bmp_path, 'BIDS', 'bmp_ADNI.mat')).MRI_master;

	ADNI3.MRI_master_ADNI3 = MRI_master(find(strcmp(MRI_master.COLPROT,'ADNI3')),:);

	ADNI3.SID_and_sesID = table (strcat('sub-ADNI', strrep(ADNI3.MRI_master_ADNI3.SID,'_S_', 'S')), strrep(strrep(ADNI3.MRI_master_ADNI3.VISCODE,'bl','M00'),'m','M'));

	ADNI3.SID_and_sesID.Properties.VariableNames={'SID';'sesID'};

	ADNI3.SID_and_sesID	(strcmp (ADNI3.SID_and_sesID.SID,   'sub-ADNI'),:) = [];
	ADNI3.SID_and_sesID	(strcmp (ADNI3.SID_and_sesID.sesID, 'sc'),  :) = [];

	ADNI3.SID_and_sesID = unique (ADNI3.SID_and_sesID);

	ADNI3.SID_and_sesID_and_newSesID = table;

	uniq_SID_list = unique(ADNI3.SID_and_sesID.SID);

	for i = 1:size(uniq_SID_list,1)
		currSIDandSESID = ADNI3.SID_and_sesID(find(strcmp(ADNI3.SID_and_sesID.SID,uniq_SID_list(i,1))),:);
		currSIDandSESID_sesIDremoveM = cellfun (@str2num, erase (currSIDandSESID.sesID,'M'));
		currtable = horzcat(currSIDandSESID, table(currSIDandSESID_sesIDremoveM, 'VariableNames',{'new_sesID'}));
		currtable.new_sesID = currtable.new_sesID - min(currtable.new_sesID);
		currtable.new_sesID = strcat('M',pad(strrep(cellstr(num2str(currtable.new_sesID)),' ',''),2,'left','0'));
		ADNI3.SID_and_sesID_and_newSesID = vertcat (ADNI3.SID_and_sesID_and_newSesID, currtable);
	end

	% generate shell scripts to move ADNI3
	ADNI3_cmd1 = strcat ({'mkdir -p ADNI3/'}, ADNI3.SID_and_sesID_and_newSesID.SID);
	fid = fopen('bmp_ADNI_pickADNI3_generatedCMD1.txt', 'w');
	fprintf(fid, '%s\n', ADNI3_cmd1{:});
	fclose(fid);


	ADNI3_cmd2 = strcat ({'mv '}, ADNI3.SID_and_sesID_and_newSesID.SID, '/ses-', ADNI3.SID_and_sesID_and_newSesID.sesID, {' ADNI3/'}, ADNI3.SID_and_sesID_and_newSesID.SID, '/ses-', ADNI3.SID_and_sesID_and_newSesID.new_sesID);
	% writecell (ADNI3_cmd1, 'bmp_ADNI_pickADNI3_generatedCMD1.txt');
	fid = fopen('bmp_ADNI_pickADNI3_generatedCMD2.txt', 'w');
	fprintf(fid, '%s\n', ADNI3_cmd2{:});
	fclose(fid);

	ADNI3_cmd3 = strcat ({'rename '}, ADNI3.SID_and_sesID_and_newSesID.sesID, {' '}, ADNI3.SID_and_sesID_and_newSesID.new_sesID, {' ADNI3/'}, ADNI3.SID_and_sesID_and_newSesID.SID, '/ses-', ADNI3.SID_and_sesID_and_newSesID.new_sesID, '/*/*');
	% writecell (ADNI3_cmd2, 'bmp_ADNI_pickADNI3_generatedCMD2.txt');
	fid = fopen('bmp_ADNI_pickADNI3_generatedCMD3.txt', 'w');
	fprintf(fid, '%s\n', ADNI3_cmd3{:});
	fclose(fid);

	ADNI3_cmd4 = strcat ({'rename '}, ADNI3.SID_and_sesID_and_newSesID.sesID, {' '}, ADNI3.SID_and_sesID_and_newSesID.new_sesID, {' ADNI3/'}, ADNI3.SID_and_sesID_and_newSesID.SID, '/ses-', ADNI3.SID_and_sesID_and_newSesID.new_sesID, '/*.tsv');
	% writecell (ADNI3_cmd3, 'bmp_ADNI_pickADNI3_generatedCMD3.txt');
	fid = fopen('bmp_ADNI_pickADNI3_generatedCMD4.txt', 'w');
	fprintf(fid, '%s\n', ADNI3_cmd4{:});
	fclose(fid);

	ADNI3_cmd5 = strcat ({'sed -i s/'}, ADNI3.SID_and_sesID_and_newSesID.sesID, '/', ADNI3.SID_and_sesID_and_newSesID.new_sesID, {'/g ADNI3/'}, ADNI3.SID_and_sesID_and_newSesID.SID, '/ses-', ADNI3.SID_and_sesID_and_newSesID.new_sesID, '/*.tsv');
	% writecell (ADNI3_cmd4, 'bmp_ADNI_pickADNI3_generatedCMD4.txt');
	fid = fopen('bmp_ADNI_pickADNI3_generatedCMD5.txt', 'w');
	fprintf(fid, '%s\n', ADNI3_cmd5{:});
	fclose(fid);