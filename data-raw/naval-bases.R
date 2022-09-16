yml <- yaml::read_yaml("data-raw/navy-bases.yml")
navy_bases <- purrr::imap_dfr(yml, ~dplyr::tibble(category = .y, base = .x))
navy_bases_geo <- navy_bases |>
  ggmap::mutate_geocode(base, output = "latlona")
write.csv(navy_bases_geo, "data/navy-bases.csv", row.names = FALSE)
