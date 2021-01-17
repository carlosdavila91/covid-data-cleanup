# covid-data-cleanup

COVID19 Data preparation.

## Possible contributions

+ Fix encoding error in `administrative_area_level_2` and `administrative_area_level_3`.
+ Add population data at `administrative_area_level_2` and `administrative_area_level_3`.
+ Add coordinates at `administrative_area_level_2` and `administrative_area_level_3`.

## Steps



+ Download population data
+ Download coordinates
+ Save in RDS format in repo
+ Pull request to [ds_mscbs_es.R](https://github.com/covid19datahub/COVID19/blob/master/R/ds_mscbs_es.R)
+ Build shiny app (inspiration [RTVE](https://www.rtve.es/noticias/coronavirus-graficos-mapas-datos-covid-19-espana-mundo/))
+ Automate ETL

