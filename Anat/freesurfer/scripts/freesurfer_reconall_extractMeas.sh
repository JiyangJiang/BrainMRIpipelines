#!/bin/bash

usage(){

cat << EOF

$(basename $0) : extract measures after recon-all processing"

Usage : $(basename $0) "

        -s, --subjects_dir      <subjects_dir>          Subjects directory where all recon-all results are stored 
                                                        (defaults is SUBJECTS_DIR).

        -o, --output_dir        <output_dir>            Path to output directory (default is current dir).

        -p, --filename_prefix   <filename_prefix>       Filename prefix (default=reconall).

        -a, --append            <text>                  Text to append to the end of filename (e.g. FreeSurfer version, 
                                                        specific options used in recon-all, etc. Default=date).

        -d, --divide            <pattern>               For data with multiple time points, the first step of recon-all
                                                        can be run on all time pooints in cross-sectional fashion. This 
                                                        option separates cross-sectional results into different Waves
                                                        according to <pattern> which is delimited by comma (e.g.,
                                                        _w1,_w2,_w4). No dividing will be done if this flag is unset.

        -h, --help                                      Display this message.

EOF
}

# resolve arguments
div_flag=0

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

# generate subjects list
find -L ${subj_dir}     -mindepth 1 \
                        -maxdepth 1 \
                        -type d \
                        -and -not -name fsaverage \
                        -print0 \
                        | xargs -0 -n1 basename > ${subj_dir}/subjs.list

subj_list=${subj_dir}/subjs.list

# extract measures
for aseg_meas in volume mean std
do

        asegstats2table --subjectsfile=${subj_list} \
                        --meas=${aseg_meas} \
                        --tablefile=${out_dir}/${fname_prefix}.${append}.aseg.${aseg_meas} \
                        --skip \
                        --all-segs \
                        --delimiter=comma

        if [ "${aseg_meas}" = "volume" ];then
                asegstats2table --subjectsfile=${subj_list} \
                                --meas=${aseg_meas} \
                                --tablefile=${out_dir}/${fname_prefix}.${append}.aseg.${aseg_meas}.etiv_perc \
                                --skip \
                                --all-segs \
                                --delimiter=comma \
                                --etiv
        fi

done

for aparc_meas in area volume thickness thicknessstd meancurv gauscurv foldind curvind
do
        for hemi in lh rh
        do
                for parc in aparc aparc.a2009s
                do

                        aparcstats2table --subjectsfile=${subj_list} \
                                        --hemi=${hemi} \
                                        --measure=${aparc_meas} \
                                        --parc=${parc} \
                                        --tablefile=${out_dir}/${fname_prefix}.${append}.aparc.${aparc_meas}.${hemi}.${parc} \
                                        --skip \
                                        --delimiter=comma

                        if [ "${aparc_meas}" = "volume" ];then
                        aparcstats2table --subjectsfile=${subj_list} \
                                        --hemi=${hemi} \
                                        --measure=${aparc_meas} \
                                        --parc=${parc} \
                                        --tablefile=${out_dir}/${fname_prefix}.${append}.aparc.${aparc_meas}.${hemi}.${parc}.etiv_perc \
                                        --skip \
                                        --delimiter=comma \
                                        --etiv
                        fi

                done
        done
done

# wm vol
asegstats2table --stats wmparc.stats \
                --subjectsfile=${subj_list} \
                --meas=volume \
                --tablefile=${out_dir}/${fname_prefix}.${append}.aseg.wm_vol \
                --skip \
                --all-segs \
                --delimiter=comma

asegstats2table --stats wmparc.stats \
                --subjectsfile=${subj_list} \
                --meas=volume \
                --tablefile=${out_dir}/${fname_prefix}.${append}.aseg.wm_vol.etiv_perc \
                --skip \
                --all-segs \
                --delimiter=comma \
                --etiv

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