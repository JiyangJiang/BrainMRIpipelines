% This script loop all dicom files, anonymise and zip them
% folder structure: studyFolder/subjID/modality/dicomFiles
%
% studyFolder.zip is the final output


function anonymiseAndZip (studyFolder)

subjDIR = dir (studyFolder);

for i = 3:size(subjDIR,1)
    cd(studyFolder);
    modalityDIR = dir (subjDIR(i).name);
   
    
    for j = 3:size(modalityDIR,1)
        fprintf ('Anonymising %s of %s ...', modalityDIR(j).name, subjDIR(i).name);
        
        cd (subjDIR(i).name);
        dicomFile = dir (modalityDIR(j).name);
        
        for k = 3:size(dicomFile,1)
            dicomImg = [studyFolder '\' subjDIR(i).name '\' modalityDIR(j).name '\' dicomFile(k).name];
            dicomanon (dicomImg, dicomImg);
        end
        
        fprintf ('   Done.\n');
        
        fprintf ('Zipping %s of %s ...', modalityDIR(j).name, subjDIR(i).name);
        
        zip ([studyFolder '\' subjDIR(i).name '\' modalityDIR(j).name '.zip'], ...
                [studyFolder '\' subjDIR(i).name '\' modalityDIR(j).name]);
            
        fprintf ('   Done.\n');
        
        cd ..
    end
    
    fprintf ('Zipping %s ...', subjDIR(i).name);
    zip ([studyFolder '\' subjDIR(i).name '.zip'], ...
                [studyFolder '\' subjDIR(i).name '\*.zip']);
    fprintf ('   Done.\n');
   
end

fprintf ('Zipping study folder ...');
zip ([studyFolder '.zip'], [studyFolder '\*.zip']);
fprintf ('   Done.\n');