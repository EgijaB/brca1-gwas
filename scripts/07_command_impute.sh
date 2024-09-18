#!/bin/sh
# This script performs genotype imputation with BEAGLE.
# Imputation refers to predicting missing genotypes using a reference panel, improving genotype resolution for downstream analyses such as GWAS.

# Ensure this script is executed in the directory where phased files are located (e.g., /folder_containing_your_files/07_Imputation).
# Tags -Xss100g and -Xmx190g determine how muxh computational resources will be used

for i in $(seq 1 23)
do
java -Xss100g -Xmx190g -jar beagle.18May20.d20.jar gt=chr${i}_eagle2_phased.vcf.gz ref=BEAGLE/reference_chr${i}.vcf.gz map=BEAGLE/plink.chr$i.GRCh37.map out=DATA_imputed_chr$i nthreads=4 ne=20000 chrom=${i} gp=true 1> imp_log_chr${i}.txt 2> imp_err_chr${i}.txt
done
