#!/bin/bash
# This script calculates the kinship matrix needed for the following step in the SAIGE analysis.

# Define the input and output paths for the files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.

# Path to the SAIGE tools and scripts
TOOLSPATH=/folder_containing_installation_files/SAIGE/extdata
# Path to the input files (PLINK and phenotype file)
INPATH=/folder_containing_your_files/06_CheckHet
# Path to the output directory
OUTPATH=/folder_containing_your_files/08_GWAS


Rscript $TOOLSPATH/step1_fitNULLGLMM.R \
        --plinkFile=$INPATH/DATA_filt \
        --phenoFile=$INPATH/pheno_file.txt \
        --phenoCol=status \
        --covarColList=brca1var,age,PC1,PC2,PC3,PC4 \
        --sampleIDColinphenoFile=IID \
        --traitType=binary        \
        --outputPrefix=$OUTPATH/DATA \
        --nThreads=4 \
        --LOCO=TRUE