

library(shiny)
library(bslib)
library(reactable)
library(lubridate)
library(googleway)

source("R/home_ui.R")
source("R/about_ui.R")
source("R/report_ui.R")

data <- data.frame(
  Location = c("Walgreens", "Big Y", "Costco"), 
  Town = c("Ellington", "Rockville", "Enfield"), 
  Inventory = c("High", "Low", "Not Sure"), 
  Type = c("BinaxNOW", "QuickVue", "Flowflex"), 
  Time = c(
    Sys.time() %m-% lubridate::days(1), 
    Sys.time(), 
    Sys.time() %m+% lubridate::days(1)
  )
)


nav_items <- function() {
  
  list(
    bslib::nav("Home", home_ui), 
    bslib::nav_menu(
      title = "Submit Report", 
      bslib::nav("Tests In Stock", in_ui), 
      bslib::nav("Tests Out of Stock", out_ui), 
    ), 
    bslib::nav("About", about_ui), 
    bslib::nav_spacer(),
    bslib::nav_item(
      tags$a(
        shiny::icon("paper-plane"), 
        "Visit Ketchbrook Analytics", 
        href = "https://www.ketchbrookanalytics.com/", 
        target = "_blank"
      ), 
      align = "right"
    )
  ) 
  
}


ui <- bslib::page_navbar(
  title = "CT COVID-19 At-Home Test Spotter", 
  theme = bslib::bs_theme(
    bootswatch = "cerulean", 
    fg = "#0B2B7C",  # CT blue
    bg = "#FFFFFF"   # white
  ), 
  
  tags$head(
    tags$style(HTML("
    
      .shiny-date-input .shiny-input-container .shiny-bound-input {
        background: #FFFFFF;
        color: #0B2B7C;
      }
      
      .selectize-dropdown-content {
        background: #FFFFFF !important;
        color: #0B2B7C !important;
      }
      
      .selectize-dropdown-content .active {
        background: #0B2B7C !important;
        color: #FFFFFF !important;
      }

    "))
  ),
  
  !!!nav_items()
)

server <- function(input, output, session) {
  
  output$table <- reactable::renderReactable({
    reactable::reactable(
      data, 
      filterable = TRUE, 
      showSortable = TRUE,
      defaultSorted = list(Time = "desc"), 
      columns = list(
        Location = reactable::colDef(filterable = FALSE), 
        Time = reactable::colDef(filterable = FALSE)
      )
    )
  })
  
  # output$map <- googleway::renderGoogle_map({
  #   googleway::google_map(
  #     key = key, 
  #     search_box = TRUE, 
  #     event_return_type = "list"
  #   )
  # })
  
  # shiny::observeEvent(input$report_in_btn, {
  # 
  #   modal_ui(type = "in") |>
  #     shiny::showModal()
  # 
  # })
  # 
  # shiny::observeEvent(input$report_out_btn, {
  # 
  #   modal_ui(type = "out") |>
  #     shiny::showModal()
  # 
  # })
  
  
}

shiny::shinyApp(ui, server)