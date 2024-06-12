#----
library(readxl)
library(tidygeocoder)
library(tidyverse)
library(readr)
library("ggplot2")
library("ggspatial")
library("sf")
library("rnaturalearth")
library("rnaturalearthdata")



# Cargar base de datos con paises de colaboraciones

# URL del archivo CSV en GitHub
url <- "https://raw.githubusercontent.com/ccm-bioinfo/cambda2023/main/06_amr_resistance/data/absolute_order_assembly.csv"

# Leer el archivo CSV desde GitHub y almacenarlo como un dataframe en R
otus <- read_csv(url)

# Muestra las primeras filas del dataframe para verificar
head(otus)

unique_cities <- otus %>%
  distinct(City, Longitude, Latitude)


# Usando la librería rnaturalearth se crea el archivo sf que se usará para crear el mapa base.
world <- ne_countries(scale = "medium", returnclass = "sf")#baja datos paises

#se usa geom_sf para crear el mapa base usando el dataframe world

p <- ggplot(data = world) +
  # Capa para el fondo blanco
  geom_sf(fill = "white") +
  # Capa para las divisiones de países en negro
  geom_sf(data = world, fill = NA, colour = "black") +
  # Capa para los países en gris
  geom_sf(fill = "lightgrey", colour = "black") +
  # Capa para los puntos de otus
  geom_point(data = unique_cities, aes(x = Longitude, y = Latitude), color = "#0047ab", size = 1) +
  geom_label(data = unique_cities, aes(x = Longitude, y = Latitude, label = City), size = 5, color = "#0047ab") +
  # Configuración de tema para eliminar ejes y agregar título
  theme_void()

p

ggsave("mapa_otus.svg", plot = p, device = "svg", width = 20, height = 16)

