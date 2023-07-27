BrainMRIpipelines (BMP) - pipelines for neuroimaging data processing
========

.. image:: http://unmaintained.tech/badge.svg
  :target: http://unmaintained.tech
  :alt: No Maintenance Intended

BrainMRIpipelines contains pipelines for neuroimaging data processing. Although the scripts are developed to process neuroimaging data available at Centre for Healthy Brain Ageing (CHeBA), University of New South Wales, some of them can be generalised to other datsets.


MRI modalities
--------

- Be awesome
- Make things faster

Installation
------------

BMP only works on Unix-based system (Linux, macOS, WSL on Windows). The following parameters need to be included in *~/.bashrc* (Linux) or *~/.bash_profile* (macOS):

..  code-block:: none
    :linenos:

    export BMP_PATH=/path/to/BrainMRIpipelines
    export BMP_SPM_PATH=/path/to/SPM12
    export BMP_3RD_PATH=/path/to/install/third-party/software
    export BMP_TMP_PATH=/path/to/my/temp
    source ${BMP_PATH}/ENGINE/bmp_init.sh &> /dev/null


where <code>/path/to/BrainMRIpipelines</code> and <code>/path/to/install/third-party/software</code> need to be replaced with the path to BrainMRIpipelines and the path to install third-party software, respectively.

Contribute
----------

- Issue Tracker: github.com/$project/$project/issues
- Source Code: github.com/$project/$project

Support
-------

If you are having issues, please let us know.
We have a mailing list located at: project@google-groups.com

License
-------

The project is licensed under the BSD license.