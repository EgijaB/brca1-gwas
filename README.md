# Explanation of Analysis

We have provided scripts for performing basic quality control (QC) analysis and filtering for Illumina OncoArray-500K BeadChip data exported from GenomeStudio in PLINK format. This is followed by imputation, post-imputation QC, GWAS analysis using R package SAIGE [PMID: 2701847](https://pubmed.ncbi.nlm.nih.gov/27018471/), and PRS calculations.

Many scripts include comments that explain their functionality. You can use these scripts for your own data analysis by replacing the name of the `DATA` file with the name of your own data file. Note that this script is based on a binary outcome measure and is not applicable for quantitative outcome measures.

All scripts used in this analysis are executed from the Unix command line. Thus, this analysis can be completed by following the steps from this file. A modified genotype QC process was followed for our dataset, which has been described in detail elsewhere [PMID: 25321409](https://pubmed.ncbi.nlm.nih.gov/25321409/).

## Start Analysis

Change directory to the folder on your UNIX device containing all PLINK files.

```sh
cd PATH/folder_containing_your_files
```

For subsequent analysis, we used single nucleotide variant (SNV) positions from the human reference genome assembly GRCh37/hg19. All variants were changed from the TOP strand to the hg19 plus strand using the `GSAMD-24v1-0_20011747_A1-b37.strand.RefAlt.zip` files, which can be found at [Wellcome Trust](https://www.well.ox.ac.uk/~wrayner/strand/).


### Step 1: Check for Gender Mismatches

1. To check for gender mismatches between reported and genotype-based data, the inbreeding estimates for the X chromosome were calculated using the PLINK command `--check-sex`. Individuals were called as females and remained in the study dataset if an inbreeding estimate was **<0.2**. Calcucate an inbreeding estimates by running the script `01_check_sex.sh`.

```sh
./01_check_sex.sh
```

2. Create a `sex_outliers.txt` file from the output file `DATA.sexcheck`, which contains inbreeding estimates in the  **F** column and flags outliers in the  **STATUS** column (marked as PROBLEM). The `sex_outliers.txt` file should include only the FID and IID columns, without headers. Once created, remove these outliers by running the `01_remove_outliers.sh` script.

```sh
./01_remove_outliers.sh
```

### Step 2: Filter Individuals and SNVs

This step removes individuals with a missing genotype rate higher than 5%, SNVs with a missing genotype rate higher than 5%, and SNVs with a minor allele frequency (MAF) less than 1%. For filtering run the script `02_filtering.sh`.

```sh
./02_filtering.sh
```

### Step 3: Check for Race Mismatch by Principal Component (PC) Analysis

Ancestry was calculated using a PC analysis by EIGENSOFT software package [PMID: 16862161](https://pubmed.ncbi.nlm.nih.gov/16862161/). To calculate PCs, the 788 ancestry informative markers (AIMs) from Illumina were applied. We have provided the list of AIMs as a text file `aim_list.txt`. Both `convertf` and `smartpca.perl` are scripts that come with the EIGENSOFT package.

1. Extract AIMs from the PLINK file by running the scipt `03_extract_aims.sh`.

```sh
./03_extract_aims.sh
```

2. Convert the PLINK file to EIGENSTRAT format by running the following command, where `par.ped.eigenstrat` is a parameter file that is already provided. If necessary, you can modify the `par.ped.eigenstrat` file.

 ```sh
convertf -p par.ped.eigenstrat > eigen.log
```

3. Perform PCA analysis.  
Use the three files produced in the previous step (`aims.geno`, `aims.SNP`, and `aims.ind`) to perform the PCA analysis by running the following command:

```sh
perl smartpca.perl -i aims.geno -a aims.snp -b aims.ind -o aims.pca -m 10 -p aims.plot -e aims.eval -l aims.log
```

*The parameter -m 10 specifies the maximum number of principal components (PCs) to compute (in this case, 10 PCs).*

4. Create a PCA table.  
Next, create a table that can be used for drawing a PCA plot by running the R script `03_pca_plot.R`.

```sh
Rscript 03_pca_plot.R aims.pca.evec
```

*The input `aims.pca.evec` is the output of the previous command, and the resulting table is saved as `aims.pca.evec.csv`.*

5. Inspect PCA results.  
Now you can create and inspect the PCA plots and review the PCA log `aims.log` for indications of outliers. Outliers may appear as individuals far from the main cluster in the PCA plot or have extreme values in the PCs. Depending on the results of PCA and association testing, you may decide to exclude outliers from further analysis manually based on criteria such as distance from the main cluster in PCA plots or statistical considerations. In this analysis, we have set the threshold for race mismatch to > mean ±6 standard deviations (SD).

6. If you have detected outliers that you would like to remove, create a `race_outliers.txt` file that should include only the FID and IID columns, without headers. Once created, remove these outliers by running the `03_remove_race_outliers.sh` script:

```sh
./03_remove_race_outliers.sh
```

### Step 4: Relatedness and Probable Duplicates Identification

Pair-wise identity by descent (IBD) calculation was used to identify relatedness and probable duplicates. Since IBD calculations do not account for linkage disequilibrium (LD), an LD pruning step was performed. LD pruning enhances marker independence by filtering out variants in strong LD. In this study, we used specific parameters for LD pruning:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Window size:** 200 variants  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Step size:** 5 variants  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Pairwise r<sup>2</sup> threshold:** 0.2  

During this process, pairs of variants in the current window with a squared correlation greater than the threshold were identified at each step. Variants were pruned until no highly correlated pairs remained. The final dataset retained relatives but excluded probable duplicates with `PI_HAT value` close to 1 from subsequent analysis.
    
1. Exclude mitochondrial and sex chromosomes to prepare LD-pruned dataset.  
Use the `--indep-pairwise` option and provided file `chr23_26.txt` for LD-based SNP pruning by running the `04_autoindep_final.sh` script. `chr23_26.txt` is a text file that contains a list of SNVs from chromosomes X, Y, XY and from mitochondria.

```sh
./04_autoindep_final.sh
```

2. Check the relatedness of the remaining SNVs.  
To check relatedness and possible duplicates with remaining SNVs, use the `04_check_relatedness_pihat01.sh` script.

```sh
./04_check_relatedness_pihat01.sh
```

As the focus of GWAS analysis is to identify extended haplotypes shared between distantly related individuals, the presence of very closely related individuals (e.g., siblings, first cousins) could influence the results. This will be corrected using the appropriate GWAS analysis method `SAIGE`. Therefore, only duplicates were removed from our dataset.

3. To remove duplicates create a list `duplicates.txt` and run the `04_remove_duplicates.sh` script.

 ```sh
./04_remove_duplicates.sh
```

### Step 5: Hardy-Weinberg equilibrium (HWE) Outlier Identification
The HWE test was performed to identify SNVs that deviate from HWE (p < 1 × 10<sup>-7</sup> for unaffected individuals and p < 1 × 10<sup>-12</sup> for cases) using the PLINK function `--hardy`.
    
1. Perform HWE test.  
Perform the HWE test to identify SNVs that deviate from HWE running script `05_perform_hwe_test.sh`.

```sh
./05_perform_hwe_test.sh
```

This command will generate a file `DATA_filt_dupout_hwe.hwe` that will be used to examine the *p* values in next step. Additionally, the parameter `--maf 0.05` ensures that the HWE test is performed only on SNVs with MAF >0.05, because the HWE test is not appropriate for rare variants.
   
2. Examine and plot HWE outliers.  
Examine the *p* values in the last column of `DATA_filt_dupout_hwe.hwe` by plotting them using the `05_PlotHWE.R` script.

```sh
RScript 05_PlotHWE.R DATA_filt_dupout_hwe.hwe
```

3. Exclude the HWE outliers.  
Create a list of outliers `hwe_outliers.txt` that deviate from HWE (*p* < 1 × 10<sup>-7</sup> for unaffected individuals and *p* < 1 × 10<sup>-12</sup> for cases), and exclude then from the dataset by running the script `05_remove_hwe_outliers.sh`.

### Step 6: Heterozygosity and Inbreeding Outlier Identification
This step was perfomed to idetify samples with extreme heterozygosity (deviation ±4.89 SD from the mean rate of samples’ heterozygosity) and inbreeding coefficient ( > 0.1), which were excluded from the dataset.

1. Calculate the inbreeding coefficient.  
Compute the inbreeding coefficient running the following script `06_compute_inbr.sh`.

```sh
./06_compute_inbr.sh
```

The file `DATA_filt_autoindep.prune.in` was produced previously during the step 4. This command produces an `DATA.het` file, in which the sixth column in the inbreeding coefficient *F*.

2. Compute heterozygosity and draw histograms.  
Compute heterozygosity and draw histograms of heterozygosity and inbreeding coefficient *F* by running the `06_PlotHeterozygosity.R` script.

```sh
RScript 06_PlotHeterozygosity.R DATA.het
```

This script generates two figures `DATA.heterozygosity.jpg` and `DATA.F.jpg` that can be examined to identify outliers.

3. Generate the list of outliers.  
To generate the list of heterozygosity outliers (that deviate ±4.89 SD from the mean rate of samples’ heterozygosity) run following `06_het_inbr_outliers_list.R` script.

```sh
RScript 06_het_outliers_list.R
```

The file `fail-het-qc.txt` will be genrate that contains the heterozygosity outliers. Create `outliers.txt` file from `fail-het-qc.txt` to contain only FID and IID columns seperated by Tab. Inspect the inbreeding coefficient in `DATA.het` file, and add to the `outliers.txt` file samples with inbreeding coefficient > 0.1.

4. Remove outliers.  
To remove outliers run the script `06_remove_het_inbr_outliers.sh`.

```sh
./06_remove_het_inbr_outliers.sh
```

### Step 7: Perform an Imputation of Missing Genotypes.
To perform the imputation, additional SNVs with **MAF < 0.01** were excluded. Missing genotypes should be imputed using a reference panel. In our study, we used the Estonian population-based high-coverage whole genome sequencing (WGS) dataset (N = 2244) as the reference panel, as described in [PMID: 28401899](https://pubmed.ncbi.nlm.nih.gov/28401899/).
We implemented a two-stage imputation approach:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Phasing with EAGLE [PMID: 27270109](https://pubmed.ncbi.nlm.nih.gov/27270109/)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Imputation with BEAGLE [PMID: 30100085](https://pubmed.ncbi.nlm.nih.gov/30100085/)  

Post-imputation QC should be done by excluding SNVs with **MAF < 0.01** and dosage R-squared **(DR<sup>2</sup>) < 0.8**.

1. Create VCF files for each chromosome seperately from PLINK files (`.bed`, `.bim`, and `.fam`) using the script `07_create_vcf.sh`.

```sh
./07_create_vcf.sh
```

*Note: Indels cannot be imputed, so they are removed in this step by using the `--snps-only no-DI` tag.*

2. Perform data phasing using EAGLE v2.3 [PMID: 27270109](https://pubmed.ncbi.nlm.nih.gov/27270109/). The input files are the VCF files created in the previous step. Run the phasing using the script `07_command_phasing.sh`.

```sh
./07_command_phasing.sh
```

*Note: Files genetic_map_chr${i}_b37.txt contain columns: chr/position/COMBINED_rate(cM/Mb)/Genetic_Map(cM) and can be downloaded along with the software.*

3. Perform imputation using the reference panel and BEAGLE [PMID: 30100085](https://pubmed.ncbi.nlm.nih.gov/30100085/). To perform this step, run the script `07_command_impute.sh`.

```sh
./07_command_impute.sh
```

4. Perform  post-imputation QC to assess DR2 scores and determine how many common variants are present in your imputed dataset. First, extract information about chromosome, position, reference allele, alternate allele, DR2, and allele frequency into `info_chr${i}.txt` files. Then calculate how many SNVs were imputed and evaluate their quality using the `07_post_imputation_QC.sh` script.

```sh
./07_post_imputation_QC.sh
```

5. Finally filter SNVs with **MAF < 0.01** and **DR2 < 0.8** using the script `07_filtering.sh`.

```sh
./07_filtering.sh
```

### Step 8: Perform GWAS Analysis Using the R package SAIGE.
To conduct the association analysis, we will use the R package SAIGE v0.38 [PMID: 27018471](https://pubmed.ncbi.nlm.nih.gov/27018471/) with R v4.0.2. SAIGE implements a mixed logistic regression model, adjusting for relatedness, the first 4 PCs, age at recruitment/disease onset, and type of BRCA1 pathogenic variant (variables can be modified). Adjusting for relatedness helps minimize the risk of false positive associations by ensuring that the genetic variants tested are genuinely associated with the outcomes, rather than being confounded by familial relationships.
The mixed logistic regression model, along with adjustments for relatedness and other covariates, helps control for potential sources of bias and provides more reliable results.

1. Begin by loading the SAIGE module on the HPC server:

```sh
module load bio/saige/saige-conda
```

2. Then calculate the kinship matrix using the script `08_run_saige_step1.sh`.

```sh
./08_run_saige_step1.sh
```

*Note: `pheno_file.txt` should contain the following columns: `IID`, `PC1`, `PC2`, `PC3`, `PC4`, `gender`, `age`,	`status`, `brca1var`. This script calculates two files that will be needed for step 2 of the SAIGE analysis (`.rda` and `.varianceRatio.txt`).*

3. Proceed with step 2 of the SAIGE analysis by running the script `08_run_saige_step2.sh`.

```sh
./08_run_saige2_step2.sh
```

*Note: File `sample_list.txt` should contain the list of sample names from `IID` column that will be analysed.*

4. To combine all the chromosome-specific SAIGE results into one file, run the following command:

```sh
# Extract the header from the first chromosome file
grep SNPID DATA_SAIGE_chr1.txt > DATA_SAIGE_combined.txt
# Append data from all other chromosome files, excluding the header
grep -v -h SNPID DATA_SAIGE_chr*.txt >> DATA_SAIGE_combined.txt
```

5. To create Manhattan and QQ plots, use the 08_plot_script.R script. Submit the plotting script running the following script 08_run_plot_script.sh.

```sh
./08_run_plot_script.sh
```

### Step 9. Perform Polygenic Risk Score (PRS) Calculations
In this study, we calculated Polygenic Risk Scores (PRS) using data from 2,174,072 SNVs present in both the UK Biobank and Estonian Biobank participants. The PRS were developed using data from 428,747 UK Biobank individuals and 105,000 Estonian Genome Centre participants as detailed in [PMID: 35905320](https://pubmed.ncbi.nlm.nih.gov/35905320/). Summaries of the PRS used are available on [Dryad](https://datadryad.org/stash/dataset/doi:10.5061/dryad.gtht76hmz#citations).

For PRS calculations, we used the PLINK v2.00 function `--score`.

The files named JointAssoc_${cancerSite}_${method} contain information on the 2,174,072 SNVs that are found in both the UK and Estonian Biobanks. The columns in the file are:
- CHR : chromosome
- SNP : SNP rsID
- A1 : effect allele
- A2 : other allele
- MEAN : mean effect size (to be used as the SNP weight in PRS calculation)
- SE : standard error of the effect size
- PIP : posterior inclusion probability (a Bayesian measure indicating the likelihood that a SNP has an effect, with higher values signifying higher significance)

Notes: Since this model is not a marginal GWAS model, the effect size estimates and standard deviations are not directly comparable to outputs from marginal GWAS models. A high PIP (>0.5) indicates the significance of a marker, but due to LD, the effect of a causal marker may be spread across multiple SNVs, resulting in lower PIP values. To account for this, grouping loci for significance teting is recommended.

1. Begin by creating a `pgen` file from the imputed and merged VCF file (DATA_imputed_filtered_merged.vcf.gz):

```sh
plink2 --vcf DATA_imputed_filtered_merged.vcf.gz --const-fid --maf 0.001 --make-pgen --out DATA_imputed_filtered_merged
```

2. Unzip the Joint models:

```sh
tar -xvf JointAssoc_Ovary_bR.tar.gz
tar -xvf JointAssoc_Ovary_bW.tar.gz
tar -xvf JointAssoc_Breast_bW.tar.gz
tar -xvf JointAssoc_Breast_bR.tar.gz
```

3. Calculate PRS for each cancer site:

```sh
plink2 --pfile DATA_imputed_filtered_merged --score JointAssoc_Breast_bR.txt cols=+scoresums 2 4 5 --out Breast_bR
plink2 --pfile DATA_imputed_filtered_merged --score JointAssoc_Breast_bW.txt cols=+scoresums 2 4 5 --out Breast_bW
plink2 --pfile DATA_imputed_filtered_merged --score JointAssoc_Ovary_bW.txt cols=+scoresums 2 4 5 --out Ovary_bW
plink2 --pfile DATA_imputed_filtered_merged --score JointAssoc_Ovary_bR.txt cols=+scoresums 2 4 5 --out Ovary_bR
```

4. Finally The association between PRS and the presence of BC and/or OC can be evaluated by using a binomial logistic regression model or other statistical methods.
