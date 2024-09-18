#!/bin/sh
# This script filters SNVs with MAF < 0.01 and DR2 < 0.8 from the imputed VCF files (DATA_imputed_chr${i}.vcf.gz).
# It will create filtered VCF files with only high-quality variants.

# Define the input and output paths for the VCF files.
# Note: Replace /folder_containing_your_files with the actual path to your VCF files.

INPATH=/folder_containing_your_files/07_Imputation
OUTPATH=/folder_containing_your_files/07_Imputation


for i in $(seq 1 23)
do
bcftools view -i 'INFO/AF>=0.01 && INFO/DR2>=0.8' $INPATH/DATA_imputed_chr${i}.vcf.gz -Oz -o $OUTPATH/DATA_imputed_filtered_chr${i}.vcf.gz
# Index the filtered VCF file
bcftools index $OUTPATH/DATA_imputed_filtered_chr${i}.vcf.gz
done

