#!/bin/sh
# This script extracts information about chromosome, position, reference allele, alternate allele, DR2, and allele frequency (AF) into `info_chr${i}.txt` files. It then calculates the total number of SNVs imputed and evaluates their quality based on DR2 and AF thresholds.

# Define the input and output paths for the VCF files.
# Note: Replace /folder_containing_your_files with the actual path to your VCF files.

INPATH=/folder_containing_your_files/07_Imputation
OUTPATH=/folder_containing_your_files/07_Imputation

# Prepare the output file and write the header
echo -e "Chromosome\tTotal_SNVS\tDR2>0.4\tDR2>0.8\tAF>0.01\tDR2>0.8_and_AF>0.01" > $OUTPATH/imp_QC.txt

# Loop through chromosomes 1 to 23
for i in $(seq 1 23)
do
  # Extract information about chromosome, position, ref, alt, DR2, and AF into info_chr${i}.txt
  bcftools query -f '%CHROM %POS %REF %ALT %INFO/DR2 %INFO/AF\n' $INPATH/DATA_imputed_chr${i}.vcf.gz > $OUTPATH/info_chr${i}.txt
  
  # Count the total number of SNVs
  total_snvs=$(wc -l < $OUTPATH/info_chr${i}.txt)
  
  # Count SNVs with DR2 > 0.4, DR2 > 0.8, AF > 0.01, and both DR2 > 0.8 and AF > 0.01
  dr2_04=$(awk '{if($5>0.4){print}}' $OUTPATH/info_chr${i}.txt | wc -l)
  dr2_08=$(awk '{if($5>0.8){print}}' $OUTPATH/info_chr${i}.txt | wc -l)
  af_001=$(awk '{if($6>0.01){print}}' $OUTPATH/info_chr${i}.txt | wc -l)
  dr2_08_af_001=$(awk '{if($6>0.01 && $5>0.8){print}}' $OUTPATH/info_chr${i}.txt | wc -l)
  
  # Output results to the QC file
  echo -e "chr${i}\t$total_snvs\t$dr2_04\t$dr2_08\t$af_001\t$dr2_08_af_001" >> $OUTPATH/imp_QC.txt
done