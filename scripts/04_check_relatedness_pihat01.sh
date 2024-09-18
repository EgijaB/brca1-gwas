#!/bin/sh

# This script exctracts not pruned SNPs (that are not in high LD) from the PLINK file and checks the relatedness

# Define the input and output paths for your recently updated PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files/
OUTPATH=/folder_containing_your_files/04_CheckRelat


plink --noweb --bfile $INPATH/DATA_filt --extract $OUTPATH/DATA_filt_autoindep.prune.in --genome --min 0.1 --out $OUTPATH/DATA_filt_pihat01

