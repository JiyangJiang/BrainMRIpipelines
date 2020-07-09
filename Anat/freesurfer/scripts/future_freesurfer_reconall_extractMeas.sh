#!/bin/bash

usage(){

cat << EOF

$(basename $0) : extract measures after recon-all processing

USAGE : $(basename $0) [OPTIONS]

        -s, --subjects_dir      <subjects_dir>          Subjects directory where all recon-all results are stored 
                                                        (defaults is SUBJECTS_DIR).

        -o, --output_dir        <output_dir>            Path to output directory (default is current dir).

        -R, --reconall                                  Extract standard measures from recon-all processing (default
                                                        is NOT extracting).

        -H, --hipp                                      Extract volumes of hippocampal subfields (default is NOT
                                                        extracting).

        -A, --amyg                                      Extract volumes of amydalar nuclei (default is NOT extracting).

        -B, --brnstm                                    Extract volumes of brainstem substructures (default is NOT
                                                        extracting).

        -T, --thalam                                    Extract volumes of thalamic nuclei (default is NOT extracting).

        -l, --longitudinal                              Treat as longitudinal results (default is cross-sectional).

        -p, --filename_prefix   <filename_prefix>       Filename prefix (default=reconall).

        -a, --append            <text>                  Text to append to the end of filename (e.g. FreeSurfer version, 
                                                        specific options used in recon-all, etc. Default=date).

        -d, --divide            <pattern>               For data with multiple time points, the first step of recon-all
                                                        can be run on all time pooints in cross-sectional fashion. This 
                                                        option separates cross-sectional results into different Waves
                                                        according to <pattern> which is delimited by comma (e.g.,
                                                        _w1,_w2,_w4). No dividing will be done if this flag is unset.

        -h, --help                                      Display this message.


OUTPUT : None


TO-DO : Longitudinal datasets may still need to be tested.

EOF
}

# set defaults
div_flag=0
reconall_flag=0
hipp_flag=0
amyg_flag=0
brnstm_flag=0
thalam_flag=0
long_flag=0

# resolve arguments
for arg in $@
do
        case "$arg" in

                -s | --subjects_dir)
                        subj_dir=$2
                        shift 2
                        ;;

                -o | --output_dir)
                        out_dir=$2
                        shift 2
                        ;;

                -p | --filename_prefix)
                        fname_prefix=$2
                        shift 2
                        ;;

                -a | --append)
                        append=$2
                        shift 2
                        ;;

                -d | --divide)
                        div_flag=1
                        div=$2
                        shift 2
                        ;;

                -h | --help)
                        usage
                        exit 0
                        ;;

                -R | --reconall)
                        reconall_flag=1
                        echo "$(basename $0) : Will extract recon-all results."
                        shift
                        ;;

                -H | --hipp)
                        hipp_flag=1
                        echo "$(basename $0) : Will extract hippocampal subfields results."
                        shift
                        ;;

                -A | --amyg)
                        amyg_flag=1
                        echo "$(basename $0) : Will extract amygdalar nuclei results."
                        shift
                        ;;

                -B | --brnstm)
                        brnstm_flag=1
                        echo "$(basename $0) : Will extract brainstem substructure results."
                        shift
                        ;;

                -T | --thalam)
                        thalam_flag=1
                        echo "$(basename $0) : Will extract thalamic nuclei results."
                        shift
                        ;;

                -l | --longitudinal)
                        long_flag=1
                        echo "$(basename $0) : treat as longitudinal dataset."
                        shift
                        ;;

                -*)
                        usage
                        exit 1
                        ;;
        esac
done

# set to default if variables are unset
[ -z ${subj_dir+x} ]     && subj_dir=${SUBJECTS_DIR}
[ -z ${out_dir+x} ]      && out_dir=$(pwd)
[ -z ${fname_prefix+x} ] && fname_prefix=reconall
[ -z ${append+x} ]       && append=$(date | sed -e 's/ /_/g' | sed -e 's/:/-/g')

# dividing into Waves requires to specify dividers
[ "${div_flag}" -eq 1 ]  && [ -z ${div+x} ] && usage && exit 1

export SUBJECTS_DIR=${subj_dir}

# extract standard recon-all measures
if [ "${reconall_flag}" -eq 1 ]; then

        # generate subjects lists
        subj_list=`future_freesurfer_genSubjList -s ${subj_dir} -o ${subj_dir}`

        # extract measures
        for aseg_meas in volume mean std
        do
                echo "$(basename $0) : ${aseg_meas} from aseg."
                asegstats2table --subjectsfile=${subj_list} \
                                --meas=${aseg_meas} \
                                --tablefile=${out_dir}/${fname_prefix}.${append}.aseg.${aseg_meas} \
                                --skip \
                                --all-segs \
                                --delimiter=comma >> $(basename $0).log

                if [ "${aseg_meas}" = "volume" ];then
                        echo "$(basename $0) : ${aseg_meas} from aseg as percentage of etiv."
                        asegstats2table --subjectsfile=${subj_list} \
                                        --meas=${aseg_meas} \
                                        --tablefile=${out_dir}/${fname_prefix}.${append}.aseg.${aseg_meas}.etiv_perc \
                                        --skip \
                                        --all-segs \
                                        --delimiter=comma \
                                        --etiv >> $(basename $0).log
                fi

        done

        for aparc_meas in area volume thickness thicknessstd meancurv gauscurv foldind curvind
        do
                for hemi in lh rh
                do
                        for parc in aparc aparc.a2009s
                        do
                                echo "$(basename $0) : ${aparc_meas} with ${parc} template on ${hemi}."
                                aparcstats2table --subjectsfile=${subj_list} \
                                                --hemi=${hemi} \
                                                --measure=${aparc_meas} \
                                                --parc=${parc} \
                                                --tablefile=${out_dir}/${fname_prefix}.${append}.aparc.${aparc_meas}.${hemi}.${parc} \
                                                --skip \
                                                --delimiter=comma >> $(basename $0).log

                                if [ "${aparc_meas}" = "volume" ];then
                                        echo "$(basename $0) : ${aparc_meas} with ${parc} template on ${hemi} as percentage of etiv."
                                        aparcstats2table --subjectsfile=${subj_list} \
                                                        --hemi=${hemi} \
                                                        --measure=${aparc_meas} \
                                                        --parc=${parc} \
                                                        --tablefile=${out_dir}/${fname_prefix}.${append}.aparc.${aparc_meas}.${hemi}.${parc}.etiv_perc \
                                                        --skip \
                                                        --delimiter=comma \
                                                        --etiv >> $(basename $0).log
                                fi

                        done
                done
        done

        # wm vol
        echo "$(basename $0) : wm vol from wmparc.stats."
        asegstats2table --stats wmparc.stats \
                        --subjectsfile=${subj_list} \
                        --meas=volume \
                        --tablefile=${out_dir}/${fname_prefix}.${append}.aseg.wm_vol \
                        --skip \
                        --all-segs \
                        --delimiter=comma >> $(basename $0).log

        echo "$(basename $0) : wm vol from wmparc.stats as percentage of etiv."
        asegstats2table --stats wmparc.stats \
                        --subjectsfile=${subj_list} \
                        --meas=volume \
                        --tablefile=${out_dir}/${fname_prefix}.${append}.aseg.wm_vol.etiv_perc \
                        --skip \
                        --all-segs \
                        --delimiter=comma \
                        --etiv >> $(basename $0).log
fi

# subcortical GM substructures
if [ "${hipp_flag}" -eq 1 ];then
        if [ "${long_flag}" -eq 1 ];then
                echo "$(basename $0) : longitudinal hippocampal subfields."
                quantifyHAsubregions.sh hippoSf T1.long ${out_dir}/${fname_prefix}.${append}.hippoSf_long ${subj_dir} >> $(basename $0).log
                sed -i 's/ /,/g' ${out_dir}/${fname_prefix}.${append}.hippoSf_long
        else
                echo "$(basename $0) : hippocampal subfields."
                quantifyHAsubregions.sh hippoSf T1 ${out_dir}/${fname_prefix}.${append}.hippoSf ${subj_dir} >> $(basename $0).log
                sed -i 's/ /,/g' ${out_dir}/${fname_prefix}.${append}.hippoSf
        fi
fi
if [ "${amyg_flag}" -eq 1 ];then
        if [ "${long_flag}" -eq 1 ];then
                echo "$(basename $0) : longitudinal amygdalar nuclei."
                quantifyHAsubregions.sh amygNuc T1.long ${out_dir}/${fname_prefix}.${append}.amygNuc_long ${subj_dir} >> $(basename $0).log
                sed -i 's/ /,/g' ${out_dir}/${fname_prefix}.${append}.amygNuc_long
        else
                echo "$(basename $0) : amygdalar nuclei."
                quantifyHAsubregions.sh amygNuc T1 ${out_dir}/${fname_prefix}.${append}.amygNuc ${subj_dir} >> $(basename $0).log
                sed -i 's/ /,/g' ${out_dir}/${fname_prefix}.${append}.amygNuc
        fi
fi
if [ "${brnstm_flag}" -eq 1 ];then
        echo "$(basename $0) : brainstem substructures."
        quantifyBrainstemStructures.sh ${out_dir}/${fname_prefix}.${append}.brnstm_substruct ${subj_dir} >> $(basename $0).log
        sed -i 's/ /,/g' ${out_dir}/${fname_prefix}.${append}.brnstm_substruct
        # on the website, longitudinal data are suggested to be treated as cross-sectional in brainstem substructure
        # extraction.
fi
if [ "${thalam_flag}" -eq 1 ];then
        echo "$(basename $0) : thalamic nuclei."
        quantifyThalamicNuclei.sh  ${out_dir}/${fname_prefix}.${append}.thalamNuc T1 ${subj_dir} >> $(basename $0).log
        sed -i 's/ /,/g' ${out_dir}/${fname_prefix}.${append}.thalamNuc
        # no suggestion on longitudinal on the website.
fi



# dividing into different Waves
if [ "${div_flag}" -eq 1 ]
then
        for i in ${out_dir}/*.aseg.* ${out_dir}/*.aparc.*
        do
                for j in $(echo ${div} | sed "s/,/ /g")
                do
                        awk 'NR==1' $i > ${i}.${j}
                        grep $j $i >> ${i}.${j}
                done
        done
fi