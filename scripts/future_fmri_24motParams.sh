#!/bin/bash

#
# DESCRIPTION
# ==========================================================================================
#
# Takes the 6-column motion parameter text file and produces a 24-column text file. The 
# first 6 are copies of the input (6 rigid body motion parameters), the next 6 columns are 
# the squares of these parameters, the next 6 columns are the temporal derivatives of the 
# motion parameters, and the final 6 columns are the squares of of the temporal derivaties. 
# The result is then suitable to be added as “multiple regressors” in a first level SPM fMRI 
# analysis.
#
# This script is downloaded from
#
#     https://warwick.ac.uk/fac/sci/statistics/staff/academic-research/nichols/scripts/spm
#
#
# USAGE
# ==========================================================================================
#
# $1 = path to mcflirt output *.par
#
# $2 = output path and filename. ".dat" suffix will be added automatically.
#
#
# ==========================================================================================

if [ $# -lt 2 ] ; then
    cat << EOF
Usage: $0 regparam.dat diffregparam.dat

Creates file with 24 columns; the first 6 are the motion
parameters, the next 6 are the square of the motion
parameters, the next 6 are the temporal difference of motion parameters, 
and the next 6 are the square of the differenced values.  This is useful for
accounting for 'spin history' effects, and variation not 
otherwise accounted for by motion correction.

EOF
    exit 1
fi

f=`echo $2 | sed 's/\....$//'`

cat <<EOF > /tmp/$$-mp-diffpow
{
  if (NR==1) {
    mp1=\$1;mp2=\$2;mp3=\$3;mp4=\$4;mp5=\$5;mp6=\$6;
  }
  printf("  %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e    %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e    %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e  %+0.7e\n",
         \$1,\$2,\$3,\$4,\$5,\$6,
         \$1^2,\$2^2,\$3^2,\$4^2,\$5^2,\$6^2,
         \$1-mp1,\$2-mp2,\$3-mp3,\$4-mp4,\$5-mp5,\$6-mp6,
         (\$1-mp1)^2,(\$2-mp2)^2,(\$3-mp3)^2,(\$4-mp4)^2,(\$5-mp5)^2,(\$6-mp6)^2);
  mp1=\$1;mp2=\$2;mp3=\$3;mp4=\$4;mp5=\$5;mp6=\$6;
}
EOF
awk -f /tmp/$$-mp-diffpow "$1" > ${f}.dat

/bin/rm /tmp/$$-mp-diffpow