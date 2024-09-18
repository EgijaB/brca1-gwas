#!/bin/sh
# This script performs phasing with EAGLE.
# Phasing refers to the process of determining the haplotype structure of the genetic variants (i.e., identifying which variants are inherited together on the same chromosome). It helps to identify combinations of alleles that are in linkage disequilibrium (LD), improving the accuracy of downstream analyses such as imputation and association studies.

# This command should be executed within the Eagle install directory.
# Define the input and output paths for the VCF files.
# Note: Replace /folder_containing_your_files with the actual path to your VCF files.

INPATH=/folder_containing_your_files/07_Imputation
OUTPATH=/folder_containing_your_files/07_Imputation

for i in $(seq 1 23)
do
./eagle  --vcf $INPATH/DATA_filt_chr${i}.vcf  --geneticMapFile EAGLE/genetic_map_chr${i}_b37.txt  --numThreads=30  --Kpbwt=20000  --outPrefix $OUTPATH/chr${i}_eagle2_phased > log_phasing_chr${i}.txt 2> err_phasing_chr${i}.txt
done
