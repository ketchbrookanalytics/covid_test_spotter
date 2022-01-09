library(shiny)
library(googleway)

ui <- fluidPage(
  google_mapOutput(outputId = "map"), 
  
  shiny::hr(), 
  
  shiny::verbatimTextOutput(outputId = "tmp")
  
  # reactable::reactableOutput(outputId = "tmp")
  
)

server <- function(input, output){
  
  
  
  output$map <- renderGoogle_map({
    google_map(
      key = key, 
      search_box = TRUE, 
      event_return_type = "list"
    )
  })
  
  output$tmp <- shiny::renderPrint({
    
    shiny::req(input$map_place_search)
    
    print(input$map_place_search)
    
  })
  
  # output$tmp <- reactable::renderReactable({
  #   
  #   shiny::req(input$map_place_search)
  #   
  #   input$map_place_search
    
    # data <- input$map_place_search
    
    # data.frame(
    #   name = data$name, 
    #   address = data$address,
    #   lat = data$lat, 
    #   lon = data$lon
    # ) |> 
    #   reactable::reactable(
    #     columns = list(
    #       name = colDef(
    #         name = "Place",
    #         # Show address under name
    #         cell = function(value, index) {
    #           addy <- data$address[index]
    #           shiny::div(
    #             shiny::div(style = list(fontWeight = 600), value),
    #             shiny::div(style = list(fontSize = 12), addy)
    #           )
    #         }
    #       ),
    #       address = colDef(show = FALSE)
    #     )
    #   )
  #   
  # })
  
}

shinyApp(ui, server)