# Original study data

The original study data can be downloaded from [this link](https://ida.loni.usc.edu/pages/access/studyData.jsp?project=ADNI).


# Sources to find all ADNI ASL scans


# Changes to UCSFASLQC.csv

- Replace <code>newline",</code> with <code>",</code>.
- Replace <code>"space</code> with <code>"</code>.
- Replace <code>space"</code> with <code>"</code>.
- Remove all <code>"</code>.
- Replace <code>,space</code> with <code>.space</code>.
- Replace <code>semicolon</code> with <code>period</code>.
- Replace <code>space--space</code> with <code>period</code>.
- Replace <code>.space</code> with <code>period</code>.

The modified file is saved as <code>UCSFASLQC_Jmod.csv</code>.

The following shell command was then ran to remove columns after QC date, as there are always issues with QC comments and they are not required.

<code>awk -F',' '{print $1,$2,$3,$4,$5}' UCSFASLQC_Jmod.csv | sed 's/ /,/g' > UCSFASLQC_Jmod2.csv</code>


# Changes to ADNIMERGE.csv

- Remove all <code>"</code>.
- Replace <code>/</code> with <code>underscore</code>.

The modified file is saved as <code>ADNIMERGE_Jmod.csv</code>.
