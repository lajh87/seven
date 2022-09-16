navy <- readr::read_csv("data/navy-bases.csv") |>
  dplyr::mutate(service = "Navy") |>
  dplyr::select(service, establishment = base, lon, lat)

army <- readr::read_csv("data/army-installations.csv") |>
  dplyr::mutate(service = "Army") |>
  dplyr::select(service, establishment = X1, lon, lat)

raf <- readr::read_csv("data/raf_stations.csv") |>
  dplyr::mutate(service = "RAF") |>
  dplyr::select(service, establishment = X1, lon, lat)

establishments <- dplyr::bind_rows(navy, army, raf) |>
  dplyr::filter(!is.na(lon))

write.csv(establishments, "inst/milheat/establishments.csv", row.names = FALSE)
