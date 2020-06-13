
FSLnets_path='/data_pub/Software/FSL/fsl-5.0.11/FSLNets/FSLNets';
libsvm_path='/data_pub/Software/FSL/fsl-5.0.11/FSLNets/LIBSVM/libsvm-3.23/matlab';

% dual-regression output folder
dualReg_folder = '/data2/jiyang/grp_cmp_lt80_over90_yesWMCSFregts/groupICA/grp_cmp_adj4sexEdu_dualReg_rand_results_metaICA';
% TR
tr = 2;
% slice summary folder (without .sum suffix)
slc_sum = '/data2/jiyang/grp_cmp_lt80_over90_yesWMCSFregts/groupICA/metaICA/50indICAs_FriMar22181340AEDT2019/metaICA/d30/melodic_IC_noiseRemoved';
% path to the folder containing the design matrix and contrasts
desmtx_con_path = '/data2/jiyang/grp_cmp_lt80_over90_yesWMCSFregts/groupICA/des_mtx';
% design matrix and contrast base name for group comparison
desmtx_con_basename = 'grp_cmp_adj4sexEdu';

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
ts_spectra = nets_spectra (ts);

% ============================================================
%                          Cleanup
% ============================================================
% - components' (nodes') timeseries that correspond to artefacts
%   rather than plausible nodes can be removed.
% - Similar to subject-level cleanup, you need to decide this
%   by looking at the spatial maps, timecourses, and frequency
%   spectra.
% - DD specifies 'good' components.
% -------------------------------------------------------------
ts.DD = [1:3,5,6:9,11:13,17:23,25:38,40,42,43,47:50,52,53,55:59,61,...
62,64:66,70:74,77,80,81,86,87,93,97];
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
% - regularisation parameter (0.1)
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










% ===================================================================
%                  Group-average netmat summaries
% ===================================================================
% - Now you have computed the full and partial netmat for each individual
%   subject.
% - The next step is to perform a simple group-level analysis to look at
%   the mean netmat across all subjects.
% - The following command saves out both the simple average (Mnet), and
%   results of a simple one-group t-test across subjects as Z values (Znet).
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














