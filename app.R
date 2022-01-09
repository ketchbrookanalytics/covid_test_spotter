

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
    bslib::nav(title = "Home", home_ui), 
    bslib::nav_menu(
      title = "Submit Report", 
      bslib::nav(title = "Tests In Stock", in_ui, value = "nav_report_in"), 
      bslib::nav(title = "Tests Out of Stock", out_ui, value = "nav_report_out"), 
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
  id = "nav_bar_id", 
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
      language = reactable::reactableLang(filterPlaceholder = "Search..."), 
      columns = list(
        Location = reactable::colDef(filterable = FALSE), 
        Time = reactable::colDef(filterable = FALSE)
      )
    )
  })
  
  output$map_in <- googleway::renderGoogle_map({
    googleway::google_map(
      key = key,
      search_box = TRUE,
      event_return_type = "list", 
      location = c(41.763710, -72.685097), 
      map_type_control = FALSE, 
      street_view_control = FALSE
    )
  })
  
  output$selected_address_in <- shiny::renderText({
    
    shiny::req(input$map_in_place_search$address)
    
    paste0("Address Selected: ", input$map_in_place_search$address)
    
  })
  
  output$map_out <- googleway::renderGoogle_map({
    googleway::google_map(
      key = key,
      search_box = TRUE,
      event_return_type = "list", 
      location = c(41.763710, -72.685097), 
      map_type_control = FALSE, 
      street_view_control = FALSE
    )
  })
  
  output$selected_address_out <- shiny::renderText({
    
    shiny::req(input$map_out_place_search$address)
    
    paste0("Address Selected: ", input$map_out_place_search$address)
    
  })
  
  shiny::observeEvent(input$report_in_btn, {

    bslib::nav_select(
      id = "nav_bar_id", 
      selected = "nav_report_in"
    )

  })

  shiny::observeEvent(input$report_out_btn, {

    bslib::nav_select(
      id = "nav_bar_id", 
      selected = "nav_report_out"
    )

  })
  
  shiny::observeEvent(input$submit_in_draft_btn, {
    
    check <- any(
      nchar(trimws(input$select_brand_in)) == 0, 
      nchar(trimws(input$select_inventory_in)) == 0, 
      nchar(trimws(input$select_date_in)) == 0, 
      nchar(trimws(input$select_time_in)) == 0, 
      length(input$map_in_place_search) == 0, 
      !grepl(input$map_in_place_search$address, "CT")
    )
    
    if (any(check)) {
      
      modal <- shiny::modalDialog(
        title = "Oops!", 
        "It looks like you forgot something...", 
        "Please ensure you chose an option from each drop down menu, and selected a location in Connecticut from the map.", 
        footer = shiny::modalButton(
          label = "Go Back"
        )
      )
      
    } else {
      
      modal <- shiny::modalDialog(
        title = "Please Review the Information Provided", 
        
        shiny::tagList(
          shiny::p(
            "By clicking \"Submit\", you verify that the following information about the COVID-19 at-home tests you saw in stock is correct to the best of your knowledge:"
          ), 
          shiny::br(), 
          shiny::p(
            paste0("Brand: ", input$select_brand_in)
          ), 
          shiny::p(
            paste0("Inventory (Amount): ", input$select_inventory_in)
          ), 
          shiny::p(
            paste0("Date: ", format(as.Date(input$select_date_in), "%A, %B %d, %Y"))
          ), 
          shiny::p(
            paste0("Time of Day: ", input$select_time_in)
          ), 
          shiny::p(
            paste0("Location Name: ", input$map_in_place_search$name)
          ), 
          shiny::p(
            paste0("Address: ", input$map_in_place_search$address)
          )
        ),
        
        footer = shiny::tagList(
          shiny::div(
            # Button to dismiss the modal
            shiny::modalButton(
              label = "Go Back"
            ), 
            # Button to move to the next question
            shiny::actionButton(
              inputId = "submit_in_final_btn", 
              label = "Submit", 
              icon = shiny::icon("check")
            )
          )
        )
      )
      
    }
    
    shiny::showModal(modal)
    
  })
  
  
  shiny::observeEvent(input$submit_out_draft_btn, {
    
    check <- any(
      nchar(trimws(input$select_date_out)) == 0, 
      nchar(trimws(input$select_time_out)) == 0, 
      length(input$map_in_place_search) == 0, 
      !grepl(input$map_in_place_search$address, "CT")
    )
    
    if (any(check)) {
      
      modal <- shiny::modalDialog(
        title = "Oops!", 
        "It looks like you forgot something...", 
        "Please ensure you chose an option from each drop down menu, and selected a location in Connecticut from the map.", 
        footer = shiny::modalButton(
          label = "Go Back"
        )
      )
      
    } else {
      
      modal <- shiny::modalDialog(
        title = "Please Review the Information Provided", 
        
        shiny::tagList(
          shiny::p(
            "By clicking \"Submit\", you verify that the following information about the COVID-19 at-home tests you found to be out of stock is correct to the best of your knowledge:"
          ), 
          shiny::br(), 
          shiny::p(
            paste0("Date: ", format(as.Date(input$select_date_out), "%A, %B %d, %Y"))
          ), 
          shiny::p(
            paste0("Time of Day: ", input$select_time_out)
          ), 
          shiny::p(
            paste0("Location Name: ", input$map_out_place_search$name)
          ), 
          shiny::p(
            paste0("Address: ", input$map_out_place_search$address)
          )
        ),
        
        footer = shiny::tagList(
          shiny::div(
            # Button to dismiss the modal
            shiny::modalButton(
              label = "Go Back"
            ), 
            # Button to move to the next question
            shiny::actionButton(
              inputId = "submit_out_final_btn", 
              label = "Submit", 
              icon = shiny::icon("check")
            )
          )
        )
      )
      
    }
    
    shiny::showModal(modal)
    
  })
  
  
  shiny::observeEvent(input$submit_in_final_btn, {
    
    data <- tibble::tibble(
      place_id = input$map_in_place_search$place_id, 
      name = input$map_in_place_search$name, 
      address = input$map_in_place_search$address, 
      lat = input$map_in_place_search$lat, 
      lon = input$map_in_place_search$lon, 
      brand = input$select_brand_in, 
      inventory = input$select_inventory_in, 
      date = input$select_date_in, 
      time = input$select_time_in, 
      timestamp = Sys.time() |> as.character()
    )
    
  })
  
  
  
}

shiny::shinyApp(ui, server)