#!/bin/sh

# This script excludes SNVs not present in autosomes and independent SNCs with MAF >0.1

# Define the input and output paths for the PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files/
OUTPATH=/folder_containing_your_files/04_CheckRelat

plink --noweb --bfile $INPATH/DATA_filt --exclude chr23_26.txt --indep-pairwise 200 5 0.2 --out $OUTPATH/DATA_filt_autoindep
