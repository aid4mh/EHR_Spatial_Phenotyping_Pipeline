We used GeoDa to visualize obesity/depression prevalence and spatial representation ratio at ZCTA level.  
We also used GeoDa to comput Moran's I for global and local spatial autocorrelations respectively.

First, we imported shape file and estimated underlying population in each zcta into GeoDa. (source: https://geo.wa.gov/datasets/wa-ofm::waofm-saep-population-estimates-wfl1/explore?layer=9)
Then, we merged the `shrunken_selected.csv` dataset with the imported WAOFM_SAEP_Population_Estimates_WFL1.shp dataset in GeoDa.
We then performed global and local spatial antocorrelation analysis.  

Here are detailed GeoDa workbook by Luc Anselin, University of Chicago, Center for Spatial Data Science that we followed:
Global Spatial Autocorrelation:   https://geodacenter.github.io/workbook/5a_global_auto/lab5a.html   
Local Spatial Autocorrelation:   https://geodacenter.github.io/workbook/6a_local_auto/lab6a.html  


