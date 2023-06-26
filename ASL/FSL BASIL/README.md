# Processing single-PLD ASL data from OATS and SCS with FSL's BASIL GUI

*Refer to [BASIL website](https://asl-docs.readthedocs.io/en/latest/#) for full content*

## "Input Data" tab

### "Data contents" section
- **Input Image** is the image containing tag-control pairs, or subtracted images between each tag-control pair, in the 4th dimension.
- **Number of PLDs** set to 1, because this particular example is for single-PLD data acquired in MAS, OATS and SCS.
- **Repeats** leave as Fixed.

### "Data order" section
- **Volumes grouped by** option is to specify how data were acquired in *multi-PLD* data. For single-PLD data, select Repeats.
- **Label/Control Pairing** specifies the order of label/control (i.e., label then control, or control or label). See table below for CHeBA data:

| Study                    | OATS Wave 3 Melbourne & Brisbane  |
|---|---|
| ASL flavour              | Pulsed ASL  |
| TI                       | 1.8 sec  |
| Bolus duration           | 0.7 sec  |
| Bolus arrival time       | 0.7 sec  |
| Time per slice (slicedt) | 0.046666666 sec  |
| TR                       | 2.5 sec  |
| TE                       | 11 msec  |
| tag/control order        | tag then control (tc)  |