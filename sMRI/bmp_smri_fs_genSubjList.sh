#!/bin/bash

usage(){

cat << EOF

$(basename $0) : Generate a list of subjects in SUBJECTS_DIR.


USAGE : 

  $(basename $0) [{-s|--subjects_dir <subjects_dir>] \
                 [{-o|--output_dir} <output_dir] \
                 [{-l|--longitudilal}]


COMPULSORY :

  None


OPTIONAL :

    -s, --subjects_dir      <subjects_dir>          Directory where all subjects are stored (defaults is SUBJECTS_DIR).

    -o, --output_dir        <output_dir>            Path to output directory (default is subjects_dir).

    -l, --longitudinal                              Treat as longitudinal datasets (default is cross-sectional).

    -h, --help                                      Display this message.


OUTPUT : 

  Path to the generated subjects list.

EOF
}

# set defaults
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

		-l | --longitudinal)
			long_flag=1;
			shift
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
[ -z ${out_dir+x} ]      && out_dir=${subj_dir}

# generate subjects list
if [ "${long_flag}" -eq 1 ];then

	find -L ${subj_dir}     -mindepth 1 \
	                        -maxdepth 1 \
	                        -type d \
	                        -name "*.long.*" \
	                        -and -not -name fsaverage \
	                        -print0 \
	                        | xargs -0 -n1 basename \
	                        | sort > ${out_dir}/subjs.list
else

	find -L ${subj_dir}     -mindepth 1 \
	                        -maxdepth 1 \
	                        -type d \
	                        -and -not -name fsaverage \
	                        -print0 \
	                        | xargs -0 -n1 basename \
	                        | sort > ${out_dir}/subjs.list
fi

# argument out
echo "${out_dir}/subjs.list"