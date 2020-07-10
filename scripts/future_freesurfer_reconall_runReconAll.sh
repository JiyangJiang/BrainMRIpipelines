#!/bin/bash

usage(){

cat << EOF

$(basename $0) : run freesurfer recon-all.


USAGE : 

	$(basename $0) [OPTIONS]


COMPULSORY :

	-t1, --t1_nifti_dir 		<t1_nifti_dir>			Directory where all T1 nifti files are stored.

	-g,  --gadi											Work on PBS-based NCI Gadi cluster. -ns or --noSubmit needs 
														to be specified to stop submiting jobs (i.e. only generate jobs
														as text). Default is automatically submitting jobs. Note that
														hippocampal subfields, amygdalar nuclei, brainstem substructure,
														and thalamic nuclei cannot be segmented on Gadi due to the
														required MATLAB runtime. Run them on NiL instead.

	-n,  --nil											Work on SGE-based CHeBA NiL cluster using fsl_sub. -ns or 
														--noSubmit needs to be specified to stop submiting jobs (i.e. 
														only generate jobs as text). Default is automatically submitting 
														jobs.

	-d,  --grid											Work on multi-core workstation, GRID. (NOT IMPLEMENTED YET)

	-S, --scrpt_dir				<job_scripts_dir>		Directory to store job scripts.


OPTIONAL :

    -s, --subjects_dir   	    <subjects_dir>          Subjects directory where all recon-all results will be stored 
                           	                    	    (defaults is SUBJECTS_DIR).

    -f, --flair					<flair_nifti_dir>		If FLAIR's are used together with T1 for surface reconstruction
    													in FreeSurfer recon-all, path to directory with all FLAIR nifti 
    													files needs to be passed to command. NOT IMPLEMENTED YET.

	-ns, --notSubmit 									If -g, --gadi, -n, or --nil is used, and do not want to submit
														jobs to job scheduler (i.e. only generating job text files), 
														-ns or --noSubmit should be specified. Default is automatically 
														submitting. NOT IMPLEMENTED YET.

    -ha, --hippoAmyg									Segmenting hippocampal subfields and amygdalar nuclei after
    													standard recon-all. Default is running recon-all only.
    													NOT IMPLEMENTED YET.

    -oha, --onlyHippoAmyg								Only segmenting hippocampal subfields. Assuming recon-all has
    													been run, and resultant subjects directories are stored in
    													subjects_dir. NOT IMPLEMENTED YET.

    -b, --brnstm										Segmenting brainstem substrucutres after standard recon-all.
													    Default is running recon-all only. NOT IMPLEMENTED YET.

	-ob, --onlyBrnstm									Only segmenting brainstem substrucutres. Assuming recon-all has
    													been run, and resultant subjects directories are stored in
    													subjects_dir. NOT IMPLEMENTED YET.

	-t, --thalam										Segmenting thalamic nuclei after standard recon-all. Default
														is running recon-all only. NOT IMPLEMENTED YET.

	-ot, --onlyThalam									Only segmenting thalamic nuclei. Assuming recon-all has
    													been run, and resultant subjects directories are stored in
    													subjects_dir. NOT IMPLEMENTED YET.

    -h, --help											Display this message.


EOF

}

# defaults
gadi_flag=0
nil_flag=0
grid_flag=0
useFLAIR_flag=0
notSubmit_flag=0
hippoAmyg_flag=0
noReconAll_flag=0
brnstm_flag=0
thalam_flag=0

# resolve arguments
for arg in $@
do
	case "$arg" in
		-t1 | --t1_nifti_dir)
			t1_dir=$2
			shift 2
			;;

		-g | --gadi)
			gadi_flag=1
			shift
			;;

		-n | --nil)
			nil_flag=1
			shift
			;;

		-d | --grid)
			grid_flag=1
			shift
			;;

		-s | --subjects_dir)
			subj_dir=$2
			shift 2
			;;

		-f | --flair)
			useFLAIR_flag=1
			flair_dir=$2
			shift 2
			;;

		-ns | --notSubmit)
			notSubmit_flag=1
			shift
			;;

		-ha | --hippoAmyg)
			hippoAmyg_flag=1
			shift
			;;

		-oha | --onlyHippoAmyg)
			noReconAll_flag=1
			hippoAmyg_flag=1
			shift
			;;

		-b | --brnstm)
			brnstm_flag=1
			shift
			;;

		-ob | --onlyBrnstm)
			noReconAll_flag=1
			brnstm_flag=1
			shift
			;;

		-t | --thalam)
			thalam_flag=1
			shift
			;;
			
		-ot | --onlyThalam)
			noReconAll_flag=1
			thalam_flag=1
			shift
			;;

		-S | --scrpt_dir)
			scrpt_dir=$2
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

[ -z ${subj_dir+x} ] && subj_dir=$SUBJECTS_DIR

for i in ${t1_dir}/*.nii*
do
	reconall_subj=$(basename $(imglob $i))
	echo "recon-all -s ${reconall_subj} -i $i -wsatlas --no-isrunning -all -sd ${subj_dir}" >> ${scrpt_dir}/recon-all.jobs
done