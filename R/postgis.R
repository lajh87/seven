#' Connecting and Querying postGIS database
#' 
#' Functions for connecting to and querying postGIS database.
#'
#' @param db Database name
#' @param host The server address
#' @param port Associated port
#' @param user Username
#' @param password Password
#'
#' @return Database connection and query results
#' @export
#' @rdname postgis
#'
#' @examples
#' db <- connect_postgres()
#' brize_q <- query_bounding_box(-1.62136, 51.74059,  -1.55236,  51.77501)
#' mil_build <- st_read(db, query = brize_q)
#' DBI::dbDisconnect(db)
NULL

#' @describeIn postgis connect_postgres
connect_postgres <- function(
    db = "milsites", 
    host = "localhost", 
    port = 5432,
    user = "postgres", 
    password = Sys.getenv("postgre_pw")
){
  DBI::dbConnect(
    RPostgres::Postgres(),
    host   = host,
    db = db,
    user = user,
    password = password,
    port = port
  )
}

#' @describeIn postgis query_bounding_box
query_bounding_box <- function(
    xmin = -3.08, ymin = 50.73, xmax =6.14, ymax = 52.10,
    tbl = "mil_build_os" 
){
  
  glue::glue("SELECT * FROM {tbl}
  WHERE  geometry 
  && 
    ST_MakeEnvelope (
      {xmin}, {ymin}, 
      {xmax}, {ymax}, 
      4326)")
}

