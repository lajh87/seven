#'---
#'title: Scrape RAF Stations from Wiki
#'---

base <- "https://en.wikipedia.org/"
path <- "wiki/List_of_Royal_Air_Force_stations"
req <- httr::GET(base, path = path)
req$status_code
httr::content(req) |>
  xml2::xml_find_all('//*[@id="mw-content-text"]/div[1]/table[1]//tr//td') |>
  xml2::xml_text() |>
  matrix(ncol = 4, byrow = TRUE) |>
  data.frame(stringsAsFactors = FALSE) |>
  dplyr::tibble()
