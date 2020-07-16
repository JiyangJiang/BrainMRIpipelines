#!/bin/sh

#   fslvbm_2_template - FSLVBM template creation
#
#   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                                          ---=== Jmod ===---
#   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   April 24, 2020 : The original code use default -90~90 degrees search in FLIRT. Sometimes this is not
#                    sufficient. For example, if FreeSurfer's nu.mgz and brainmask.mgz are used for
#                    bias field correction and brain extraction, the orientation is very different from
#                    MNI152. Therefore, -180~180 search is necessary.
#
#                    stop auto submitting to SGE, so that processing can be started from middle steps
#                    using previous steps' outputs. i.e. do not have to start from beginning.
#
#                    fslvbm2a : run FAST for segmentation pve1 is used as GM map (*_struc_GM.nii.gz).
#                    fslvbm2b : affine GM map to avg152T1_gray (*_struc_GM_to_T.nii.gz).
#                    fslvbm2c : averaging to generate template (template_4D_GM, template_GM, template_GM_init, template_GM_flipped)
#                    fslvbm2d : fnirt to template (*_struc_GM_to_T_init.nii.gz).
#                    fslvbm2e : redo fslvbm2c with *_struc_GM_to_T_init.nii.gz (template_4D_GM, template_GM, template_GM_init, template_GM_flipped).
#
#   April 25, 2020 : add "--aff=*_GM2Tmtx_Jmod.mat" to FNIRT, because of the same reason as above. The
#                    original code does not consider the affine matrix established in fslvbm2b. Therefore,
#                    it is added.
#
#                    change to use whole brain image for all transformations, as transformation using only
#                    GM seg does not yield meaningful results. Why this is only the case with FreeSurfer
#                    nu.mgz and brainmask.mgz, but not SPM c123 extracted brain???

export LC_ALL=C

Usage() {
    echo ""
    echo "Usage: fslvbm_2_template [options]"
    echo ""
    echo "-n  : nonlinear registration (recommended)"
    echo "-a  : affine registration (discouraged)"
    echo ""
    exit 1
}

[ "$1" = "" ] && Usage

echo [`date`] [`hostname`] [`uname -a`] [`pwd`] [$0 $@] >> .fslvbmlog

HOWLONG=30
if [ $1 = -a ] ; then
    REG="-a"
    HOWLONG=5
fi

cd struc

T=${FSLDIR}/data/standard/tissuepriors/avg152T1_gray
Tbrain=${FSLDIR}/data/standard/data/standard/MNI152_T1_2mm_brain

### segmentation
/bin/rm -f fslvbm2a
for g in `$FSLDIR/bin/imglob *_struc.*` ; do
    echo $g
    echo "$FSLDIR/bin/fast -R 0.3 -H 0.1 ${g}_brain ; \
          $FSLDIR/bin/immv ${g}_brain_pve_1 ${g}_GM" >> fslvbm2a
done
chmod a+x fslvbm2a
#fslvbm2a_id=`$FSLDIR/bin/fsl_sub -T 30 -N fslvbm2a -t ./fslvbm2a`
#echo Running segmentation: ID=$fslvbm2a_id

### Estimation of the registration parameters of GM to grey matter standard template
/bin/rm -f fslvbm2b
for g in `$FSLDIR/bin/imglob *_struc.*` ; do
  # echo "${FSLDIR}/bin/fsl_reg ${g}_GM $T ${g}_GM_to_T -a" >> fslvbm2b
  # Jmod
  echo -n "${FSLDIR}/bin/fsl_reg ${g}_GM $T ${g}_GM_to_T -a -flirt \"-searchrx -180 180 -searchry -180 180 -searchrz -180 180 -omat ${g}_GM2Tmtx_Jmod.mat\";" >> fslvbm2b
  echo "${FSLDIR}/bin/flirt -in ${g}_brain -ref $T -init ${g}_GM2Tmtx_Jmod.mat -applyxfm -out ${g}_brain_to_T" >> fslvbm2b
done
chmod a+x fslvbm2b
#fslvbm2b_id=`$FSLDIR/bin/fsl_sub -j $fslvbm2a_id -T $HOWLONG -N fslvbm2b -t ./fslvbm2b`
#echo Running initial registration: ID=$fslvbm2b_id

### Creation of the GM template by averaging all (or following the template_list for) the GM_nl_0 and GM_xflipped_nl_0 images
cat <<stage_tpl3 > fslvbm2c
#!/bin/sh
if [ -f ../template_list ] ; then
    template_list=\`cat ../template_list\`
    template_list=\`\$FSLDIR/bin/remove_ext \$template_list\`
else
    template_list=\`echo *_struc.* | sed 's/_struc\./\./g'\`
    template_list=\`\$FSLDIR/bin/remove_ext \$template_list | sort -u\`
    echo "WARNING - study-specific template will be created from ALL input data - may not be group-size matched!!!"
fi
for g in \$template_list ; do
    mergelist="\$mergelist \${g}_struc_GM_to_T"
    mergelist_brain="\$mergelist_brain \${g}_struc_brain_to_T"
done
\$FSLDIR/bin/fslmerge -t template_4D_GM \$mergelist
\$FSLDIR/bin/fslmaths template_4D_GM -Tmean template_GM
\$FSLDIR/bin/fslswapdim template_GM -x y z template_GM_flipped
\$FSLDIR/bin/fslmaths template_GM -add template_GM_flipped -div 2 template_GM_init

# Jmod
\$FSLDIR/bin/fslmerge -t brain2Temp_4D \$mergelist_brain
\$FSLDIR/bin/fslmaths brain2Temp_4D -Tmean brain2Temp
\$FSLDIR/bin/fslswapdim brain2Temp -x y z brain2Temp_flipped
\$FSLDIR/bin/fslmaths brain2Temp -add brain2Temp_flipped -div 2 brain2Temp_init
stage_tpl3
chmod +x fslvbm2c
#fslvbm2c_id=`fsl_sub -j $fslvbm2b_id -T 15 -N fslvbm2c ./fslvbm2c`
#echo Creating first-pass template: ID=$fslvbm2c_id

### Estimation of the registration parameters of GM to grey matter standard template
/bin/rm -f fslvbm2d
T=template_GM_init
Tbrain=brain2Temp_init
for g in `$FSLDIR/bin/imglob *_struc.*` ; do
  # echo "${FSLDIR}/bin/fsl_reg ${g}_GM $T ${g}_GM_to_T_init $REG -fnirt \"--config=GM_2_MNI152GM_2mm.cnf\"" >> fslvbm2d
  # Jmod
  echo -n "${FSLDIR}/bin/fsl_reg ${g}_brain ${Tbrain} ${g}_brainWarp2Tinit $REG -fnirt \"--config=T1_2_MNI152_2mm.cnf --aff=${g}_GM2Tmtx_Jmod.mat --cout=${g}_brainWarp2T_cout\";" >> fslvbm2d
  echo "${FSLDIR}/bin/applywarp --in=${g}_GM --warp=${g}_brainWarp2T_cout --ref=${Tbrain} --out=${g}_GM_to_T_init" >> fslvbm2d
  # echo "${FSLDIR}/bin/fsl_reg ${g}_GM $T ${g}_GM_to_T_init $REG -fnirt \"--config=GM_2_MNI152GM_2mm.cnf --aff=${g}_GM2Tmtx_Jmod.mat\"" >> fslvbm2d
done
chmod a+x fslvbm2d
#fslvbm2d_id=`$FSLDIR/bin/fsl_sub -j $fslvbm2c_id -T $HOWLONG -N fslvbm2d -t ./fslvbm2d`
#echo Running registration to first-pass template: ID=$fslvbm2d_id

### Creation of the GM template by averaging all (or following the template_list for) the GM_nl_0 and GM_xflipped_nl_0 images
cat <<stage_tpl4 > fslvbm2e
#!/bin/sh
if [ -f ../template_list ] ; then
    template_list=\`cat ../template_list\`
    template_list=\`\$FSLDIR/bin/remove_ext \$template_list\`
else
    template_list=\`echo *_struc.* | sed 's/_struc\./\./g'\`
    template_list=\`\$FSLDIR/bin/remove_ext \$template_list | sort -u\`
    echo "WARNING - study-specific template will be created from ALL input data - may not be group-size matched!!!"
fi
for g in \$template_list ; do
    mergelist="\$mergelist \${g}_struc_GM_to_T_init"
done
\$FSLDIR/bin/fslmerge -t template_4D_GM \$mergelist
\$FSLDIR/bin/fslmaths template_4D_GM -Tmean template_GM
\$FSLDIR/bin/fslswapdim template_GM -x y z template_GM_flipped
\$FSLDIR/bin/fslmaths template_GM -add template_GM_flipped -div 2 template_GM
stage_tpl4
chmod +x fslvbm2e
#fslvbm2e_id=`fsl_sub -j $fslvbm2d_id -T 15 -N fslvbm2e ./fslvbm2e`
#echo Creating second-pass template: ID=$fslvbm2e_id

echo "Study-specific template will be created, when complete, check results with:"
echo "fslview struc/template_4D_GM"
echo "and turn on the movie loop to check all subjects, then run:"
echo "fslview " ${FSLDIR}/data/standard/tissuepriors/avg152T1_gray " struc/template_GM"
echo "to check general alignment of mean GM template vs. original standard space template."