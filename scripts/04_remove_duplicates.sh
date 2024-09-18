#!/bin/sh

# This script removes the duplicates

# Define the input and output paths for your recently updated PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files/04_CheckRelat
OUTPATH=/folder_containing_your_files/04_CheckRelat


plink --noweb --bfile $INPATH/DATA_filt --remove $INPATH/duplicates.txt --make-bed --out $OUTPATH/DATA_filt_dupout
