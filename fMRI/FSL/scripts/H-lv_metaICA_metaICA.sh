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
# $5 = isotropic resampling scale
#
# $6 = TR in seconds.
#
# $7 = 'yesQsub' or 'noQsub'
#
# ===============================================================================
#
#
#


cohortFolder=$1
N_indICA=$2
N_dim_indICA=$3
N_dim_metaICA=$4
resample_scale=$5
tr=$6
qsub_flag=$7

# if $tr = empty, extract TR from func
# if [ -z ${tr+x} ]; then
# 	eg_func=`ls $(head -n 1 ${cohortFolder}/studyFolder.list)/*_func.nii*`
# 	tr=`fslval ${eg_func} pixdim4`
# fi



# meta ICA
	cat << EOF > ${cohortFolder}/SGE_commands/metaICA.sge
#!/bin/bash

#$ -N metaICA
#$ -V
#$ -cwd
#$ -pe smp 4
#$ -q long.q
#$ -l h_vmem=32G
#$ -o ${cohortFolder}/SGE_commands/oe/metaICA.out
#$ -e ${cohortFolder}/SGE_commands/oe/metaICA.err

module load fsl/5.0.11

for i in \`ls -d ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_*\`
do
	mkdir -p \${i}/metaICA/melodicIC_from_indICA

	# copy melodic IC maps from each individuals ICA
	for j in \`ls -d \${i}/ICA_*\`
	do
		cp \${j}/d${N_dim_indICA}/melodic_IC.nii.gz \
			\${i}/metaICA/melodicIC_from_indICA/\$(basename \$j)_d${N_dim_indICA}_melodicIC.nii.gz
	done

	# write the list of individual melodic IC maps
	ls \${i}/metaICA/melodicIC_from_indICA/ICA_*_d${N_dim_indICA}_melodicIC.nii.gz > \${i}/metaICA/indICA_d${N_dim_indICA}_melodicIC.list

	# meta ICA with individual IC maps
	case ${N_dim_metaICA} in

		auto)
			
			melodic -i \${i}/metaICA/indICA_d${N_dim_indICA}_melodicIC.list -o \${i}/metaICA/d${N_dim_metaICA} --tr=${tr} --nobet --bgthreshold=1 -a concat --bgimage=${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${resample_scale}mm -m ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${resample_scale}mm --report --mmthresh=0.5 --Oall
			;;
		*)
			melodic -i \${i}/metaICA/indICA_d${N_dim_indICA}_melodicIC.list -o \${i}/metaICA/d${N_dim_metaICA} --tr=${tr} --nobet --bgthreshold=1 -a concat --bgimage=${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${resample_scale}mm -m ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${resample_scale}mm --report --mmthresh=0.5 --Oall -d ${N_dim_metaICA}
			;;
	esac
done
EOF

# submit jobs
if [ "${qsub_flag}" = "yesQsub" ]; then
	metaICA_jid=`echo $(qsub ${cohortFolder}/SGE_commands/metaICA.sge) | awk '{print $3}'`
fi



