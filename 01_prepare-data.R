library(tidyverse)
library(jsonlite)
library(rvest)
library(xml2)
library(httr)


# CNIG regions ETRS89 -----------------------------------------------------

# URL: http://centrodedescargas.cnig.es/CentroDescargas/index.jsp

municipios <- read.csv2("data/cnig/MUNICIPIOS.csv", encoding = "latin1")

provincias <- read.csv2("data/cnig/PROVINCIAS.csv", encoding = "latin1")



# Provincias nombre español -----------------------------------------------

# https://es.wikipedia.org/wiki/Provincia_(Espa%C3%B1a)

link <- "https://es.wikipedia.org/wiki/Provincia_(Espa%C3%B1a)"
content <- read_html(link)

table <- content %>% html_table(fill = TRUE)

provincias_espanyol <- table[[2]] %>% 
  tibble() %>% 
  mutate(
    # Remove duplicates and weirds
    Provincia = map_chr(Provincia, ~paste(unique(unlist(strsplit(.x, split = "\\s"))), 
                                          collapse = " ")),
    Provincia = str_replace(Provincia, "Alicante", ""),
    Provincia = str_replace(Provincia, "Castellón", ""),
    Provincia = str_replace(Provincia, "CoruñaLa", ""),
    Provincia = str_replace(Provincia, "PalmasLas", ""),
    Provincia = str_replace(Provincia, "TenerifeSanta", ""),
    Provincia = str_replace(Provincia, "Zamora", ""),
    # Correct names according to official
    `Nombre oficial` = map_chr(`Nombre oficial`, 
                               ~paste(unique(unlist(strsplit(.x, split = "\\s"))), 
                                      collapse = " ")),
    `Nombre oficial` = str_replace_all(`Nombre oficial`, "-", "/"),
    `Nombre oficial` = str_replace(`Nombre oficial`, "Alicante/Alacant", "Alacant/Alicante"),
    `Nombre oficial` = str_replace(`Nombre oficial`, "Castellón/Castelló", "Castelló/Castellón"),
    `Nombre oficial` = str_replace(`Nombre oficial`, "Valencia/València", "València/Valencia"),
    # Correct duplicates in comunidad autonoma
    `Comunidad autónoma` = map_chr(`Comunidad autónoma`, 
                               ~paste(unique(unlist(strsplit(.x, split = "\\s"))), 
                                      collapse = " "))
  ) %>% 
  filter(!Provincia == "Ciudad autónoma")

saveRDS(provincias_espanyol, file = "data/provincias_espanyol.rds")

# INE population and codes ------------------------------------------------

# https://servicios.ine.es/wstempus/js/{idioma}/{función}/{input}[?parámetros]

# Population
res <- GET("https://servicios.ine.es/wstempus/js/ES/DATOS_TABLA/2852", 
                query = list(geo = 1, date = 20200101))

population_es_2020 <- fromJSON(rawToChar(res$content)) %>% 
  tibble() %>% 
  mutate(Anyo = map_dbl(Data, ~pull(.x, Anyo)),   # get data from nested data.frame
         Valor = map_dbl(Data, ~pull(.x, Valor)),
         Nombre = str_replace_all(Nombre, " Total. Total habitantes. Personas. |\\.", ""),
         Nombre = str_replace(Nombre, "Alicante/Alacant", "Alacant/Alicante"),
         Nombre = str_replace(Nombre, "Castellón/Castelló", "Castelló/Castellón"),
         Nombre = str_replace(Nombre, "Valencia/València", "València/Valencia"),
         Nombre = str_replace(Nombre, "Balears, Illes", "Illes Balears"),
         Nombre = str_replace(Nombre, "Rioja, La", "La Rioja"),
         Nombre = str_replace(Nombre, "Coruña, A", "A Coruña")
  ) %>% 
  filter(!str_detect(Nombre, "Hombre|Mujer|Total Nacional")) %>% 
  select(Nombre, Valor)

saveRDS(population_es_2020, file = "data/population_es_2020.rds")
write_csv(population_es_2020, "data/population_es_2020.csv")


# Join data ---------------------------------------------------------------

# Join provincias-capital-provincias_esp
cod_provincia_etrs89 <- provincias %>% 
  select(COD_PROV, PROVINCIA, CAPITAL) %>% 
  left_join(
    municipios %>% select(NOMBRE_ACTUAL, LONGITUD_ETRS89, LATITUD_ETRS89),
    by = c("CAPITAL" = "NOMBRE_ACTUAL")
  )
saveRDS(cod_provincia_etrs89, file = "data/cod_provincia_etrs89.rds")
write_csv(cod_provincia_etrs89, "data/cod_provincia_etrs89.csv")

cod_provincia_etrs89_nombre_espanyol <- cod_provincia_etrs89 %>% 
  left_join(
    provincias_espanyol, by = c("PROVINCIA" = "Nombre oficial")
  )
saveRDS(cod_provincia_etrs89_nombre_espanyol, file = "data/cod_provincia_etrs89_nombre_espanyol.rds")
write_csv(cod_provincia_etrs89_nombre_espanyol, "data/cod_provincia_etrs89_nombre_espanyol.csv")

# Full data
cod_provincia_etrs89_nombre_espanyol_population20 <- 
  cod_provincia_etrs89_nombre_espanyol %>% 
  left_join(population_es_2020, by = c("PROVINCIA" = "Nombre"))

saveRDS(cod_provincia_etrs89_nombre_espanyol_population20, file = "data/cod_provincia_etrs89_nombre_espanyol_population20.rds")
write_csv(cod_provincia_etrs89_nombre_espanyol_population20, "data/cod_provincia_etrs89_nombre_espanyol_population20.csv")

covid19_dataset_prepared <- 
  cod_provincia_etrs89_nombre_espanyol_population20 %>% 
  select(COD_PROV, Provincia, `Comunidad autónoma`, LONGITUD_ETRS89, LATITUD_ETRS89, Valor)
saveRDS(covid19_dataset_prepared, file = "data/covid19_dataset_prepared.rds")
write_csv(covid19_dataset_prepared, "data/covid19_dataset_prepared.csv")

