Software installation
---------------------
Our first task in HCP-Aging data is to process ASL data. The `ASL pipeline <https://github.com/physimals/hcp-asl>`_ requires prerequisites of FSL (version >= 6.0.5.1), HCP workbench (version >= 1.5.0), HCP pipelines, and FreeSurfer (Note that version 6.0 and 5.3.0-HCP are compatible in `HCP pipeline prerequisites <https://github.com/Washington-University/HCPpipelines/wiki/Installation-and-Usage-Instructions#prerequisites>`_). The installation of FSL, HCP workbench, and FreeSurfer are relatively straightforward.

The installation of `HCP pipeline requires a few prerequisites <https://github.com/Washington-University/HCPpipelines/wiki/Installation-and-Usage-Instructions#prerequisites>`_. In these prerequisites, the installation of gradunwarp can follow `this page <https://github.com/Washington-University/gradunwarp>`_. Note that *openblas* may need to be available. On Katana, this can be done by ``module load openblass/0.3.21``. The installation of FSL FIX can follow `this webpage <https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIX/UserGuide>`_. In particular, R packages required by FIX can be installed by following the subsection below.

R packages for FSL FIX
++++++++++++++++++++++
Followed instruction in the end of `this webpage <https://github.com/Washington-University/HCPpipelines/blob/master/ICAFIX/README.md>`_. It took me a full day to get this work!!!

..  code-block::

	module load r/4.2.2
	export R_LIBS=/srv/scratch/cheba/Imaging/software/R_libs

	# Temporarily rename FSL, otherwise it will interfere with installation
	mv /srv/scratch/cheba/NiL/Software/fsl/6.0.6.5 /srv/scratch/cheba/NiL/Software/fsl/6.0.6.5_bak

	R
	install.packages('devtools', dependencies=TRUE)
	require ('devtools')
	quit()

	PACKAGES="lattice_0.20-38 Matrix_1.2-15 survival_2.43-3 MASS_7.3-51.1 class_7.3-14 codetools_0.2-16 KernSmooth_2.23-15 mvtnorm_1.0-8 modeltools_0.2-22 zoo_1.8-4 sandwich_2.5-0 strucchange_1.5-1 TH.data_1.0-9 multcomp_1.4-8 coin_1.2-2 bitops_1.0-6 gtools_3.8.1 gdata_2.18.0 caTools_1.17.1.1 gplots_3.0.1 kernlab_0.9-24 ROCR_1.0-7 party_1.0-25 e1071_1.6-7 randomForest_4.6-12"

	MIRROR="http://cloud.r-project.org"

	for package in $PACKAGES
	do
	    wget "$MIRROR"/src/contrib/Archive/$(echo "$package" | cut -f1 -d_)/"$package".tar.gz || \
	        wget "$MIRROR"/src/contrib/"$package".tar.gz
	    R CMD INSTALL "$package".tar.gz
	done

An alternative approach is to follow the instructions in the README file in the downloaded fix.tar.gz. I haven't tried this myself.

Setting environment variables
-----------------------------

..  code-block::

	# HCP workbench
	export PATH=$PATH:/srv/scratch/cheba/Imaging/software/workbench/bin_rh_linux

	# HCP version of gredunwarp
	conda activate gradunwarp
	export PATH=$PATH:/srv/scratch/cheba/Imaging/software/gradunwarp-1.2.1/build/scripts.linux-x86_64-3.7

	# MSM_HOCR
	module load openblas/0.3.21
	export PATH=$PATH:/srv/scratch/cheba/Imaging/software

	# HCP pipelines
	export HCPPIPEDIR=/srv/scratch/cheba/Imaging/software/HCPpipelines-4.7.0

	# R for FSL FIX
	module load r/4.2.2 matlab/R2019a
	export R_LIBS=/srv/scratch/cheba/Imaging/software/R_libs
	export FSL_FIX_R_CMD=$(which R)

	# configure FSL FIX
	export FSL_FIX_MATLAB_MODE=1
	export FSL_FIX_WBC=/srv/scratch/cheba/Imaging/software/workbench/bin_rh_linux64/wb_command

	cd /srv/scratch/cheba/Imaging/software
	git clone https://github.com/Washington-University/cifti-matlab.git # clone cifti-matlab library from github.
	                                                                    # I am not sure if this will be the same as
	                                                                    # /srv/scratch/cheba/Imaging/software/HCPpipelines-4.7.0/global/matlab/cifti-matlab
	                                                                    # But to be safe, and also recommended in this link 
	                                                                    # (https://wiki.humanconnectome.org/display/PublicData/HCP+Users+FAQ#HCPUsersFAQ-2.HowdoyougetCIFTIfilesintoMATLAB?),
	                                                                    # this library is cloned from GitHub.
	export FSL_FIX_CIFTIRW=/srv/scratch/cheba/Imaging/software/cifti-matlab

	cd /srv/scratch/cheba/Imaging/software/fix-v1.06.15
	./setting.sh