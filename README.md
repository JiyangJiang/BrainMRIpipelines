# Jpipe - pipelines for neuroimaging data processing

Jpipe contains pipelines neuroimaging data processing. It includes pipelines for converting DICOM to NIFTI data, and processing structural, diffusion, and functional MRI data. Although the scripts are developed to run on computational resources available at Centre for Healthy Brain Ageing (CHeBA), University of New South Wales, they are written with generalisation in mind. Most of them can be applied to different datasets with different computational resources (multi-core workstations, PBS-based HPC, etc.).

**NOTE CURRENT DEVELOPMENT MAINLY ON MULTI-CORE WORKSTATIONS**


## 3rd-party software installation

Jpipe requires the following 3rd party software:

- [Dcm2Bids](https://unfmontreal.github.io/Dcm2Bids/)
- [BIDS-Validator (docker/singularity)](https://github.com/bids-standard/bids-validator)
- [MRIQC (docker/singularity)](https://mriqc.readthedocs.io/en/latest/)


## Workflow for converting DICOM to BIDS

The workflow for converting DICOM data to BIDS format will run <code>dcm2bids</code> and <code>bids validator</code>. Examples of configuration files for dcm2bids are included in <code>/path/to/Jpipe/BIDS/config_files</code>.


### workflow_dicom2bids step 1


## Workflow for structural MRI

sMRI workflow includes <code>MRIQC</code>