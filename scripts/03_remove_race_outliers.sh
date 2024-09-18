#!/bin/sh
# This script removes the race outliers from the dataset.

# Define the input and output paths for the PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files/02_Filtered
OUTPATH=/folder_containing_your_files/03_CheckRace

# Run PLINK with the following parameters:

plink --noweb --bfile $INPATH/DATA_filt --remove $OUTPATH/race_outliers.txt --make-bed --out $OUTPATH/DATA_filt