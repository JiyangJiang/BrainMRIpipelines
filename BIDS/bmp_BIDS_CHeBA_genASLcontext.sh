#!/bin/bash

BIDS_dir=$1
subject_ID=$2

cat << EOF > $BIDS_dir/sub-${subject_ID}/perf/sub-${subject_ID}_dir-PA_aslcontext.tsv
volume_type
m0scan
label
control
label
control
label
control
label
control
label
control
label
control
label
control
label
control
label
control
label
control
label
control
label
control
label
control
label
control
label
control
label
control
EOF

