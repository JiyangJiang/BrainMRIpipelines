cd /data3/adni/adni_all
mkdir iotools tmp CAPS

clinica iotools create-subjects-visits BIDS iotools/visits.tsv
clinica iotools check-missing-modalities BIDS iotools

ses=M00

# ==> NOTE t1w_col_num NEEDS TO BE CHANGED
# ++++++++++++++++++++++++++++++++++++++++
cat iotools/missing_mods_ses-${ses}.tsv | awk -v t1w_col_num="4" '{print $1,$t1w_col_num}' | awk '$2 == "1"' | awk '{print $1}' > iotools/t1w_${ses}.tsv
sed -i "s/$/\tses-${ses}/" iotools/t1w_${ses}.tsv
sed -i '1s/^/participant_id\tsession_id\n/' iotools/t1w_${ses}.tsv

clinica run t1-freesurfer -tsv iotools/t1w_${ses}.tsv -wd tmp -np 32 BIDS CAPSs