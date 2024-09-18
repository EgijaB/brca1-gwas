#!/bin/sh
# This script filters individuals removes individuals with a missing genotype rate higher than 5%, and SNVs with a missing genotype rate higher than 5%, and SNVs with a minor allele frequency (MAF) less than 1%.

# Define the input and output paths for the PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files/01_CheckSex
OUTPATH=/folder_containing_your_files/02_Filtered


plink --noweb --bfile $INPATH/DATA --mind 0.05 --geno 0.05 --maf 0.01 --make-bed --out $OUTPATH/DATA_filt