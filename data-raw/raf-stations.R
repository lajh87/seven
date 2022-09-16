#'---
#'title: Scrape RAF Stations from Wiki
#'---

base <- "https://en.wikipedia.org/"
path <- "wiki/List_of_Royal_Air_Force_stations"
req <- httr::GET(base, path = path)
req$status_code

raf_stations <- httr::content(req) |>
  xml2::xml_find_all('//*[@id="mw-content-text"]/div[1]/table[1]//tr//td') |>
  xml2::xml_text() |>
  matrix(ncol = 4, byrow = TRUE) |>
  data.frame(stringsAsFactors = FALSE) |>
  dplyr::tibble() |>
  dplyr::mutate(
    X1 = stringr::str_remove_all(X1, "\n"),
    X2 = stringr::str_remove_all(X2, "\n"),
    X3 = stringr::str_remove_all(X3, "\n")
  ) |>
  dplyr::mutate(addr = paste(X1, X3, X2, sep = ", ")) |>
  ggmap::mutate_geocode(addr, output = "latlona")

write.csv(raf_stations, "data/raf_stations.csv", row.names = FALSE)
