library(shiny)
library(dplyr)
library(magrittr)
library(leaflet)

establishments <- readr::read_csv("establishments.csv")

ui <- navbarPage(
  title = "milheat", 
  id="nav",
  tabPanel(
    title = "Interactive map",
    div(class="outer",
        tags$head(
          includeCSS("styles.css"),
          includeScript("gomap.js")
        ),
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
  ),
  
  conditionalPanel("false", icon("crosshairs"))
)
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() |>
      addTiles() |>
      setView(lng = -93.85, lat = 37.45, zoom = 4)
  })
  
  observe({
    if (is.null(input$goto))
      return()
    isolate({
      map <- leafletProxy("map")
     
      dist <- 0.1
      
      lat <- input$goto$lat
      lng <- input$goto$lng
  
      map |> 
        setView(lng, lat, 14)
        
      
    })
  })
  
  output$establishment_tbl <- DT::renderDataTable({
    df <- establishments |>
      mutate(Action = paste('<a class="go-map" href="" data-lat="', lat, '" data-long="', lon, '"><i class="fa fa-crosshairs"></i></a>', sep=""))
    
    action <- DT::dataTableAjax(session, df, outputId = "establishment_tbl")
    
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })
}

shinyApp(ui, server)