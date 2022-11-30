# BrainMRIpipelines (BMP) - pipelines for neuroimaging data processing

BrainMRIpipelines contains pipelines neuroimaging data processing. It includes pipelines for converting DICOM to NIFTI data, and processing structural, diffusion, and functional MRI data. Although the scripts are developed to run on computational resources available at Centre for Healthy Brain Ageing (CHeBA), University of New South Wales, they are written with generalisation in mind. Most of them can be applied to different datasets with different computational resources (multi-core workstations, PBS-based HPC, etc.).


## Global environment setup

BMP only works on Unix-based system (Linux, macOS, WSL on Windows). The following parameters need to be included in <code>~/.bashrc</code>:


<code>export BMP_PATH=/path/to/BrainMRIpipelines</code>

<code>export BMP_3RD_PATH=/path/to/install/third-party/software</code>

<code>export BMP_TMP_PATH=/path/to/my/temp</code>

<code>source ${BMP_PATH}/init/bmp_init.sh &> /dev/null</code>


where <code>/path/to/BrainMRIpipelines</code> and <code>/path/to/install/third-party/software</code> need to be replaced with the path to BrainMRIpipelines and the path to install third-party software, respectively.

## Workflows

Please go to specific folders for details:

- [Initialisation for BMP](https://github.com/JiyangJiang/BrainMRIpipelines/tree/master/init)
- [Converting to BIDS](https://github.com/JiyangJiang/BrainMRIpipelines/tree/master/BIDS)
- [Structural MRI workflow](https://github.com/JiyangJiang/BrainMRIpipelines/tree/master/sMRI)
- [ASL workflow](https://github.com/JiyangJiang/BrainMRIpipelines/tree/master/ASL)