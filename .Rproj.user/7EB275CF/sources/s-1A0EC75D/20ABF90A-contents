library(tidyverse)
library(COVID19)


# COVID19 package data ----------------------------------------------------
covid <- covid19(country = "Spain", level = 2, raw = FALSE, verbose = FALSE) %>% 
  tibble()

num_names <- covid %>% 
  select(c(vaccines:population, latitude:longitude, contains("numeric"))) %>% 
  names()

cat_names <- covid %>% select(-c(all_of(num_names), id, date)) %>% names()

covid %>%
  select(all_of(num_names)) %>% 
  map_dfr(summary) %>% 
  mutate(across(everything(), as.numeric)) %>% 
  add_column(Variable = num_names, .before = 1)


summary_categorical <- function(data, cat_names, selector = 1:8){
  data %>% 
    transmute(across(all_of(cat_names[selector]), as.factor)) %>% 
    summary() %>%
    tibble()
}

summary_categorical(covid, cat_names)
summary_categorical(covid, cat_names, selector = 9:16)
summary_categorical(covid, cat_names, selector = 17:23)


# Datos ministerio --------------------------------------------------------

# Enlace documentacion
# https://cnecovid.isciii.es/covid19/#documentaci%C3%B3n-y-datos

# De residencia
# https://cnecovid.isciii.es/covid19/resources/casos_diagnostico_ccaa.csv
gob_diagnostico_ccaa <- read_csv("casos_diag_ccaadecl.csv")

# https://cnecovid.isciii.es/covid19/resources/casos_diagnostico_provincia.csv
gob_diagnostico_prov <- read_csv("casos_diagnostico_provincia.csv")

# Otras series disponibles

# De declaracion
# https://cnecovid.isciii.es/covid19/resources/casos_diag_ccaadecl.csv
gob_diag_ccaadecl <- read_csv("casos_diag_ccaadecl.csv")

# Número de hospitalizaciones, número de ingresos en UCI y número de
# defunciones por sexo, edad y provincia de residencia.
# https://cnecovid.isciii.es/covid19/resources/casos_hosp_uci_def_sexo_edad_provres.csv
gob_hosp_uci_def <- read_csv("casos_hosp_uci_def_sexo_edad_provres.csv")

gob_diagnostico_ccaa %>% head()
gob_diagnostico_prov %>% head()
gob_hosp_uci_def %>% head()


