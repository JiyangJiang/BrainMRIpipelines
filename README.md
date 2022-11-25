# BrainMRIpipelines (BMP) - pipelines for neuroimaging data processing

BrainMRIpipelines contains pipelines neuroimaging data processing. It includes pipelines for converting DICOM to NIFTI data, and processing structural, diffusion, and functional MRI data. Although the scripts are developed to run on computational resources available at Centre for Healthy Brain Ageing (CHeBA), University of New South Wales, they are written with generalisation in mind. Most of them can be applied to different datasets with different computational resources (multi-core workstations, PBS-based HPC, etc.).

**NOTE CURRENT DEVELOPMENT MAINLY ON MULTI-CORE WORKSTATIONS**


## Third-party software installation

BrainMRIpipelines requires the following third party software:

- [Dcm2Bids](https://unfmontreal.github.io/Dcm2Bids/)
- [BIDS-Validator (docker/singularity)](https://github.com/bids-standard/bids-validator)
- [MRIQC (docker/singularity)](https://mriqc.readthedocs.io/en/latest/)


## Workflow for converting DICOM to BIDS

The workflow for converting DICOM data to BIDS format will run <code>Dcm2Bids</code> and <code>BIDS Validator</code>.

- *Step 1 : converting DICOM to BIDS* Call <code>/path/to/BrainMRIpipelines/BIDS/bmp_dcm2bids.sh</code>. Examples of configuration files for dcm2bids are included in <code>/path/to/BrainMRIpipelines/BIDS/config_files</code>.


## Workflow for structural MRI

sMRI workflow includes <code>MRIQC</code>
