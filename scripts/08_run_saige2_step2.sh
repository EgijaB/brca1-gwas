#!/bin/bash
# This script performs the association analysis by SAIGE.

# Define the input and output paths for the files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.

# Path to the SAIGE tools and scripts
TOOLSPATH=/folder_containing_installation_files/SAIGE/extdata
# Path to the input files (VCF and csi file)
INPATH=/folder_containing_your_files/07_Imputation
# Path to the output directory
OUTPATH=/folder_containing_your_files/08_GWAS

module load bio/saige/saige-conda

for i in $(seq 1 23)
do
Rscript $TOOLSPATH/step2_SPAtests.R \
        --vcfFile=$INPATH/DATA_imputed_filtered_chr${i}.vcf.gz \
        --vcfFileIndex=$INPATH/DATA_imputed_filtered_chr${i}.vcf.gz.csi \
        --vcfField=DS \
        --chrom=${i} \
        --minMAC=5 \
        --sampleFile=$INPATH/sample_list.txt \
        --GMMATmodelFile=$OUTPATH/DATA.rda \
        --varianceRatioFile=$OUTPATH/DATA.varianceRatio.txt \
        --SAIGEOutputFile=$OUTPATH/DATA_SAIGE_chr${i}.txt \
        --numLinesOutput=2 \
        --IsOutputAFinCaseCtrl=TRUE\
        --LOCO=FALSE

done