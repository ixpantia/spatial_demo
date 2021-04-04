library(sf)
library(tidyverse)
library(leaflet)

beaches <- st_read("data/playas2014crtm05.shp", 
                  options = "ENCODING=latin1") %>% 
  st_transform(crs = "+init=epsg:4326") %>%  
  select(-X_COORD, -Y_COORD)

segments <- st_read("data/Segmento Censal_CR.shp",
                     options = "ENCODING=latin1") %>% 
  st_transform(crs = "+init=epsg:4326") 

# General map -----------------------------------------------------------------
leaflet() %>%
  addTiles() %>%
  setView(lat = 10, lng = -84, zoom = 7) %>%
  addCircleMarkers(data = beaches,
                   popup = paste0("<strong> Playa: </strong>",
                                  beaches$NOMBRE_DE_),
                   opacity = 1,
                   radius = 0.5,
                   color = "#B306B6") %>%
  addPolygons(data = segments,
              fillColor = "chartreuse",
              popup = paste0("<strong> Province: </strong>", 
                             segments$PROVINCIA,
                             "<br><strong> Canton: </strong>",
                             segments$NCANTON,
                             "<br><strong> District: </strong>",
                             segments$NDISTRITO,
                             "<br><strong>Segment ID: </strong>",
                             segments$IDSEG),
              color = "black",
              fillOpacity = 0.35,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue"))

# Procedure 1 --------------------------------------------------------------
acosta <- readRDS("data/shapes_segmentos/segmentos_acosta.rds")
alfaro_ruiz <- readRDS("data/shapes_segmentos/segmentos_alfaro_ruiz.rds")

leaflet() %>%
  addTiles() %>%
  setView(lat = 10, lng = -84, zoom = 7) %>%
  addPolygons(data = acosta,
              fillColor = "chartreuse",
              popup = paste0("<strong> Province: </strong>", 
                             acosta$PROVINCIA,
                             "<br><strong> Canton: </strong>",
                             acosta$NCANTON,
                             "<br><strong> District: </strong>",
                             acosta$NDISTRITO,
                             "<br><strong> Segment ID: </strong>",
                             acosta$IDSEG),
              color = "black",
              fillOpacity = 0.35,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue")) %>%
  addPolygons(data = alfaro_ruiz,
              fillColor = "chartreuse",
              popup = paste0("<strong> Province: </strong>", 
                             alfaro_ruiz$PROVINCIA,
                             "<br><strong> Canton: </strong>",
                             alfaro_ruiz$NCANTON,
                             "<br><strong> District: </strong>",
                             alfaro_ruiz$NDISTRITO,
                             "<br><strong> Segment ID: </strong>",
                             alfaro_ruiz$IDSEG),
              color = "black",
              fillOpacity = 0.35,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue"))

# Procedure 2---------------------------------------------------------------

leaflet() %>%
  addTiles() %>%
  setView(lat = 10, lng = -84, zoom = 7) %>%
  addPolygons(data = acosta,
              fillColor = "chartreuse",
              popup = paste0("<strong> Province: </strong>", 
                             acosta$PROVINCIA,
                             "<br><strong> Canton: </strong>",
                             acosta$NCANTON,
                             "<br><strong> District: </strong>",
                             acosta$NDISTRITO,
                             "<br><strong> Segment ID: </strong>",
                             acosta$IDSEG),
              color = "black",
              fillOpacity = 0.35,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue")) %>%
  addCircleMarkers(data = beaches,
                   popup = paste0("<strong> Playa: </strong>",
                                  beaches$NOMBRE_DE_),
                   opacity = 1,
                   radius = 0.5,
                   color = "#B306B6")

# Procedure 3 --------------------------------------------------------------

segments <- segments %>% 
  mutate(NCANTON = as.factor(NCANTON))

factpal <- colorFactor(rainbow(82), unique(segments$NCANTON), alpha = FALSE)

leaflet() %>%
  addTiles() %>%
  setView(lat = 10, lng = -84, zoom = 7) %>%
  addPolygons(data = segments,
              fillColor = ~factpal(NCANTON),
              popup = paste0("<strong> Province: </strong>", 
                             segments$PROVINCIA,
                             "<br><strong> Canton: </strong>",
                             segments$NCANTON,
                             "<br><strong> Districto: </strong>",
                             segments$NDISTRITO,
                             "<br><strong> Segment ID: </strong>",
                             segments$IDSEG),
              color = "black",
              fillOpacity = 1,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue"))

## Result -------------------------------------------------------------------

result <- readRDS("data/segmentos_playas.rds")

paleta <- colorNumeric( palette = colorRampPalette(c('#70FB01', '#760506'))
                  (length(result$distancia_m)), domain = result$distancia_m)

leaflet() %>%
  addTiles() %>%
  setView(lat = 10, lng = -84, zoom = 7) %>%
  addPolygons(data = result,
              color = ~paleta(result$distancia_m),
              popup = paste0("<strong> Province: </strong>", 
                             result$PROVINCIA,
                             "<br><strong> Canton: </strong>",
                             result$NCANTON,
                             "<br><strong> District: </strong>",
                             result$NDISTRITO,
                             "<br><strong> Segment ID: </strong>",
                             result$IDSEG),
              fillOpacity = 1,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue")) %>%
  addLegend("bottomright", pal = paleta, values = result$distancia_m,
            title = "Vicinity to a beach",
            labFormat = labelFormat(suffix = "m"),
            opacity = 1)

