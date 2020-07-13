#!/bin/bash

usage(){

cat << EOF

$(basename $0) : Submit jobs to NCI Gadi and CHeBA NiL.

USAGE :	

COMPULSORY :

  -n,--nil                    Submit to CHeBA NiL cluster.

  -g, --gadi                  Submit to NCI Gadi cluster.

  -t,--txt    <job_textfile>  Text file with each job in a separate line. If each
                              job contains multiple lines of commands, create a
                              separate text file for each job, and pass a list
                              of these text files to -l or --list.

  -l,--list       <job_list>  A list containing text files. Each text file contains 
                              a series of commands. If only one line of command
                              is run for each data/scan, use -t or --txt.


OPTIONAL :

  -q,--queue         <queue>  If submitting to CHeBA NiL, which queue to submit 
                              the jobs to. Default is all.q on NiL, and normal
                              on Gadi.

  -w,--wait         <job_id>  Wait <job_id> to finish before submit the job.
                              (YET TO IMPLEMENT)

  -ns,--noSubmit              Only prepare job text files, not submitting to
                              scheduler.

  -c,--cores   <n_cpu_cores>  Number of CPU cores. Default is 2.

  -m,--memory     <n_memory>  Number of memory in GB. Only specify the number (e.g.,
                              8 for 8GB). Default is 8GB.

  -wt,--walltime <wall_time>  Wall time for NCI Gadi jobs (e.g. 48:00:00 for 48 hours).
                              Default is 48 hrs.

  -h, --help                  Display this message.

EOF

}


# set defaults
nil_flag=0
gadi_flag=0
txt_flag=0
list_flag=0
hjob_flag=0
nsub_flag=0
walltime=48:00:00
n_cpus=2
n_mems=8

for arg in $@
do
	case "$arg" in

		-n|--nil)
			nil_flag=1
			shift
			;;

		-g|--gadi)
			gadi_flag=1
			shift
			;;

		-t|--txt)
			txt=$2
			txt_flag=1
			oe_dir=$(dirname $(readlink -f $txt))/oe
			jobs_dir=$(dirname $(readlink -f $txt))/jobs
			shift 2
			;;

		-l|--list)
			list=$2
			list_flag=1
			oe_dir=$(dirname $(readlink -f $list))/oe
			jobs_dir=$(dirname $(readlink -f $list))/jobs
			shift 2
			;;

		-q|--queue)
			queue=$2
			shift 2
			;;

		-w|--wait)
			hjob_flag=1
			wait_jid=$2
			shift 2
			;;

		-ns|--noSubmit)
			nsub_flag=1
			shift
			;;

		-c|--cores)
			n_cpus=$2
			shift 2
			;;

		-m|--memory)
			n_mems=$2
			shift 2
			;;

		-wt|--walltime)
			walltime=$2
			shift 2
			;;

		-h|--help)
			usage
			exit 0
			;;

		-*)
			usage
			exit 1
			;;

	esac
done

[ ! -d "$oe_dir" ]   && mkdir -p $oe_dir
[ ! -d "$jobs_dir" ] && mkdir -p $jobs_dir

# stupid inputs
[ "$nil_flag" -eq 1 ] && \
[ "$gadi_flag" -eq 1 ] && \
echo Cannot submit to NiL and Gadi simultaneously. && \
exit 1

[ "$nil_flag" -eq 0 ] && \
[ "$gadi_flag" -eq 0 ] && \
echo Either NiL or Gadi needs to be specified. && \
exit 1

[ "$txt_flag" -eq 1 ] && \
[ "$list_flag" -eq 1 ] && \
echo Cannot specify job textfile and job list simultaneously. && \
exit 1

[ "$txt_flag" -eq 0 ] && \
[ "$list_flag" -eq 0 ] && \
echo Either txt or list needs to be specified. && \
exit 1

# default queues
[ -z ${queue+x} ] && [ "$nil_flag" -eq 1 ] && queue=all.q
[ -z ${queue+x} ] && [ "$gadi_flag" -eq 1 ] && queue=normal


# NiL, single txt
# =====================================================
if [ "$nil_flag" -eq 1 ] && [ "$txt_flag" -eq 1 ]; then
idx=0
while read cmd;do
idx=$((idx+1))
cat << EOF > ${jobs_dir}/job.${idx}
#!/bin/bash

#$ -N job.${idx}
#$ -V
#$ -cwd
#$ -pe smp ${n_cpus}
#$ -q $queue
#$ -l h_vmem=${n_mems}G
#$ -o ${oe_dir}/job.${idx}.out
#$ -e ${oe_dir}/job.${idx}.err

${cmd}

EOF
if [ "${nsub_flag}" -eq 0 ]; then
	echo $(qsub ${jobs_dir}/job.${idx}) | awk '{ print $3 }'
fi
done < ${txt}
fi

# NiL, list
# =====================================================
if [ "$nil_flag" -eq 1 ] && [ "$list_flag" -eq 1 ]; then
idx=0
while read cmd;do
idx=$((idx+1))
cat << EOF > ${jobs_dir}/job.${idx}
#!/bin/bash

#$ -N job.${idx}
#$ -V
#$ -cwd
#$ -pe smp ${n_cpus}
#$ -q $queue
#$ -l h_vmem=${n_mems}G
#$ -o ${oe_dir}/job.${idx}.out
#$ -e ${oe_dir}/job.${idx}.err

$(cat $cmd)

EOF
if [ "${nsub_flag}" -eq 0 ]; then
	echo $(qsub ${jobs_dir}/job.${idx}) | awk '{ print $3 }'
fi
done < ${list}
fi


# Gadi, single txt
# =====================================================
if [ "$gadi_flag" -eq 1 ] && [ "$txt_flag" -eq 1 ]; then
idx=0
while read cmd;do
idx=$((idx+1))
cat << EOF > ${jobs_dir}/job.${idx}
#!/bin/bash
#PBS -P ey6
#PBS -q ${queue}
#PBS -l ncpus=${n_cpus}
#PBS -l mem=${n_mems}GB
#PBS -l walltime=${walltime}
#PBS -l jobfs=4GB
#PBS -l wd
#PBS -V
#PBS -l storage=gdata/ey6
#PBS -l software=matlab_unsw
#PBS -e ${oe_dir}/job.${idx}.out
#PBS -o ${oe_dir}/job.${idx}.err

${cmd}

EOF
if [ "${nsub_flag}" -eq 0 ]; then
	qsub ${jobs_dir}/job.${idx}
fi
done < ${txt}
fi

# Gadi, list
# =====================================================
if [ "$gadi_flag" -eq 1 ] && [ "$list_flag" -eq 1 ]; then
idx=0
while read cmd;do
idx=$((idx+1))
cat << EOF > ${jobs_dir}/job.${idx}
#!/bin/bash
#PBS -P ey6
#PBS -q ${queue}
#PBS -l ncpus=${n_cpus}
#PBS -l mem=${n_mems}GB
#PBS -l walltime=${walltime}
#PBS -l jobfs=4GB
#PBS -l wd
#PBS -V
#PBS -l storage=gdata/ey6
#PBS -l software=matlab_unsw
#PBS -e ${oe_dir}/job.${idx}.out
#PBS -o ${oe_dir}/job.${idx}.err

$(cat $cmd)

EOF
if [ "${nsub_flag}" -eq 0 ]; then
	qsub ${jobs_dir}/job.${idx}
fi
done < ${list}
fi
