#!/bin/bash

dce_nii=./sub-pilotPS_ce-gd_T1w.nii
logfile=./logfile

echo -n "[$(date)] : $(basename $0) : mcflirt to correct for motion ... "
mcflirt -in $dce_nii -stages 4 -stats -mats -plots -report >> $logfile
echo "DONE!"