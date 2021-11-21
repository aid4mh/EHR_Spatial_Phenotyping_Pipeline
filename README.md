This is a code pipeline for EHR-based geospatial analysis pipeline incorporates a metric for assessing spatial representativeness, data-driven selection of regional areas for geospatial-phenotyping, and bias-adjusted spatial analysis to detect spatial patterns in cohorts with conditions of interest.  

![pipeline image](/Images/analysis_pipeline.png)

If you have any question about the codes, please direct your email to Jinchen Xie: jinchenx\@uw.edu

## Main files
**ESPP_preprocess.do**: Stata Script to pre-process the raw datasets. Clean and prepare all needed information and merge the patient-level dataset with the visit-level dataset. This script should be modified based on your raw dataset(s) (e.g. which columns are extracted). The output need to be at visit-level and contain cleaned data fields.

**ESPP_load_data.R**: Script to load needed datasets to R environment.  

**ESPP_phenotypes.R**: Script to process and generate 'depressed' and 'obese' phenotype labels. The labels will help us to identify cohort of interests. The final output dataset is at patient-level.      

**ESPP_EHRzip.R**: Script to merge zcta to patient data and aggregate patients' information to ZCTA-level.   

**ESPP_selection_adjustment.R**: Script for using Spatial Representation Ratio to select a smaller areas for analysis, and applying Empirical-Bayes adjustment.   

**ESPP_spatial_analysis.md**: This is a markdown file describing steps to be taken in GeoDa.  

## Data Preparation
Based on our EHR extraction methods, we started with two EHR-based data sets: one patient-level data (i.e. one unique patient per row), and one visit-level data (i.e. one unique clinical visit per row).

External dataset contain shape files of ZCTA boundaries of Washington state and underlying population estimates of each ZCTA in WA: https://geo.wa.gov/datasets/wa-ofm::waofm-saep-population-estimates-wfl1/explore?layer=9  
External dataset to map ZIP Codes to ZCTA can be found here: https://udsmapper.org/zip-code-to-zcta-crosswalk/  
External dataset to map ZCTA to County can be found here:
https://data.sandiegodata.org/dataset/census-gov-zcta-county/   

## R Package Dependencies:  
readxl  
tidyverse  
ebbr  (install by 'devtools::install_github("dgrtwo/ebbr")')
