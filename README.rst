BrainMRIpipelines (BMP) - pipelines for neuroimaging data processing
========

BrainMRIpipelines contains pipelines for neuroimaging data processing. Although the scripts are developed to process neuroimaging data available at Centre for Healthy Brain Ageing (CHeBA), University of New South Wales, some of them can be generalised to other datsets.


Document
------------




Installation
------------

BMP only works on Unix-based system (Linux, macOS, WSL on Windows). The following parameters need to be included in ``~/.bashrc`` (Linux) or ``~/.bash_profile`` (macOS):

..  code-block::

    export BMP_PATH=/path/to/BrainMRIpipelines
    export BMP_SPM_PATH=/path/to/SPM12
    export BMP_3RD_PATH=/path/to/install/third-party/software
    export BMP_TMP_PATH=/path/to/my/temp
    source ${BMP_PATH}/ENGINE/bmp_init.sh &> /dev/null


where ``/path/to/BrainMRIpipelines`` and ``/path/to/install/third-party/software`` need to be replaced with the path to BrainMRIpipelines and the path to install third-party software, respectively.

For MATLAB, ``Set Path - Add with Subfolders ... - Select BrainMRIpipelines folder``.


Current available modules
--------

- Converting DICOM to BIDS
- Arterial Spin Labelling (ASL)


Author
----------

| Jiyang Jiang, PhD
| Centre for Healthy Brain Ageing
| University of New South Wales
| Australia

