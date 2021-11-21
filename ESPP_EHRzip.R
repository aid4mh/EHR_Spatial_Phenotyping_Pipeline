# Removed Missing zipcode
person_complete <- subset(person, !is.na(person$zip_recoded))

# Merge patient data with zip code and ZCTA data
person_zip <- left_join(person_complete, zip_to_zcta, by = c("zip_recoded" = "ZIP_CODE"), copy = FALSE, suffix = c(".x", ".y"))
person_complete <- subset(person_zip, !is.na(person_zip$ZCTA))
names(person_complete)[names(person_complete) == "ZCTA"] <- "zcta"
rm(person, person_zip)

# Create control, dep-only, obese-only labels
# Create "control" variable= not obese and not depressed
person_complete <- person_complete %>% 
  mutate(control= case_when(
    depressed==0 & obese_np==0 ~ 1,
    depressed==1 | obese_np==1 ~ 0)) 

person_complete <- person_complete %>% 
  mutate(dep_only=0) %>% 
  mutate(dep_only= ifelse((depressed==1&depob==0),1,dep_only)) 

person_complete <- person_complete %>% 
  mutate(obese_only=0) %>% 
  mutate(obese_only= ifelse((obese_np==1&depob==0),1,obese_only)) 

# Summarize at the zip level
persons_zips<- person_complete %>%
  group_by(zcta) %>%
  dplyr::summarise(n_zctas= n(),   # how many patients in the zcta
                   pop_zctas= mean(POP2020),
                   mean_age_zips= mean(age),
                   n_dep= n_distinct(study_id[depressed==1]),
                   prop_dep=n_dep/n_zctas,
                   n_ob= n_distinct(study_id[obese_np==1]),
                   prop_ob=n_ob/n_zctas,
                   n_depob= n_distinct(study_id[depob==1]),
                   prop_depopb=n_depob/n_zctas,
                   n_control= n_distinct(study_id[control==1]),
                   prop_control=n_control/n_zctas,
                   n_fem= n_distinct(study_id[sex=="Female"]),
                   prop_fem=n_fem/n_zctas,
                   n_nhwhite= n_distinct(study_id[race_eth=="N-H White"]),
                   prop_nhwhite=n_nhwhite/n_zctas,
                   n_hisp= n_distinct(study_id[race_eth=="Hispanic"]),
                   prop_hisp= n_hisp/n_zctas,
                   n_unempl= n_distinct(study_id[employment=="Not Employed"]),
                   prop_unempl=n_unempl/n_zctas,
                   n_medicaid= n_distinct(study_id[payer_group=="Medicaid"]),
                   prop_medicaid= n_medicaid/n_zctas
  )

