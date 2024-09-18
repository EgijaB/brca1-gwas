#!/bin/sh
# This script extracts AIMs from the PLINK file.

# Define the input and output paths for the PLINK files.
# Note: Replace /folder_containing_your_files with the actual path to your PLINK files.
# All files need to have the same basename (e.g., DATA.bed, DATA.bim, DATA.fam).

INPATH=/folder_containing_your_files/02_Filtered
OUTPATH=/folder_containing_your_files/03_CheckRace


plink --noweb --bfile $INPATH/DATA_filt --extract aim_list.txt --out $OUTPATH/aims --recode
cd $OUTPATH
chmod a+rw *