library(shiny)
library(dplyr)
library(magrittr)
library(leaflet)
library(sf)

source("functions.R")
db <- connect_postgres()
establishments <- db |> 
  dplyr::tbl("mil_site_geo") |> 
  dplyr::collect()
DBI::dbDisconnect(db)

ui <- navbarPage(
  title = "milheat", 
  id="nav",
  header = tags$head(
    includeCSS("styles.css"),
    includeScript("gomap.js")
  ),
  tabPanel(
    title = "Interactive map",
    div(class="outer",
        leafletOutput("map", width="100%", height="100%"),
        absolutePanel(
          id = "controls", class = "panel panel-default", fixed = TRUE,
          draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
          width = 330, height = "auto",
          h2("Explorer")
        ),
        tags$div(id="cite", 'Data compiled for ', tags$em('Defence Hackathon'), ' by team seven.'
        )
    )
  ),
  
  tabPanel("Data explorer",
           DT::dataTableOutput("establishment_tbl")
  )
)
server <- function(input, output, session) {
  
  # Map ----
  output$map <- renderLeaflet({
    leaflet() |>
      addTiles() |>
      setView(lng = 0, lat = 51.5, zoom = 14) |>
      addMarkers(data = establishments, lng = ~lon,  lat = ~lat, popup = ~name, label = ~name)
  })
  
  # Fetch Data ----
  mil_build <- reactive({
    if(is.null(input$map_bounds)) return(NULL)
    
    q <- query_bounding_box(
      xmax = input$map_bounds$east, 
      ymin = input$map_bounds$south,
      xmin = input$map_bounds$west, 
      ymax = input$map_bounds$north,
      tbl = "military_site_clusters"
    )
    
    db <- connect_postgres()
    mil_build <- st_read(db, query = q)
    DBI::dbDisconnect(db)
    return(mil_build)
  })
  
  mil_build_t <- mil_build |>  debounce(millis = 500)
  
  observe({
    if(is.null(mil_build_t())) return(NULL)
    leafletProxy("map", data = mil_build_t()) |>
      clearShapes() |>
      addPolygons(popup = ~as.character(name))
  })
  
  
  # Data table ----
  output$establishment_tbl <- DT::renderDataTable({
    df <- establishments |>
      dplyr::select(service, type, name, address, lon, lat) |>
      mutate(Action = paste(
        '<a class="go-map" href="" data-lat="', lat, '" data-long="', lon, '">Go</a>', 
        sep="")
        )
    action <- DT::dataTableAjax(session, df, outputId = "establishment_tbl")
    
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })
  
  observe({
    if (is.null(input$goto)) return()
    isolate({
      map <- leafletProxy("map")
      lat <- input$goto$lat
      lng <- input$goto$lng
      map |> setView(lng, lat, 14)
    })
  })
  
}

shinyApp(ui, server)