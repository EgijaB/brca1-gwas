#!/bin/sh

# This script performs the HWE test to identify SNVs that deviate from HWE

# Define the input and output paths for the PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files/04_CheckRelat
OUTPATH=/folder_containing_your_files/05_CheckHWE


plink --noweb --bfile $INPATH/DATA_filt_dupout --exclude $OUTPATH/hwe_outliers.txt --make-bed --out $OUTPATH/DATA_filt_dupout_hweout