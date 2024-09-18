#!/bin/sh

# This script removes heterozygosity and inbreeding outliers from PLINK files

# Define the input and output paths for the PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files/
OUTPATH=/folder_containing_your_files/06_CheckHet

plink --noweb --bfile $INPATH/DATA_filt_dupout_hweout --remove $OUTPATH/outliers.txt --make-bed --out $INPATH/DATA_filt_dupout_hweout_hetout