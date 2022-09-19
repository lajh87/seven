#' Function to get api key from m2m api
get_api_key  <- function(user = "lajh87", password = Sys.getenv("ers_pw") ){
  base <- "https://m2m.cr.usgs.gov/"
  path <- "api/api/json/stable/login"
  
  payload <- list(
    username = user,
    password = password
  )
  
  payload_json <- jsonlite::toJSON(
    rapply(payload, function(z) {
      if (length(z) == 1L) jsonlite::unbox(z) else z
    }, how = "replace")
  )
  
  req <- httr::POST(base, path = path, body = payload_json)
  httr::content(req)$data
  
}


logout_usgs <- function(api_key){
  base <- "https://m2m.cr.usgs.gov/"
  path <- "api/api/json/stable/logout"
  
  payload <- list()
  req <- httr::POST(base, path = path, body = payload,
                    httr::add_headers(`X-Auth-Token` = api_key))
  req$status_code
}

# Function to search through the api
dataset_search <- function(
    api_key, 
    payload = list(catalog = "EE", datasetName = "Landsat")
){
  
  base <- "https://m2m.cr.usgs.gov/"
  path <- "api/api/json/stable/dataset-search"
  
  req <- httr::POST(
    url = base, 
    path = path, 
    body = payload, 
    encode = "json",
    httr::add_headers(`X-Auth-Token` = api_key)
  )
  
  
  if(req$status_code != 200) return(req$status_code)
  
  req |> 
    httr::content() |>
    purrr::pluck("data") |>
    purrr::map_df(~dplyr::as_tibble(t(unlist(.x))))
}

scene_search <- function(
    api_key,
    payload =  list(
      datasetName = "landsat_ot_c2_l2",
      startingNumber = 1,
      maxResults = 1867,
      sceneFilter = list(
        spatialFilter = list(
          filterType = "mbr", 
          lowerLeft = list(latitude = 49.959999905, longitude = -7.57216793459 ),
          upperRight = list(latitude = 58.6350001085 , longitude =  1.68153079591)
        ),
        acquisitionFilter = list(
          start = "2021-08-31",
          end = "2022-09-01"
        )
      ))
){
  base <- "https://m2m.cr.usgs.gov/"
  path <- "api/api/json/stable/scene-search"
  
  req <- httr::POST(
    url = base, 
    path = path, 
    body = payload, 
    encode = "json",
    httr::add_headers(`X-Auth-Token` = api_key)
  )
  
  if(req$status_code != 200) return(req$status_code)
  
  httr_content <- req |>
    httr::content() 
  
  total_hits <- httr_content |> purrr::pluck("data", "totalHits")
  results <- httr_content |> purrr::pluck("data", "results")
  
  purrr::map_df(results, ~unlist(.x))
}
