#!/bin/bash


Sfolder=$1
outputTXT=$2

cat << EOF > ${outputTXT}
#!/bin/bash
#$ -V
#$ -cwd
#$ -N sub$(basename ${Sfolder})_Xbrain
#$ -pe smp 2
#$ -q short.q
#$ -l h_vmem=16G
#$ -o $(dirname ${Sfolder})/SGE_commands/oe/sub$(basename ${Sfolder})_Xbrain.out
#$ -e $(dirname ${Sfolder})/SGE_commands/oe/sub$(basename ${Sfolder})_Xbrain.err

module load matlab/R2018a fsl/5.0.11
$(dirname $(which $0))/bmp_fmri_ini_Xbrain_SGE_functions.sh ${Sfolder}
EOF

# submit jobs to SGE cluster
qsub ${outputTXT}



