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