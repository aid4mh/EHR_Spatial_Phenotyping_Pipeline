# Recall columns:
# n_dep: total number of depression diagnosis  
# any_dep: had diagnosis of depression at that visit

# label `depressed`
# we applied PheKB’s ‘2/30/180 rule’, whereby a patient had to have received a depression diagnosis in at least 2 separate service dates, at least 30 days apart, and not more than 180 days apart during the study period to be considered depressed.

# add twodep to 'full' data frame
full <- full %>%
  group_by(study_id) %>%
  mutate(twodep= case_when(
    n_dep>1 ~ 1,
    n_dep<2 ~ 0))

# Create label 'depressed'
twodep.df <- full %>% filter(twodep==1)
twodep.df <- twodep.df[twodep.df$any_dep==1,] %>%
  group_by(study_id) %>%
  arrange(date) %>%
  mutate(diff = date - lag(date, default = first(date))) %>% 
  select(study_id, date, diff) %>% 
  arrange(study_id)

depressed.ids = twodep.df %>% filter(diff>=30 & diff<=180) %>% group_by(study_id) %>% summarise(count = n()) %>% select(study_id)
depression <- full %>% mutate(depressed = NA)
depression$depressed[depression$study_id %in% depressed.ids$study_id] <- 1
depression$depressed[is.na(depression$depressed)] <- 0
rm(depressed.ids, twodep.df, full)

# merge depressed label to person-level data
person_labels <- left_join(depression, person)
# if depressed==NA, change to zero
person_labels<- person_labels %>% 
  mutate(depressed=ifelse(is.na(depressed),0,depressed))

#Create person-level overweight/obesity labels
obesity <- depression %>% 
  group_by(study_id) %>%
  summarise(obese_np= max(obese_np))

#Merge in obesity label
person_labels <- left_join(person_labels %>% select(-obese_np), obesity)

rm(depression, obesity, person)

#Create person-level combined case status (depob) variable
person_labels <- person_labels %>% 
  mutate(depob=0) %>% 
  mutate(depob= ifelse((obese_np==1 & depressed==1),1,depob))

person_labels.first <- ddply(person_labels,.(study_id), head,1)
columns <- colnames(person.uw)[!colnames(person.uw) %in% c("depdx", "marital_status", "employment", "payer_group", "language_top", "religion_top", "tract")]
person_labels.first = person_labels.first %>% select(columns)
person = person_labels.first