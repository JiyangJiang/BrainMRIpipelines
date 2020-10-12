#!/bin/bash

# output from AFNI's 3dNetCorr is formatted as columns as timepoints
# and rows as parcellations. FSLNets' input is the opposite. This
# script transposes between rows and columns

awk '
{
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}' $1