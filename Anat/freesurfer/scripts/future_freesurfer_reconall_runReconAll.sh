#!/bin/bash

usage(){

cat << EOF

$(basename $0) : run freesurfer recon-all.

USAGE : $(basename $0) [OPTIONS]

    -s, --subjects_dir      <subjects_dir>          Subjects directory where all recon-all results will be stored 
                                                    (defaults is SUBJECTS_DIR).


EOF

}