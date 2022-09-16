#'---
#'title: Scrape AI from Wiki
#'---
#'


library(httr)
library(xml2)
library(ggmap)

base <- "https://en.wikipedia.org/"
path <- "wiki/List_of_British_Army_installations"
req <- GET(base, path = path)
req$status_code
xml <- content(req)

army_installations <- xml_find_all(xml, "//table[21]//tr/td") |>
  xml_text() |>
  matrix(ncol = 6, byrow = TRUE) |>
  data.frame(stringsAsFactors = FALSE) |>
  dplyr::tibble()

army_inst_geo <- army_installations |>
  dplyr::mutate(search = paste(X1, X4, sep = ", ")) |>
  mutate_geocode(location = search, output = "latlona")

  
write.csv(army_inst_geo, "data/army-installations.csv", row.names = FALSE)
