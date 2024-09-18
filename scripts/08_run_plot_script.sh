#!/bin/bash
# This script loads the R and runs the script 08_plot_script.R.

INPATH=/folder_containing_your_files/08_GWAS

module load R/R-3.4
R --vanilla --slave --args input=$INPATH/DATA_SAIGE_combined.txt < $INPATH/08_plot_script.R