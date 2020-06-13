#!/bin/bash

BIDS_dir=/data/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS
fmriprep_version=v1.5.4
fs_license=/home/jiyang/Software/FUTURE/fMRI/fMRIPrep/FS_license.txt
method_code=2

mkdir -p ${BIDS_dir}/derivatives/fmriprep-${fmriprep_version}/work

cd ${BIDS_dir}
sub_list=$(ls -1d sub-* | tr '\n' ' ')


case ${method_code} in

        1)

                fmriprep-docker ${BIDS_dir}\
                                ${BIDS_dir}/derivatives/fmriprep-${fmriprep_version} \
                                participant \
                                --fs-license-file ${fs_license} \
                                --participant_label ${sub_list} \
                                --work-dir ${BIDS_dir}/derivatives/fmriprep-${fmriprep_version}/work \
                                --ignore {fieldmaps,slicetiming} \
                                --output-spaces MNI152NLin6Asym:res-2 MNI152NLin2009cAsym \
                                --nthreads 30 \
                                --mem_mb 240000 \
                                --use-aroma \
                                --use-syn-sdc \
                                --write-graph \
                                --skip_bids_validation
        ;;


        2)
                # note that this example is using v1.5.2 
                docker run -it --rm \
                           -v ${BIDS_dir}:/data:ro \
                           -v ${BIDS_dir}/derivatives/fmriprep-${fmriprep_version}:/out \
                           -v ${fs_license}:/opt/freesurfer/license.txt \
                           -v ${BIDS_dir}/derivatives/fmriprep-${fmriprep_version}/work:/work \
                           poldracklab/fmriprep:1.5.2 \
                           /data /out \
                           participant \
                           --fs-license-file /opt/freesurfer/license.txt \
                           --participant_label ${sub_list} \
                           --work-dir /work \
                           --ignore {fieldmaps,slicetiming} \
                           --output-spaces MNI152NLin6Asym:res-2 MNI152NLin2009cAsym \
                           --nthreads 30 \
                           --mem_mb 240000 \
                           --use-aroma \
                           --use-syn-sdc \
                           --write-graph \
                           --skip_bids_validation
                           
                           
        ;;



esac



