#!/bin/bash

IniXbrain_SGE(){
	Sfolder=$1
	anat_filename=$2
	SPM12path=$4
	overwrite_F=$5
	outputTXT=$6

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
$(dirname $(which $0))/bmp_fmri_ini_Xbrain_SGE_functions.sh ${Sfolder} ${anat_filename} ${SPM12path} ${overwrite_F}
EOF
	# submit jobs to SGE cluster
	qsub ${outputTXT}
}

IniXbrain_SGE $1 $2 $3 $4 $5


