* load patient-level raw data
insheet using "person202105.csv", clear

** the following section clean missing data fields and renames columns 
 replace gender="" if gender=="Unknown"
 gen sex=gender
 drop gender
 replace race="" if race=="Unknown"
 replace ethnicity="" if ethnicity=="Unknown"
* languages are all NAs
 drop language
* relifion are all NAs
 drop religion
* marital_status are all NAs
 drop marital_status
* education are all NAs
 drop education
* employment are all NAs
 drop employment
* payer_group are all NAs
 drop payer_group
* tract are all NAs
 drop tract
* Age at the start of the study period (2015)
 gen age_cat=age-4
 replace age_cat=1 if age_cat<25 
 replace age_cat=2 if age_cat>24 & age_cat<35 
 replace age_cat=3 if age_cat>34 & age_cat<45 
 replace age_cat=4 if age_cat>44 & age_cat<55 
 replace age_cat=6 if age_cat>54 & age_cat<65
 replace age_cat=7 if age_cat>64 & age_cat<75
 replace age_cat=8 if age_cat>74 & age_cat<85
 replace age_cat=9 if age_cat>84 & age_cat~=. 
 la de l_age_cat 1 "18-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65-74" 7 "65-74" 8 "75-84" 9 "85+"
 la val age_cat l_age_cat
 la var age_cat "Age categories"
 gen race_eth=.
 * NH White
 recode race_eth .=1 if ethnicity=="Not Hispanic or Latino" & race=="White" 
 * NH Asian
 recode race_eth .=2 if ethnicity=="Not Hispanic or Latino" & race=="Asian" 
 * NH Black
 recode race_eth .=3 if ethnicity=="Not Hispanic or Latino" & race=="Black or African American" 
 * NH Native Hawaiian of Other Pacific Islander
 recode race_eth .=4 if ethnicity=="Not Hispanic or Latino" & race=="Native Hawaiian or Other Pacific Islander" 
 * NH American Indian or Alaska Native"
 recode race_eth .=5 if ethnicity=="Not Hispanic or Latino" & race=="American Indian or Alaska Native" 
 * NH Multiple races
 recode race_eth .=6 if ethnicity=="Not Hispanic or Latino" & race=="Multiple races" 
 * Hispanic
 recode race_eth .=7 if ethnicity=="Hispanic or Latino" 
 la de l_race_eth 1 "N-H White" 2 "N-H Asian" 3 "N-H Black" 4 "N-H Native Hawaiian or Other Pacific Islander" 5 "N-H American Indian or Alaska Native" 6 "N-H Multiple Race" 7 "Hispanic"
 la val race_eth l_race_eth
 la var race_eth "Race/ethnicity"
*drop original variables that were 'cleaned' to create cleaned data set
drop race ethnicity zip source

* save processed patient-level dataset
save person202105_cleaned, replace
export delimited using "person202105_cleaned.csv", replace
************************************************

* load visit-level raw data 
 insheet using "services_202105.csv", clear
 keep if source==2
 gen date=date(service_date, "MDY") 
 gen year=year(date)
 ta year, m
* save processed visit-level dataset
 export delimited using "services_202105.csv", replace
************************************************

** the following section clean clinical variables and create 
* Cleaning clinical variables  
* Create person-level summary variables

*Running visit number per patient
sort study_id date
bysort study_id: gen visit = _n
*Total visits per patient
bysort study_id: egen total_visits = max(visit)
*Grouping by person by year 
egen id_year = group(study_id year)
*Indicator for visit year
forvalues x=15/19 {
gen visit`x' = (year==20`x')
}
*Number of visits per patient per year
forvalues x=15/19 {
bysort study_id: egen n_visits`x' = total(visit`x')
}
*Any diagnosis of depression, whole study
gen any_dep= (doc_type1==1 | doc_type2==1 |doc_type3==1) 
*Indicator for depression diagnosis year
forvalues x=15/19 {
gen dep`x'= (any_dep==1 & year==20`x')
}
*Number of depression diagnoses
forvalues x=15/19 {
bysort study_id: egen n_dep_`x' = total(dep`x')
gen any_dep_`x' = 0
bysort study_id: replace any_dep_`x' =1 if n_dep_`x'>0 & n_dep_`x'!=.
}
gen n_dep= n_dep_15+n_dep_16+n_dep_17+n_dep_18+n_dep_19
la var n_dep "Number of visits with depression diagnosis"

 
* Create hierarchy of Charlson Dx
 gen doc_ch_diab=.
 recode doc_ch_diab .=0 if doc_ch_diabwcc==0 & doc_ch_diabwocc==0
 recode doc_ch_diab .=2 if doc_ch_diabwcc==1
 recode doc_ch_diab .=1 if doc_ch_diabwcc==0 & doc_ch_diabwocc==1
 
 gen doc_ch_liver=.
 recode doc_ch_liver .=0 if doc_ch_liver_severe==0 & doc_ch_liver_mild==0
 recode doc_ch_liver .=3 if doc_ch_liver_severe==1
 recode doc_ch_liver .=1 if doc_ch_liver_severe==0 & doc_ch_liver_mild==1
 
 gen doc_ch_neoplasia=.
 recode doc_ch_neoplasia .=0 if doc_ch_tumor==0 & doc_ch_cancer==0
 recode doc_ch_neoplasia .=6 if doc_ch_tumor==1
 recode doc_ch_neoplasia .=2 if doc_ch_tumor==0 & doc_ch_cancer==1
 
* Create weighted Charlson score by service date
 gen charlson= 6*(doc_ch_hiv)+ 2*(doc_ch_hemiplegia + doc_ch_renal) + (doc_ch_cvd + doc_ch_chf + doc_ch_cpd + doc_ch_dementia + doc_ch_mi + doc_ch_ulcer + doc_ch_pvd + doc_ch_rheumatic) + (doc_ch_diab + doc_ch_liver + doc_ch_neoplasia)
* Take highest service date Charlson score per patient per year
 forvalues x=15/19 {
 bysort study_id: egen max_ch_`x' = max(charlson) if year==20`x'
}
* Take highest Charlson score per patient over the study period
 bysort study_id: egen max_charlson = max(charlson)
* Any cancer during study period
 gen any_cancer = 0
 bysort study_id: replace any_cancer =1 if sum(doc_ch_neoplasia)>0 & sum(doc_ch_neoplasia)!=.


*PHENOTYPING: Obesity
* Create "real" pregnancy variable, and rename 'pregnancy_status' as reproductive status
 gen preg=0
 recode preg 0=1 if dx_preg==1
* Create non-pregnant obese flag  
  gen obese_np =0 
  recode obese_np 0=1 if doc_obese==1 & preg==0 
  la var obese_np "Obesity status (not pregnant)"
* Clean BMI data
 sort study_id date
 gen bmiclean=.
 replace bmiclean=bmi if bmi<80 & bmi>10 & preg==0 // "conservative" cut offs for plausible values, NCD-RisC Nature paper

 gen bmi_cat=.
 recode bmi_cat .=1 if bmiclean<18.5 & preg==0
 recode bmi_cat .=2 if bmiclean>=18.5 & bmiclean<25 & preg==0
 recode bmi_cat .=3 if bmiclean>=25 & bmiclean<30 & preg==0
 recode bmi_cat .=4 if bmiclean>=30 & bmiclean<35 & preg==0
 recode bmi_cat .=5 if bmiclean>=35 & bmiclean<40 & preg==0
 recode bmi_cat .=6 if bmiclean>=40 & bmiclean~=. & preg==0
 la de l_bmi_cat 1 "<18.5" 2 "18.5 - 24.9" 3 "25.0 - 29.9" 4 "30.0 - 34.9" /// 
 5 "35.0 - 39.9" 6 "≥40.0" 
 la val bmi_cat l_bmi_cat
 ta bmi_cat, m

 bysort study_id: egen maxbmi_np= max(bmiclean)
 bysort study_id: egen minbmi_np= min(bmiclean)
 bysort study_id: egen medbmi_np= median(bmiclean)

*************************
export delimited using "preprocessed_df.csv", replace 
*************************

