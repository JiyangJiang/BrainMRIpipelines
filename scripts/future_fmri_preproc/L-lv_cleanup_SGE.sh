#!/bin/bash

outputTXT=$1

cleanup_mode=$2
Sfolder=$3
epi_filename=$4
Hpass_thr=$5

case ${cleanup_mode} in

	fix)
		fixdir=$6
		Tdata=$7
		fix_thr=$8
		;;

	aroma)
		ICA_AROMA_path=$6
		;;

esac


curr_dir=$(dirname $(which $0))

cat << EOF > ${outputTXT}
#!/bin/bash

#$ -N sub$(basename ${Sfolder})_cleanup
#$ -V
#$ -cwd
#$ -pe smp 2
#$ -q standard.q
#$ -l h_vmem=16G
#$ -o $(dirname ${Sfolder})/SGE_commands/oe/$(basename ${Sfolder})_cleanup.out
#$ -e $(dirname ${Sfolder})/SGE_commands/oe/$(basename ${Sfolder})_cleanup.err

module load python/2.7.15
module load fsl/5.0.11

module load matlab/R2018a
module load R/3.5.1


case ${cleanup_mode} in

	fix)

		${curr_dir}/L-lv_cleanup_SGE_functions.sh ${cleanup_mode} ${Sfolder} $(basename ${Sfolder})_func ${Hpass_thr} ${fixdir} ${Tdata} ${fix_thr}
		
		;;

	aroma)
		
		${curr_dir}/L-lv_cleanup_SGE_functions.sh ${cleanup_mode} ${Sfolder} $(basename ${Sfolder})_func ${Hpass_thr} ${ICA_AROMA_path}
		
		;;

esac

EOF


# submit jobs to SGE cluster
# qsub ${outputTXT}


