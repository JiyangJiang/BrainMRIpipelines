FSLnets_path='/data_pub/Software/FSL/fsl-5.0.11/FSLNets/FSLNets';
libsvm_path='/data_pub/Software/FSL/fsl-5.0.11/FSLNets/LIBSVM/libsvm-3.23/matlab';

% dual-regression output folder
% dualReg_folder = '/data2/jiyang/FSLNets/dr_d72';

% dualReg_folder = '/data2/jiyang/FSLNets/dr_d32';
% dualReg_folder = '/data2/jiyang/FSLNets/dr_d32/dr1_grp1'; % for plotting in each group
% dualReg_folder = '/data2/jiyang/FSLNets/dr_d32/dr1_grp2';

% dualReg_folder = '/data2/jiyang/FSLNets/dr_d70';
% dualReg_folder = '/data2/jiyang/FSLNets/dr_d100';

dualReg_folder = '/data2/jiyang/FSLNets/new_dr_d32';
% dualReg_folder = '/data2/jiyang/FSLNets/dartel_dr_d30';


% TR
tr = 2;
% slice summary folder (without .sum suffix)
% slc_sum = '/data2/jiyang/FSLNets/d72';
% slc_sum = '/data2/jiyang/FSLNets/d32';
slc_sum = '/data2/jiyang/FSLNets/new_d32';
% slc_sum = '/data2/jiyang/FSLNets/dartel_dr_d30';

% path to the folder containing the design matrix and contrasts
desmtx_con_path = '/data2/jiyang/FSLNets/des_mtx';
% design matrix and contrast base name for group comparison
% desmtx_con_basename = 'conVScent_adjSEXandEDU_gmCovMap_fslOrder';
desmtx_con_basename = 'CONgtCENT_adjSEXandEDU_4FSLNets';
desmtx_con_basename = 'CONltCENT_adjSEXandEDU_4FSLNets';

% desmtx_con_basename = 'conVScent_NOadj_fslOrder';

% ============================================================================================ %


% NOTE
% - Do not use the statistics package with octave, instead, use MATLAB.
% - Do not use the libraries distributed with FSLNets tutorial.
% - The 'addpath' below works fine.

% =======
% addpath
% =======

% FSLNets
% -------
% addpath /home/jiyang/Work/fMRI/FSL-course/ICA_MELODIC_DualRegression/rest/FSLNets
addpath  (FSLnets_path);

% FSL's MATLAB
% ------------
addpath (sprintf('%s/etc/matlab', getenv ('FSLDIR')))

% statistics
% ----------
% addpath /home/jiyang/Work/fMRI/FSL-course/ICA_MELODIC_DualRegression/rest/octave/statistics-1.2.4/inst

% libsvm
% ------
% addpath /home/jiyang/Work/fMRI/FSL-course/ICA_MELODIC_DualRegression/rest/octave/libsvm/matlab
addpath (libsvm_path);

% addpath current directory
[currdir, ~, ~] = fileparts (mfilename ('fullpath'));
addpath (currdir);


% ========================================================================= %
% Remove the last two columns, which correspond to WM and CSF timeseries.   %
% These two timeseries were manually added to regress out any physiological %
% noise when doing dual regression (i.e. multivariate regression)           %
% ========================================================================= %
% NW_fslnets_rmWMCSFtsFromDR1txt (dualReg_folder);

% ====================================================================
% Loading all subjects' timeseries data files from the dual-regression
% output directory
% ====================================================================
% - Here 0 is specified to avoid normalising timeseries.
ts = nets_load (dualReg_folder,...
				tr,...
				0);

% ============================================================
% Visualising and checking the temporal spectra of the RSNs.
% ------------------------------------------------------------
% The following command will show a figure in which the left
% part of the plot shows one spectrum per group-ICA component
% (node, ICA component = node), each averaged across all
% subjects. The right part shows the same thing, but with all
% spectra overlapping.
% ============================================================
% - left plot : frequency spectrum of each node (i.e. IC) averaged
%               across all subjects. grey line = average across 
%               all nodes. Therefore, the grey line is identical
%               for each component.
% - left plot : raised tail = noise node.
% - right plot : all ICs' spectra normalised to peak 1 and overlaid.
%                black line = mean spectrum.
% - right plot : largest value = Nyquist frequency, 1/TR/2,
%                Here : 0.69 Hz.
%
% X-axis = frequency range
% Y-axis = power
% ------------------------------------------------------------
% - TR relates to the maximum frequency that can be measured.
% - Q : Why do the plots show that all nodes have high power
%       in the low-frequency range?
%   A : Because the hemodynamic response function is very slow
%       and therefore neural fluctuations are mainly seen as
%       slow fluctuations in the BOLD signal.
%       Neural responses are measured indirectly in BOLD, and
%       fluctuations are expected to vary slowly as a result
%       of the hemodynamic response function (HRF).
% ------------------------------------------------------------
% J : raised tail ? Nyquist frequency ?
% ts_spectra = nets_spectra (ts);

% ============================================================
%                          Cleanup
% ============================================================
% - components' (nodes') timeseries that correspond to artefacts
%   rather than plausible nodes can be removed.
% - Similar to subject-level cleanup, you need to decide this
%   by looking at the spatial maps, timecourses, and frequency
%   spectra.
% - DD specifies 'good' components.
% - Note that fslview display starting from 0, whereas here
%   the index should start from 1.
% -------------------------------------------------------------

% dim = 70
% ts.DD = [1,3:5,7:9,12:14,17:19,21,22,27,33,38,46,47,54:56]; % spt corr > 0.7
% ts.DD = [1,3:5,7:9,12:14,17:19,21,22,27,33,34,37,38,40,46,47,54:56,59]; % spt corr > 0.7 plus four 
% 																	    % visually selected.
% % dim = 30
% ts.DD = [1:5,7,8,10,13,17,18,20,24]; % spt corr > 0.6
% ts.DD = [1:4,7,8,17];             % spt corr > 0.7

% new dim 30 (group ICA using whole sample)
ts.DD = [1:7,9:14,18:27];


% - input structure (ts) loaded previously.
% - aggressive or soft cleanup. Here 1 means aggressive.
%   soft cleanup = all node timeseries labelled as noise
%                  are simply removed from ts.ts
%   aggressive = all node timeseries labelled as noise
%                are regressed out of the signal node
%                timeseries.
% - output structure (ts) overwriting original ts.
ts = nets_tsclean (ts,1);


% ============================================================
%            Compute subject-level network matrix
% ============================================================
% - This subject-specific network matrix is in general a matrix
%   of connection strengths.
% - Here two different versions of these network matrices (netmat)
%   are computed :
%   - a simple full correlation ('corr')
%   - a partial correlation that has regularised in order to
%     potentially improve the mathematical robustness of the
%     estimation ('ridgep'). Partial correlation will regress
%     out the effects of timeseries from region B out of the
%     timeseries of both regions A and C before calculating
%     the correlation between A and C. Partial correlation is
%     only sensitive to direct connections, not indirect
%     connections.
%   - regularisation = use additional information in order to
%                      reduce noise. One approach is to threshold
%                      to get sparse network matrix.
% - The partial correlation matrix should do a better job of
%   only estimating the direct network connections than the full
%   correlation does.
% ----------------------------------------------------------------

% - inputs structure (ts)
% - apply Fisher's r-to-z transformation (1)
% - method of netmat estimation = simple full correlation ('corr')
Fnetmats = nets_netmats (ts, 1, 'corr');
% - 'ridgep' = regularised partial correlation
% - regularisation parameter (0.1) - i.e. sparsity (?)
Pnetmats = nets_netmats (ts, 1, 'ridgep', 0.1);

% -------------------------------------------------------------------
% The full and partial netmats are now calculated for all subjects.
% Run the following command to show the size of the Fnetmats variable.
% -------------------------------------------------------------------
size (Fnetmats)
%
% !!! The number of rows is equal to the number of subjects.
%     Each node-by-node network matrix is reshaped into a single line
%     (i.e. number of nodes * number of nodes).
% J : Not discarding one half mirrored across diagonal ?
% -------------------------------------------------------------------






% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%               GENERATING GRAPH THEORY MEASURES
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% ===================================================================
%        Jmod : output matrix for graph theory analyses
% ===================================================================
sparsity = 0.2;
sparsity_in_filename = 'sparsity0p2';

% addpath BCT
addpath('/home/jiyang/Work/BCT/2019_03_03_BCT');
% re-construct subject-level matrix without r-to-z transformation
Fnetmats_noR2Z = nets_netmats (ts, 0, 'corr');
Pnetmats_noR2Z = nets_netmats (ts, 0, 'ridgep', 0.1);


for i = 1 : ts.Nsubjects

	% +++++++++++++++++
	% Full correlations
	% +++++++++++++++++

	mtx_Fcorr = reshape (Fnetmats_noR2Z(i,:), [ts.Nnodes, ts.Nnodes]);

	% zero negative correlation
	mtx_Fcorr (mtx_Fcorr < 0) = 0;

	% threshold with specific sparsity
	mtx_Fcorr_thr = threshold_proportional (mtx_Fcorr, sparsity);

	% binarise
	mtx_Fcorr_thr_bin = mtx_Fcorr_thr;
	mtx_Fcorr_thr_bin (mtx_Fcorr_thr_bin > 0) = 1;

	% save adjacency matrix without negative correlation
	fid = fopen(['adjacencyMatrix_subject' num2str(i,'%04d') '_fullCorrelation.txt'],'wt');
	for ii = 1:ts.Nnodes
	    fprintf(fid,'%.5f\t',mtx_Fcorr(ii,:));
	    fprintf(fid,'\n');
	end
	fclose(fid);

	% save adjacency matrix without negative correlation, thresholded with sparsity, and
	% weighted edges.
	fid = fopen(['adjacencyMatrix_subject' num2str(i,'%04d') '_fullCorrelation_' sparsity_in_filename ...
				 '_wei.txt'],'wt');
	for ii = 1:ts.Nnodes
	    fprintf(fid,'%.5f\t',mtx_Fcorr_thr(ii,:));
	    fprintf(fid,'\n');
	end
	fclose(fid);

	% save adjacency matrix without negative correlation, thresholded with sparsity, and
	% binarised edges.
	fid = fopen(['adjacencyMatrix_subject' num2str(i,'%04d') '_fullCorrelation_' sparsity_in_filename ...
				 '_bin.txt'],'wt');
	for ii = 1:ts.Nnodes
	    fprintf(fid,'%d\t',mtx_Fcorr_thr_bin(ii,:));
	    fprintf(fid,'\n');
	end
	fclose(fid);

	% save 3D matrices with the 3rd dimention being across subjects
	mtx_Fcorr_thr_3D(:,:,i) = mtx_Fcorr_thr;
	mtx_Fcorr_thr_bin_3D(:,:,i) = mtx_Fcorr_thr_bin;


	% +++++++++++++++++++
	% partial correlation
	% +++++++++++++++++++

	mtx_Pcorr = reshape (Pnetmats_noR2Z(i,:), [ts.Nnodes, ts.Nnodes]);

	% zero negative correlation
	mtx_Pcorr (mtx_Pcorr < 0) = 0;

	% threshold with specific sparsity
	mtx_Pcorr_thr = threshold_proportional (mtx_Pcorr, sparsity);

	% binarise
	mtx_Pcorr_thr_bin = mtx_Pcorr_thr;
	mtx_Pcorr_thr_bin (mtx_Pcorr_thr_bin > 0) = 1;

	% save adjacency matrix without negative correlation
	fid = fopen(['adjacencyMatrix_subject' num2str(i,'%04d') '_partialCorrelation.txt'],'wt');

	for jj = 1:ts.Nnodes
	    fprintf(fid,'%.5f\t',mtx_Pcorr(jj,:));
	    fprintf(fid,'\n');
	end
	fclose(fid);

	% save adjacency matrix without negative correlation, thresholded with sparsity, and
	% weighted edges.
	fid = fopen(['adjacencyMatrix_subject' num2str(i,'%04d') '_partialCorrelation_' sparsity_in_filename ...
				 '_wei.txt'],'wt');
	for ii = 1:ts.Nnodes
	    fprintf(fid,'%.5f\t',mtx_Pcorr_thr(ii,:));
	    fprintf(fid,'\n');
	end
	fclose(fid);

	% save adjacency matrix without negative correlation, thresholded with sparsity, and
	% binarised edges.
	fid = fopen(['adjacencyMatrix_subject' num2str(i,'%04d') '_partialCorrelation_' sparsity_in_filename ...
				 '_bin.txt'],'wt');
	for ii = 1:ts.Nnodes
	    fprintf(fid,'%d\t',mtx_Pcorr_thr_bin(ii,:));
	    fprintf(fid,'\n');
	end
	fclose(fid);

	% save 3D matrices with the 3rd dimention being across subjects
	mtx_Pcorr_thr_3D(:,:,i) = mtx_Pcorr_thr;
	mtx_Pcorr_thr_bin_3D(:,:,i) = mtx_Pcorr_thr_bin;
end


% ===================================================================
%            Jmod : calculate graph theory measures
% ===================================================================
for k = 1 : ts.Nsubjects

	% +++++++++++++++++++
	% node-level measures
	% +++++++++++++++++++
	betweenness_Fcorr_wei (k,:) = betweenness_wei (mtx_Fcorr_thr_3D(:,:,k));
	betweenness_Fcorr_bin (k,:) = betweenness_bin (mtx_Fcorr_thr_bin_3D(:,:,k));
	betweenness_Pcorr_wei (k,:) = betweenness_wei (mtx_Pcorr_thr_3D(:,:,k));
	betweenness_Pcorr_bin (k,:) = betweenness_bin (mtx_Pcorr_thr_bin_3D(:,:,k));

	clustering_coef_Fcorr_wei (k,:) = clustering_coef_wu (mtx_Fcorr_thr_3D(:,:,k));
	clustering_coef_Fcorr_bin (k,:) = clustering_coef_bu (mtx_Fcorr_thr_bin_3D(:,:,k));
	clustering_coef_Pcorr_wei (k,:) = clustering_coef_wu (mtx_Pcorr_thr_3D(:,:,k));
	clustering_coef_Pcorr_bin (k,:) = clustering_coef_bu (mtx_Pcorr_thr_bin_3D(:,:,k));

	modularity_Fcorr_wei (k,:) = modularity_und (mtx_Fcorr_thr_3D(:,:,k));
	modularity_Fcorr_bin (k,:) = modularity_und (mtx_Fcorr_thr_bin_3D(:,:,k));
	modularity_Pcorr_wei (k,:) = modularity_und (mtx_Pcorr_thr_3D(:,:,k));
	modularity_Pcorr_bin (k,:) = modularity_und (mtx_Pcorr_thr_bin_3D(:,:,k));

	degree_Fcorr_wei (k,:) = degrees_und (mtx_Fcorr_thr_3D(:,:,k));
	degree_Fcorr_bin (k,:) = degrees_und (mtx_Fcorr_thr_bin_3D(:,:,k));
	degree_Pcorr_wei (k,:) = degrees_und (mtx_Pcorr_thr_3D(:,:,k));
	degree_Pcorr_bin (k,:) = degrees_und (mtx_Pcorr_thr_bin_3D(:,:,k));

	loc_efficiency_Fcorr_wei(k,:) = efficiency_wei (mtx_Fcorr_thr_3D(:,:,k),2);
	loc_efficiency_Fcorr_bin(k,:) = efficiency_bin (mtx_Fcorr_thr_bin_3D(:,:,k),2);
	loc_efficiency_Pcorr_wei(k,:) = efficiency_wei (mtx_Pcorr_thr_3D(:,:,k),2);
	loc_efficiency_Pcorr_bin(k,:) = efficiency_bin (mtx_Pcorr_thr_bin_3D(:,:,k),2);


	% ++++++++++++++++++++++
	% subject-level measures
	% ++++++++++++++++++++++
	assortativity_Fcorr_wei (k,1) = assortativity_wei (mtx_Fcorr_thr_3D(:,:,k), 0);
	assortativity_Fcorr_bin (k,1) = assortativity_bin (mtx_Fcorr_thr_bin_3D(:,:,k), 0);
	assortativity_Pcorr_wei (k,1) = assortativity_wei (mtx_Pcorr_thr_3D(:,:,k), 0);
	assortativity_Pcorr_bin (k,1) = assortativity_bin (mtx_Pcorr_thr_bin_3D(:,:,k), 0);

	% ==> !!! J: why is efficiency from charpath different from efficiency_bin/efficiency_wei ??
	%
	% [charPathLength_Fcorr_wei(k,1), glb_efficiency_Fcorr_wei(k,1)] = charpath (distance_wei (mtx_Fcorr_thr_3D(:,:,k)));
	% [charPathLength_Fcorr_bin(k,1), glb_efficiency_Fcorr_bin(k,1)] = charpath (distance_bin (mtx_Fcorr_thr_bin_3D(:,:,k)));
	% [charPathLength_Pcorr_wei(k,1), glb_efficiency_Pcorr_wei(k,1)] = charpath (distance_wei (mtx_Pcorr_thr_3D(:,:,k)));
	% [charPathLength_Pcorr_bin(k,1), glb_efficiency_Pcorr_bin(k,1)] = charpath (distance_bin (mtx_Pcorr_thr_bin_3D(:,:,k)));
	charPathLength_Fcorr_wei(k,1) = charpath (distance_wei (mtx_Fcorr_thr_3D(:,:,k)));
	charPathLength_Fcorr_bin(k,1) = charpath (distance_bin (mtx_Fcorr_thr_bin_3D(:,:,k)));
	charPathLength_Pcorr_wei(k,1) = charpath (distance_wei (mtx_Pcorr_thr_3D(:,:,k)));
	charPathLength_Pcorr_bin(k,1) = charpath (distance_bin (mtx_Pcorr_thr_bin_3D(:,:,k)));

	
	glb_efficiency_Fcorr_wei(k,1) = efficiency_wei (mtx_Fcorr_thr_3D(:,:,k));
	glb_efficiency_Fcorr_bin(k,1) = efficiency_bin (mtx_Fcorr_thr_bin_3D(:,:,k));
	glb_efficiency_Pcorr_wei(k,1) = efficiency_wei (mtx_Pcorr_thr_3D(:,:,k));
	glb_efficiency_Pcorr_bin(k,1) = efficiency_bin (mtx_Pcorr_thr_bin_3D(:,:,k));
end


% write graph theory measures to text file
graphTheory_Table = table (assortativity_Fcorr_wei, ...
						   assortativity_Fcorr_bin, ...
						   assortativity_Pcorr_wei, ...
						   assortativity_Pcorr_bin, ...
						   charPathLength_Fcorr_wei, ...
						   charPathLength_Fcorr_bin, ...
						   charPathLength_Pcorr_wei, ...
						   charPathLength_Pcorr_bin, ...
						   glb_efficiency_Fcorr_wei, ...
						   glb_efficiency_Fcorr_bin, ...
						   glb_efficiency_Pcorr_wei, ...
						   glb_efficiency_Pcorr_bin, ...
						   betweenness_Fcorr_wei, ...
						   betweenness_Fcorr_bin, ...
						   betweenness_Pcorr_wei, ...
						   betweenness_Pcorr_bin, ...
						   clustering_coef_Fcorr_wei, ...
						   clustering_coef_Fcorr_bin, ...
						   clustering_coef_Pcorr_wei, ...
						   clustering_coef_Pcorr_bin, ...
						   modularity_Fcorr_wei, ...
						   modularity_Fcorr_bin, ...
						   modularity_Pcorr_wei, ...
						   modularity_Pcorr_bin, ...
						   degree_Fcorr_wei, ...
						   degree_Fcorr_bin, ...
						   degree_Pcorr_wei, ...
						   degree_Pcorr_bin, ...
						   loc_efficiency_Fcorr_wei, ...
						   loc_efficiency_Fcorr_bin, ...
						   loc_efficiency_Pcorr_wei, ...
						   loc_efficiency_Pcorr_bin);
writetable (graphTheory_Table, 'graphTheoryMeasures.csv');

% ===================================================================
%                  Group-average netmat summaries
% ===================================================================
% - Now you have computed the full and partial netmat for each individual
%   subject.
% - The next step is to perform a simple group-level analysis to look at
%   the mean netmat across all subjects.
% - The following command saves out both the simple average (Mnet), and
%   results of a simple one-group t-test across subjects as Z values (Znet).
%   (J : that is, testing mean > 0).
% -------------------------------------------------------------------
% - The second input of the following commands (1/0) decides whether or
%   not to display a summary figure.
[Znet_F, Mnet_F] = nets_groupmean (Fnetmats, 0);
[Znet_P, Mnet_P] = nets_groupmean (Pnetmats, 1);
% Figure output : - The left figure is the results from group t-test.
%                   Actually doing one-sample t-test at each edge and
%                   then transforming to Z stats.
%
%                 - The right figure is a consistency scatter plot
%                   showing how similar the results from each subject 
%                   are to the group, i.e. the more this looks like a 
%                   diagonal line, the more consistent the relevant
%                   netmat is across subjects. This figure shows each
%                   subject edge plotted against group mean (more
%                   diagonal = more consistent).
%
%                 - Here 'edge' means the full/partial correlation
%                   between pair of nodes.

Mnet_P (3, 27)
% This command is to view the mean partial correlation strength between
% node number 3 and node number 27, after performing r-to-Z transformation
% for each subject before averaging. The group-averaged strength of the
% partial correlation between the pair of nodes is shown here, which is
% also called the 'edge' between the two nodes. The number is higher
% than 1, because these are averaged z-transformed correlation
% coefficients.


% ======================================================================
% To look at how nodes cluster together to form larger resting state
% networks.
% ======================================================================
% - For this we run a clustering method that groups nodes together
%   based on their timeseries.
% - To view this network heirarchy, run:
nets_hierarchy (Znet_F, ...
				Znet_P, ...
				ts.DD, ...
				slc_sum);
% - Input : group-averaged netmat to drive clustering (Znet_F) shown below
%           the diagonal.
%
%           group-averaged netmat to show (doesn't drive clustering)
%           (Znet_P) shown above the diagonal.
%
%           list of good components (ts.DD) entered earlier.
%
%           directory containing png summary figures ('groupICA100.sum')
%           to create, run:
%
%              slices_summary groupICA100/melodic_IC \
%                             4 \
%                             $FSLDIR/data/standard/MNI152_T1_2mm \
%                             groupICA100.sum \
%                             -1
% ----------------------------------------------------------------------
% - Clustering tree groups similar nodes. Note colour-cut off is
%   arbitrary.
% - The plot is just for visulisation, NOT a statistical test.
% ----------------------------------------------------------------------
% [hier_order, linkages] = nets_hierarchy (netmatL, ...
%										   netmatH, ...
%                                          DD, ...
%                                          sumpics)
%
% [hier_order, linkages] = nets_hierarchy (netmatL, ...
%										   netmatH, ...
%                                          DD, ...
%                                          sumpics, ...
%                                          colour_threshold)
%
% netmatL : the netmat shown below the diagonal, and drives the hierarchical
%           clustering. It is typically the z-stat from the one-group
%           t-test across all subjects' netmats.
%
% netmatH : the netmat shown above the diagonal, for example partial
%           correlation. Just shown for comparison.
%
% DD : list of good nodes (needed to map the current set of nodes back
%      to originals), e.g., ts.DD.
%
% sumpics : name of directory containing summary pictures for each
%           component, without the .sum suffix.
%
% hier_order : index numbers of the good nodes, as reordered by the
%              heirarchical clustering.
%
% colour_threshold : default = 0.75. specifies at what level the dendrogram
%                    colouring stops.
% 


% ----------------------------------------------------------------------
% !!! You can see, for example, that the nodes group together in the dark
%     blue tree on the far left are part of a large-scale resting state
%     network called the default mode network.
% ----------------------------------------------------------------------
% J : This sentence is from the webpage. The order may not be always the
%     same across runs.
% ----------------------------------------------------------------------


% ======================================================================
%                Cross-subject comparison with netmats
% ======================================================================
% - This example tests whether the netmats differ significantly between
%   healthy controls and patients with a tumor.
%
% - This will be a univariate two-sample t-test.
%
% - !!! We will test each netmat edge separately for a group-difference,
%   and then we will estimate p-values for these tests, correcting for
%   the multiple comparisons across all edges.
%
% - !!! Analogy to high-level task-fMRI analyses : you can think of each
%   subject's netmat as being an N*N image of voxels, and the univariate
%   testing as modelling each voxel (in isolation from each other) across
%   subjects.
%
% - The following script calls randomise with 5000 permutations for each
%   contrast.
% ----------------------------------------------------------------------
% - input to t-test (Pnetmats).
%
% - EVs of group-level design ('design/paired_ttest.mat'). Use GLM GUI
%   to create this.
%
% - contrasts of group-level design ('design/paired_ttest.con'). Use GLM
%   GUI to create this.
%
% - create output figure? (1 means 'yes').
%
% - output : variable containing uncorrected p-values (p_uncorr).
%
% - output : variable containing p-values corrected for multiple
%            comparisons (p_corr).

[p_uncorr, p_corr] = nets_glm (Pnetmats, ...
							   [desmtx_con_path '/' desmtx_con_basename '.mat'], ...
							   [desmtx_con_path '/' desmtx_con_basename '.con'], ...
							   1, ...
							   5000);
[p_uncorr, p_corr] = nets_glm (Fnetmats, ...
							   [desmtx_con_path '/' desmtx_con_basename '.mat'], ...
							   [desmtx_con_path '/' desmtx_con_basename '.con'], ...
							   1, ...
							   5000);

% - in the plot output, below the diagonal is showing the (1 - corrected_p) of
%   all correlations.
%
% - in the plot output, above the diagonal is the same thing, but thresholded
%   at 0.95, i.e. corrected_p < 0.05.
% -----------------------------------------------------------------------
% J : For some reason, the script is not permutating for 5000 times. Probably
%     due to the fact that too few subjects are included - number of possible
%     permutations is limited.


% =======================================================================
%       Map the significant results to the corresponding nodes
% =======================================================================
% - The following command shows which nodes were linked to the significant
%   result.
% - The resulting plot only shows the MOST significant result.
% - Pictures are from groupICA100.sum.
nets_edgepics (ts, ...
			   [slc_sum '.sum'], ...
			   Znet_P, ...
			   reshape (p_corr, ...
			   			ts.Nnodes, ...
			   			ts.Nnodes), ...
			   1);


% =======================================================================
%                Boxplots to show the group difference
% =======================================================================
% - The following script shows how the partial correlation differs between
%   the patients and the controls at these two significant edges.
%
% - !!! Note that this command assumes that subjects are grouped together
%       according to groups, e.g. all group 1 subjects are listed before
%       group 2.

nets_boxplots (ts, ...
			   Pnetmats, ...
			   57, ...
			   33, ...
			   6);
% - The boxplots summarize the distributions of the correlation values
%   (connections strengths) in the two groups, for this one particular
%   node-pair (57, 33).
%   
%   A : healthy controls
%
%   B : tumor patients
%
% - The boxplot displays the difference in edge stength across the two
%   groups.
%
% - Y-axis : edge strength (Z transformed).
%
% - Interpretation : The group-averaged stength of the partial correlation
%                    was positive in healthy controls, and close to zero
%                    in patients. Therefore, the connection stength was
%.                   positive in healthy controls and not present in the
%.                   patients.
%
% - the '6' for the last argument is the number of subject for the first
%   group


% =======================================================================
%               Multivariate cross-subject analysis
% =======================================================================
% - multivariate cross-subject analysis = instead of considering each
%   netmat edge in isolation (like above), we will consider the whole
%   netmat in one analysis.
%
% - !!! For example, we can attempt to classify subjects into patients or
%   controls using machine learning methods, such as support vector machines
%   (SVM) or linear discriminant analysis (LDA). Such methods look at the
%   overall pattern of values in the netmat, and try to learn how the overall
%   pattern changes between the two groups.
%
% - The following command feeds the regularised partial correlation netmats
%   from both groups into LDA. It uses a method known as leave-one-out
%.  cross-validation to train and test a classifier, and reports in what
%.  percentage of tests it was successful at discriminating between patients
%.  and controls.
nets_lda (Pnetmats, ...
		  6, ...
		  2);
% - One 'downside' of such multivariate testing is that you can no longer make
%.  strong statistical claims about individual edges in the network - the whole
%.  pattern of edges has been used, so we do not know which individual edges
%.  are significantly different in the two groups.
% -------------------------------------------------------------------------
% J : the svm options are not working at the moment. need some configuration
%     for them to be used.














