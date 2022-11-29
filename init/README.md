# Initialisation

This module includes scripts to initialise BrainMRIpipelines (<code>bmp_init.sh</code>) and install third-party software (<code>bmp_install.sh</code>).

## Tips

- If in your <code>~/.bashrc</code> you run scripts to set up FSL and FreeSurfer environment after initialising conda, you may end up using conda within FSL installation. Therefore, running conda to install the third-party software packages will end up installing to <code>/path/to/fsl/envs</code>. This can be resolved by moving FSL and FreeSurfer initialisation codes before conda initialisation in <code>~/.bashrc</code>. You can check which conda you are using by typing <code>which conda</code>. If you accidentally installed packages to <code>/path/to/fsl/envs</code>, they can be removed by typing <code>conda env remove -p /path/to/fsl/envs/package_name</code>. 