Input/output module
===================

Converting DICOM to BIDS with dcm2bids
--------------------------------------
Note that the DCM2BIDS documentation has details on how to install and use dcm2bids. Here, I only recorded how I did it.

Install dcm2bids
++++++++++++++++
Full installation instructions can be found `here <https://unfmontreal.github.io/Dcm2Bids/3.0.1/get-started/install/>`_.

* Create a yml file with all prerequisites: ``nano environment.yml``
* Copy paste the following to *environment.yml*.

..  code-block::

	name: dcm2bids
	channels:
	  - conda-forge
	dependencies:
	  - python>=3.7
	  - dcm2niix
	  - dcm2bids

* Create a conda environment with *environment.yml*: ``conda env create --file environment.yml``
* Activate environment: ``conda activate dcm2bids``
* Verify that dcm2bids works: ``dcm2bids --help``

Tutorial go-through
+++++++++++++++++++
Tutorial can be found `here <https://unfmontreal.github.io/Dcm2Bids/3.0.1/tutorial/>`_.

..  code-block::

	conda activate dcm2bids

	mkdir dcm2bids-tutorial
	cd dcm2bids-tutorial

	dcm2bids_scaffold  # Help structure and organise data in an effient way
	                   # by creating automatically a basic directory structure
	                   # and the core files according to BIDS specification.

	git clone https://github.com/neurolabusc/dcm_qa_nih/ sourcedata/dcm_qa_nih   # download/clone example DICOM data to sourcedata folder

	dcm2bids_helper -d sourcedata/dcm_qa_nih/In

Running dcm2bids in VCI/MAS2
++++++++++++++++++++++++++++

..  code-block::

	conda activate dcm2bids