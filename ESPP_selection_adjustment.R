# Add measures of spatial representation ratio
persons_zips<- persons_zips %>% 
  mutate_at(c("zcta"), as.character) %>%
  mutate(prop_obs=n_zctas/sum(n_zctas)) %>%  # proportion of DQ patients in the zcta
  mutate (prop_pop=pop_zctas/sum(pop_zctas))%>%   # proportion of whole population in the zcta
  mutate(prop_diff= prop_obs-prop_pop) %>% 
  mutate(prop_ratio= prop_obs/prop_pop)   # spatial representation ratio (SRR)

write.csv(persons_zips, "persons_zips.csv")
# use this file to visualize SRR in GeoDa and pick the reasonable smaller areas with high SRR (e.g. >0.5)

# in our case, we choose zctas in King and Snohomish Counties
zcta_selected = zcta_to_county$zcta5[zcta_to_county$county==53033 | zcta_to_county$county==53061]
person_complete_selected = person_complete %>% filter(zcta %in% zcta_selected)

# Summarize at the zip level
persons_zips_selected<- person_complete_selected %>%
  group_by(zcta) %>%
  dplyr::summarise(n_zctas= n(),   # how many DQ patients in the zcta
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

# Add measures of spatial representation ratio
persons_zips_selected<- persons_zips_selected %>% 
  mutate_at(c("zcta"), as.character) %>%
  mutate(prop_obs=n_zctas/sum(n_zctas)) %>%  # proportion of DQ patients in the zcta
  mutate (prop_pop=pop_zctas/sum(pop_zctas))%>%   # proportion of population in the zcta
  mutate(prop_diff= prop_obs-prop_pop) %>% 
  mutate(prop_ratio= prop_obs/prop_pop)   # spatial representation ratio (SRR)

####################################
# EB Depression
prior_selected <- ebb_fit_prior(persons_zips_selected, n_dep, n_zctas)
shrunken_selected <- add_ebb_estimate(persons_zips_selected, n_dep, n_zctas)
shrunken_selected$zcta <- as.character(shrunken_selected$zcta)

# Plot raw vs fitted vs n_zctas to make sure the tracts with fewer observations are the ones that are more shrunken to the mean, something like:
bayes_plot_selected <- ggplot(shrunken_selected, aes(.raw, .fitted, size = log10(n_zctas))) +
  scale_x_continuous("Proportion w/ Depression, Raw Data") +
  scale_y_continuous("EB Corrected Proportion w/ Depression") +
  geom_point() +
  geom_abline(color = "blue") +
  geom_hline(yintercept = tidy(prior_selected)$mean, color = "blue", lty = 2) +
  scale_size_continuous("Log number of\npatients in zip")+
  theme_minimal()
bayes_plot_selected

# EB Overweight/Obesity
prior_selected_ob <- ebb_fit_prior(persons_zips_selected, n_ob, n_zctas)
shrunken_selected_ob <- add_ebb_estimate(persons_zips_selected, n_ob, n_zctas)
shrunken_selected_ob$zcta <- as.character(shrunken_selected_ob$zcta)

# Plot raw vs fitted vs n_zctas to make sure the tracts with fewer observations are the ones that are more shunken to the mean, something like:
bayes_plot_selected_ob <- ggplot(shrunken_selected_ob, aes(.raw, .fitted, size = log10(n_zctas))) +
  scale_x_continuous("Proportion Overweight/Obese, Raw Data") +
  scale_y_continuous("EB Corrected Proportion Overweight/Obese") +
  geom_point() +
  geom_abline(color = "orange") +
  geom_hline(yintercept = tidy(prior_selected_ob)$mean , color = "orange", lty = 2) +
  scale_size_continuous("Log number of\npatients in zip")+
  theme_minimal()
bayes_plot_selected_ob

# EB Depression & Overweight/Obesity
prior_selected_depob <- ebb_fit_prior(persons_zips_selected, n_depob, n_zctas)
shrunken_selected_depob <- add_ebb_estimate(persons_zips_selected, n_depob, n_zctas)
shrunken_selected_depob$zcta <- as.character(shrunken_selected_depob$zcta)

# Plot raw vs fitted vs n_zctas to make sure the tracts with fewer observations are the ones that are more shrunken to the mean, something like:
bayes_plot_selected_depob <- ggplot(shrunken_selected_depob, aes(.raw, .fitted, size = log10(n_zctas))) +
  scale_x_continuous("Proportion w/ Depression & Overweight/Obesity, Raw Data") +
  scale_y_continuous("EB Corrected Proportion w/ Depression & Overweight/Obesity") +
  geom_point() +
  geom_abline(color = "red") +
  geom_hline(yintercept = tidy(prior_selected_depob)$mean , color = "red", lty = 2) +
  scale_size_continuous("Log number of\npatients in zip")+
  theme_minimal()
bayes_plot_selected_depob

rm(bayes_plot_selected, bayes_plot_selected_ob, bayes_plot_selected_depob )
rm(prior_selected, prior_selected_ob, prior_selected_depob)

# Combining EB results for the 3 outcomes
shrunken_selected<-left_join(shrunken_selected_depob, shrunken_selected, by = "zcta", copy = FALSE, suffix = c(".depob", ".dep"))
shrunken_selected<-left_join(shrunken_selected, shrunken_selected_ob, by = "zcta", copy = FALSE, suffix = c("", ".ob"))    
#suffix didn't apply because there were actually no variable name conflicts. Add suffix .ob for clarity
shrunken_selected <- dplyr::rename(shrunken_selected, .alpha1.ob = .alpha1, .beta1.ob=.beta1, .fitted.ob=.fitted, .raw.ob=.raw, .low.ob=.low, .high.ob=.high)

#Remove repeated variables   
shrunken_selected <- shrunken_selected %>% select(
  c("zcta", "n_zctas", "pop_zctas", "mean_age_zips", "n_dep", "prop_dep", "n_ob", "prop_ob", "n_depob", "prop_depopb",
    "n_control", "prop_control", "n_fem", "prop_fem", "n_nhwhite", "prop_nhwhite", "n_hisp", "prop_hisp", 
    "prop_ratio", ".alpha1.dep", ".beta1.dep", ".fitted.dep", ".raw.dep",
    ".low.dep", ".high.dep", ".alpha1.ob", ".beta1.ob", ".fitted.ob", ".raw.ob", ".low.ob", ".high.ob", ".alpha1.depob",
    ".beta1.depob", ".fitted.depob", ".raw.depob", ".low.depob", ".high.depob"))    
shrunken_selected<- dplyr::rename(shrunken_selected, prop_depob = prop_depopb)
rm(shrunken_selected, shrunken_selected_ob, shrunken_selected_depob, persons_zips_selected, persons_zips)
# add percentage columns
shrunken_selected = shrunken_selected %>% mutate(perc_dep = .fitted.dep*100, perc_ob = .fitted.ob*100, perc_depob = .fitted.depob*100)

####################################
# save the dataset to be merged with shape file in GeoDa
write_csv(shrunken_selected, "shrunken_selected.csv")
