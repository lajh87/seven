# Function to connect to database (with default parameters set).
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

# Query a database based on bounding box.
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