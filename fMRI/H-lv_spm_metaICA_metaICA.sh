#!/bin/bash

# DESCRIPTION
# ===============================================================================
#
# This script does temporal ICA with melodic_IC.nii.gz generated from individual
# ICA.
#
# Note that this code only works in SGE. needs modification to work locally.
#
#
# USAGE
# ===============================================================================
#
# $1 = path to cohort folder.
#
# $2 = number of individual ICAs conducted.
#
# $3 = dimensionality of each individual ICA that has been conducted.
#
# $4 = dimentionality of meta ICA that will be conducted.
#
# $5 = TR in seconds.
#
# $6 = 'yesQsub' or 'noQsub'
#
# ===============================================================================
#
#
#


cohortFolder=$1
N_indICA=$2
N_dim_indICA=$3
N_dim_metaICA=$4
tr=$5
N_grps=$6
qsub_flag=$7



# meta ICA
for k in $(seq 1 ${N_grps})
do

	[ -f "${cohortFolder}/SGE_commands/spm.metaICA.grp${k}.sge" ] && \
		rm -f ${cohortFolder}/SGE_commands/spm.metaICA.grp${k}.sge

	cat << EOF > ${cohortFolder}/SGE_commands/spm.metaICA.grp${k}.sge
#!/bin/bash

#$ -N spm_metaICA_grp${k}
#$ -V
#$ -cwd
#$ -pe smp 4
#$ -q bigmem.q
#$ -l h_vmem=32G
#$ -o ${cohortFolder}/SGE_commands/oe/spm.metaICA.grp${k}.out
#$ -e ${cohortFolder}/SGE_commands/oe/spm.metaICA.grp${k}.err

module load fsl/5.0.11

for i in \`ls -d ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_*/grp${k}\`
do
	mkdir -p \${i}/metaICA

	[ -f "\${i}/metaICA/indICA_d${N_dim_indICA}_melodicIC.list" ] && \
		rm -f \${i}/metaICA/indICA_d${N_dim_indICA}_melodicIC.list

	for j in \`ls -d \${i}/ICA_*\`
	do
		ls \${j}/d${N_dim_indICA}/melodic_IC.nii.gz \
			>> \${i}/metaICA/indICA_d${N_dim_indICA}_melodicIC.list
	done

	
	# meta ICA with individual IC maps
	case ${N_dim_metaICA} in

		auto)
			
			melodic -i \${i}/metaICA/indICA_d${N_dim_indICA}_melodicIC.list \
					-o \${i}/metaICA/d${N_dim_metaICA} \
					--tr=${tr} \
					--nobet \
					--bgthreshold=1 \
					-a concat \
					--bgimage=${cohortFolder}/spm/grp${k}/grp${k}_brain \
					-m ${cohortFolder}/spm/grp${k}/grp${k}_brain_mask \
					--report \
					--mmthresh=0.5 \
					--Oall
			;;
		*)
			melodic -i \${i}/metaICA/indICA_d${N_dim_indICA}_melodicIC.list \
					-o \${i}/metaICA/d${N_dim_metaICA} \
					--tr=${tr} \
					--nobet \
					--bgthreshold=1 \
					-a concat \
					--bgimage=${cohortFolder}/spm/grp${k}/grp${k}_brain \
					-m ${cohortFolder}/spm/grp${k}/grp${k}_brain_mask \
					--report \
					--mmthresh=0.5 \
					--Oall \
					-d ${N_dim_metaICA}
			;;
	esac
done
EOF
done

# submit jobs
if [ "${qsub_flag}" = "yesQsub" ]; then
	for g in $(seq 1 ${N_grps})
	do
		metaICA_jid=`echo $(qsub ${cohortFolder}/SGE_commands/spm.metaICA.grp${g}.sge) | awk '{print $3}'`
	done
fi



