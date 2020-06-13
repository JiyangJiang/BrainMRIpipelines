L1precision_path = '/home/jiyang/Software/L1precision';
FSLnets_path='/data_pub/Software/FSL/fsl-5.0.11/FSLNets/FSLNets';

working_dir = '/data2/jiyang/UKBB/1771_rsfMRI_IDPs/test';

addpath (L1precision_path, FSLnets_path);

addpath(sprintf('%s/etc/matlab',getenv('FSLDIR')));

addpath (mfilename ('fullpath'));


for dim = {'25', '100'}
	curr_dim = dim{1};

	list = dir ([working_dir '/*_d' curr_dim '_dr_stage1.txt']);
	
	parfor (i = 1 : size (list,1), 22)

		id = list(i).name;
		id = strsplit(id,'_');
		id = id{1};

		ts = fmri_ukbb_netsload_Jmod ([list(i).folder '/' list(i).name],...
									  0.735,...
									  0,...
									  1,...
									  490);
		if strcmp(curr_dim,'25')
          ts.DD=[setdiff([1:25],[4 23 24 25])];
          r2zFULL=10.6484;
          r2zPARTIAL=10.6707;
        else
          ts.DD=[setdiff([1:100],[1 44 47 51 54 55 56 59 61 62 65:92 94:100])];
          r2zFULL=19.7177;
          r2zPARTIAL=18.8310;
        end
        
        ts=nets_tsclean(ts,1);

        netmats1=  nets_netmats(ts,-r2zFULL,'corr');
        netmats2=  nets_netmats(ts,-r2zPARTIAL,'ridgep',0.5);
     
        clear NET; 

        grot=reshape(netmats1(1,:),ts.Nnodes,ts.Nnodes); 


        NET(i,:)=grot(triu(ones(ts.Nnodes),1)==1); 
        
        % +++++++++++++ %
        % NOT COMPLETED %
        % +++++++++++++ %


        % po=fopen(strcat(subj_dir, '/fMRI/', sprintf('rfMRI_d%s_fullcorr_v1.txt',D)),'w');
        % fprintf(po,[ num2str(NET(1,:),'%14.8f') '\n']);  
        % fclose(po);

        % clear NET; 

        % grot=reshape(netmats2(1,:),ts.Nnodes,ts.Nnodes); 
        % NET(1,:)=grot(triu(ones(ts.Nnodes),1)==1); 

        % po=fopen(strcat(subj_dir, '/fMRI/', sprintf('rfMRI_d%s_partialcorr_v1.txt',D)),'w'); 
        % fprintf(po,[num2str(NET(1,:),'%14.8f') '\n']);  
        % fclose(po);

        % ts_std=std(ts.ts);

        % po=fopen(strcat(subj_dir, '/fMRI/', sprintf('rfMRI_d%s_NodeAmplitudes_v1.txt',D)),'w');

        % fprintf(po,[num2str(ts_std(1,:),'%14.8f') '\n']);  
        % fclose(po);


	end


end