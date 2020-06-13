#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

fMRI_blipped_prepareNIfTIimgs(){
	DICOM_folder=$1
	ID=$2
	subjects_folder=$3
	

	echo "fMRI_blipped_prepareNIfTIimgs.sh: Prepare blipped fMRI pairs for generating field maps ..."

	if [ ! -d "${subjects_folder}/${ID}/fMRI" ]; then
		mkdir ${subjects_folder}/${ID}/fMRI
	fi

	if [ -d "${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap" ]; then
		rm -fr ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap
	fi

	mkdir ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap

	cp ${DICOM_folder}/${ID}_*_blip_rsFMRI*.nii \
		${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_blipped_fMRI_raw.nii

	N_vol_blippedFMRI=`fslsize ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_blipped_fMRI_raw.nii | grep -w "dim4" | awk '{print $2}'`
	echo "fMRI_blipped_prepareNIfTIimgs.sh: ${N_vol_blippedFMRI} volumes of blipped fMRI."

	echo "fMRI_blipped_prepareNIfTIimgs.sh: Splitting blipped fMRI and use only the last 5 volumes."
	fslsplit ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_blipped_fMRI_raw.nii \
				${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_blipped_fMRI_raw_splitted \
				-t

	# startLoop=$((N_vol_blippedFMRI - lastNvol2use))
	# endLoop=$((N_vol_blippedFMRI - 1))

	# startLoop=`expr $N_vol_blippedFMRI - $lastNvol2use`
	# endLoop=`expr $N_vol_blippedFMRI - 1`
	
	splittedImg_str=""
	# for i in {$startLoop..$endLoop}
	for i in {5..9}
	do
		index=`echo $i`
		splittedImg="${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_blipped_fMRI_raw_splitted000${index}.nii.gz "
		splittedImg_str=${splittedImg_str}${splittedImg}
	done

	fslmerge -t ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_blipped_fMRI_raw_5to9vols \
				${splittedImg_str}

	rm -f ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_blipped_fMRI_raw_splitted0*.nii.gz

	echo "fMRI_blipped_prepareNIfTIimgs.sh: Blipped fMRI are ready."


	################ End of preparation of blipped fMRI ####################






	echo "fMRI_blipped_prepareNIfTIimgs.sh: Now prepare normal fMRI."

	cp ${DICOM_folder}/${ID}_*_MB_rs*.nii \
		${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_fMRI_raw.nii

	N_vol_fMRI=`fslsize ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_fMRI_raw.nii | grep -w "dim4" | awk '{print $2}'`
	echo "fMRI_blipped_prepareNIfTIimgs.sh: ${N_vol_fMRI} volumes of fMRI."

	echo "fMRI_blipped_prepareNIfTIimgs.sh: Splitting fMRI, and use the 5 - 9th volumes for generating field map."
	fslsplit ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_fMRI_raw.nii \
				${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_fMRI_raw_splitted \
				-t

	splittedImg_str=""
	# for i in {$startLoop..$endLoop}
	for i in {5..9}
	do
		index=`echo $i`
		splittedImg="${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_fMRI_raw_splitted000${index}.nii.gz "
		splittedImg_str=${splittedImg_str}${splittedImg}
	done

	fslmerge -t ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_fMRI_raw_5to9vols \
				${splittedImg_str}

	rm -f ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_fMRI_raw_splitted0*.nii.gz

	################# End of preparation of fMRI for field map ##################








	fslmerge -t ${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_blipped_pairs \
				${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_fMRI_raw_5to9vols \
				${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap/${ID}_blipped_fMRI_raw_5to9vols

	echo "fMRI_blipped_prepareNIfTIimgs.sh: Finished."

}

fMRI_blipped_prepareNIfTIimgs $1 $2 $3