
% NOTE
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% prior to running this script:
%
% 1. transpose rows/columns by running future_fmri_graphTheory_transpose.sh
%
%
% 2. Exclude netts with inconsistent number of columns/rows
%
% for i in *.txt;do ncol=$(awk '{print NF; exit}' $i);[ "$ncol" != 7 ] && mv $i not7col/.;done
% for i in *.txt;do nrow=$(wc -l $i | awk '{print $1}');[ "$nrow" != 490 ] && mv $i not490rows/.;done

FSLnets_path='/data_pub/Software/FSL/fsl-5.0.11/FSLNets/FSLNets';
libsvm_path='/data_pub/Software/FSL/fsl-5.0.11/FSLNets/LIBSVM/libsvm-3.23/matlab';
tr = 0.735;
netts_dir = '/data2/jiyang/heidi_regularisedPartialCorr/netts_transposed';

nROI = 7;

addpath  (FSLnets_path);
addpath (sprintf('%s/etc/matlab', getenv ('FSLDIR')));
addpath (libsvm_path);

all_txt = dir (fullfile(netts_dir,'*.txt'));


% load timeseries
ts = nets_load (netts_dir,tr,0);

% regularised partial correlation
Pnetmats = nets_netmats (ts, 1, 'ridgep', 0.1);

parfor i = 1 : size(Pnetmats,1)
	tmp = strsplit (all_txt(i).name,'_');
	id  = tmp{1};

	mtx = reshape (Pnetmats(i,:),nROI,nROI);

	csvwrite(fullfile('regularised_partial_correlation',...
					  [id '_ridgep0p1.txt']),...
			 mtx);
end