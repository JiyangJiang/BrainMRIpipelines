#!/bin/bash

ind_BIDS_dir=$1

mkdir -p $ind_BIDS_dir/work

# 105 vols
# 1st vol is M0
#
num_asls=$(ls $ind_BIDS_dir/func/*_asl.nii* | wc | awk '{print $1}')
num_t1s=$(ls $ind_BIDS_dir/anat/*_T1w.nii* | wc | awk '{print $1}')
echo "There are ${num_asls} ASLs and ${num_t1s} T1s."

ls $ind_BIDS_dir/func/*_asl.nii* > $ind_BIDS_dir/work/ASL_list.txt
ls $ind_BIDS_dir/anat/*_T1w.nii* > $ind_BIDS_dir/work/T1w_list.txt

# while read t1
# do
# 	imcp ${t1} $ind_BIDS_dir/work/t1
# 	t1_withoutSuffix=$(echo ${t1} | cut -d. -f1)
# 	echo "fsl_anat processing for $(echo $t1_withoutSuffix | awk -F'/' '{print $NF}') ... "
# 	[[ -d "$ind_BIDS_dir/work/t1.anat" ]] && rm -fr $ind_BIDS_dir/work/t1.anat
# 	fsl_anat -i $ind_BIDS_dir/work/t1 -o $ind_BIDS_dir/work/t1
# done < $ind_BIDS_dir/work/T1w_list.txt

while read asl
do
	asl_withoutSuffix=$(echo $asl | cut -d. -f1)
	echo "BASIL processing for $(echo $asl_withoutSuffix | awk -F'/' '{print $NF}') ... "

	fslroi $asl_withoutSuffix $ind_BIDS_dir/work/m0 0 1
	fslroi $asl_withoutSuffix $ind_BIDS_dir/work/asl 1 -1

	mkdir -p $ind_BIDS_dir/work/basil_autoCSFmask

	scanner_model=$(grep -w "DeviceSerialNumber" ${asl_withoutSuffix}.json | awk -F'"' '{print $4}')
	software_version=$(grep -w "SoftwareVersions" ${asl_withoutSuffix}.json | awk -F'"' '{print $4}')

	# Ref : https://www.oasis-brains.org/files/OASIS-3_Imaging_Data_Dictionary_v2.3.pdf (Page 16)
	case "$scanner_model" in
		51010)
			case "$software_version" in
				syngo_MR_B18P|syngo_MR_B20P)
					bolus=0.7
					ti=1.9
					slicedt=46
					;;
				*)
					echo "---=== !!! ===---"
					echo "WARNING : scanner model = $scanner_model, unknown software version $software_version."
					echo "---=== !!! ===---"
					;;
			esac
			;;
		35177)
			case "$software_version" in
				syngo_MR_B17P)
					bolus=0.7
					ti=1.9
					slicedt=36.4
					;;
				*)
					echo "---=== !!! ===---"
					echo "WARNING : scanner model = $scanner_model, unknown software version $software_version."
					echo "---=== !!! ===---"
					;;
			esac
			;;
		35248)
			case "$software_version" in
				syngo_MR_B17P)
					bolus=0.7
					ti=1.8
					slicedt=36.4
					;;
				*)
					echo "---=== !!! ===---"
					echo "WARNING : scanner model = $scanner_model, unknown software version $software_version."
					echo "---=== !!! ===---"
					;;
			esac
			;;
		175614)
			echo "scanner model = $scanner_model ??????"
			;;
		*)
			echo "---=== !!! ===---"
			echo "WARNING : unknown scanner model $scanner_model, unknown software version $software_version."
			echo "---=== !!! ===---"
			;;
	esac

	tr=$(grep -w "RepetitionTime" ${asl_withoutSuffix}.json | awk -F": " '{print $2}' | awk -F',' '{print $1}')
	te_sec=$(grep -w "EchoTime" ${asl_withoutSuffix}.json | awk -F": " '{print $2}' | awk -F',' '{print $1}')
	te=$( bc -l <<< "$te_sec*1000" )
	nvols=$(fslnvols $ind_BIDS_dir/work/asl)
	npairs=$( bc -l <<< "$nvols/2" )

cat << EOT > $ind_BIDS_dir/work/basil_command.sh
#!/bin/bash

oxford_asl 	-i=$ind_BIDS_dir/work/asl \
			--iaf=tc \
			--ibf=rpt \
			--bolus=0.7 \
			--rpts=${npairs} \
			--slicedt=${slicedt} \
			--tis=1.8 \
			--fslanat=$ind_BIDS_dir/work/t1.anat \
			-c=$ind_BIDS_dir/work/m0 \
			--cmethod=single \
			--tr=${tr} \
			--cgain=1 \
			--tissref=csf \
			--t1csf=4.3 \
			--t2csf=750 \
			--t2bl=150 \
			--te=${te} \
			-o=$ind_BIDS_dir/work/basil_autoCSFmask \
			--bat=0.7 \
			--t1=1.3 \
			--t1b=1.65 \
			--alpha=0.98 \
			--spatial=1 \
			--mc \
			--pvcorr \
			--artoff
EOT

sh $ind_BIDS_dir/work/basil_command.sh

done < $ind_BIDS_dir/work/ASL_list.txt