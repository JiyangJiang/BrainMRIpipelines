#!/bin/bash

future_dir=$(dirname$(dirname $0))

# grant permision to *.sh
chmod u+x $(find ${future_dir} -type f -name "*.sh")

# add freesurfer scripts to PATH
export PATH=${future_dir}/freesurfer/scripts:$PATH