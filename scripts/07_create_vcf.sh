#!/bin/sh
# This script creates a vcf file for each chromosome seperately from PLINK files.

# Define the input and output paths for the PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files/06_CheckHet
OUTPATH=/folder_containing_your_files/07_Imputation

for i in {1..23}
do
plink --bfile $INPATH/DATA_filt --recode vcf-iid --chr ${i} --out $OUTPATH/DATA_filt_chr${i} --snps-only no-DI
done
