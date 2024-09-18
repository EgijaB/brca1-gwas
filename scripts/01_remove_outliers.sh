#!/bin/sh
# This script removes the sex outliers from the dataset.

# Define the input and output paths for the PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files
OUTPATH=/folder_containing_your_files/01_CheckSex

# Run PLINK with the following parameters:

plink --noweb --bfile $INPATH/DATA --remove $OUTPATH/sex_outliers.txt --make-bed --out $OUTPATH/DATA