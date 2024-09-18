#!/bin/sh
# This script performs a sex check on PLINK files and sets appropriate permissions on the output files.

# Define the input and output paths for the PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files
OUTPATH=/folder_containing_your_files/01_CheckSex

# Run PLINK with the following parameters:

plink --noweb --bfile $INPATH/DATA --maf 0.1 --check-sex --out $OUTPATH/DATA
cd $OUTPATH
chmod a+rw *