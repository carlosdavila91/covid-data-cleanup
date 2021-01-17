library(tidyverse)
library(jsonlite)
library(rvest)
library(xml2)
library(httr)


# INE population and codes ------------------------------------------------

# https://servicios.ine.es/wstempus/js/{idioma}/{función}/{input}[?parámetros]

# Population
res <- GET("https://servicios.ine.es/wstempus/js/ES/DATOS_TABLA/2852", 
                query = list(geo = 1, date = 20200101))

population_2020 <- fromJSON(rawToChar(res$content)) %>% 
  tibble() %>% 
  mutate(Anyo = map_dbl(Data, ~pull(.x, Anyo)),
         Valor = map_dbl(Data, ~pull(.x, Valor)),
         Nombre = str_replace_all(Nombre, " Total. Total habitantes. Personas. |\\.", "")) %>% 
  filter(!str_detect(Nombre, "Hombre|Mujer")) %>% 
  transmute(region = Nombre, date = Anyo, population = Valor) 

# Codes
content <- read_html("https://www.ine.es/daco/daco42/codmun/cod_provincia.htm")
tables <- content %>% html_table(fill = T)

codes <- tables[[2]] %>% 
  bind_rows(tables[[3]]) %>% 
  bind_rows(tables[[4]])
