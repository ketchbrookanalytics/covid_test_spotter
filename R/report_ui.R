


in_ui <- shiny::tagList(
  
  shiny::wellPanel(
    
    shiny::fluidRow(
      shiny::column(
        width = 12, 
        shiny::h4("Please Provide Information on When & Where You Saw Tests In Stock")
      )
    ), 
    
    shiny::hr(), 
    
    shiny::fluidRow(
      
      shiny::column(
        width = 3, 
        
        shiny::selectizeInput(
          inputId = "select_brand_in", 
          label = "Brand", 
          choices = c("BinaxNOW", "QuickVue", "Flowflex", "Multiple", "Other", "Not Sure"), 
          options = list(
            placeholder = "Choose One...", 
            onInitialize = I('function() { this.setValue(""); }')
          )
        ), 
        
        shiny::br(), 
        
        shiny::selectizeInput(
          inputId = "select_inventory_in", 
          label = "Inventory (Amount)", 
          choices = c(
            "High (Lots in Stock)", 
            "Medium (Fair Amount in Stock)", 
            "Low (Not Many Left in Stock)", 
            "Not Sure"
          ), 
          options = list(
            placeholder = "Choose One...", 
            onInitialize = I('function() { this.setValue(""); }')
          )
        ), 
        
        shiny::br(), 
        
        shiny::dateInput(
          inputId = "select_date_in", 
          label = "Date", 
          min = Sys.Date() - lubridate::days(5), 
          max = Sys.Date() + lubridate::days(1), 
          format = "mm/dd/yyyy"
        ),
        
        shiny::br(), 
        
        shiny::selectizeInput(
          inputId = "select_time_in", 
          label = "Time of Day", 
          choices = c("Morning", "Afternoon", "Evening"), 
          options = list(
            placeholder = "Choose One...", 
            onInitialize = I('function() { this.setValue(""); }')
          )
        )
        
      ), 
      
      shiny::column(
        width = 9, 
        
        shiny::div(
          shiny::div(
            style = "float: left; vertical-align: bottom;", 
            shiny::icon("map-marker-alt")
          ), 
          shiny::h5(
            style = "color: black; display: inline-block;", 
            "Find the Location using the Search Box below:"
          )
        ), 
        
        googleway::google_mapOutput(outputId = "map_in"), 
        
        shiny::br(), 
        
        shiny::textOutput(outputId = "selected_address_in")
        
      )
      
    ), 
    
    shiny::fluidRow(
      shiny::column(
        width = 12, 
        
        shiny::hr(), 
        
        shiny::actionButton(
          class = "btn btn-info", 
          inputId = "submit_in_draft_btn", 
          label = "Submit"
        )
        
      )
      
    )
    
  )
  
)


out_ui <- shiny::tagList(
  
  shiny::wellPanel(
    
    shiny::fluidRow(
      shiny::column(
        width = 12, 
        shiny::h4("Please Provide Information on When & Where You Saw Tests Out of Stock")
      )
    ), 
    
    shiny::hr(), 
    
    shiny::fluidRow(
      
      shiny::column(
        width = 3, 
        
        shiny::dateInput(
          inputId = "select_date_out", 
          label = "Date", 
          min = Sys.Date() - lubridate::days(5), 
          max = Sys.Date() + lubridate::days(1), 
          format = "mm/dd/yyyy"
        ),
        
        shiny::br(), 
        
        shiny::selectizeInput(
          inputId = "select_time_out", 
          label = "Time of Day", 
          choices = c("Morning", "Afternoon", "Evening"), 
          options = list(
            placeholder = "Choose One...", 
            onInitialize = I('function() { this.setValue(""); }')
          )
        )
        
      ), 
      
      shiny::column(
        width = 9, 
        
        shiny::div(
          shiny::div(
            style = "float: left; vertical-align: bottom;", 
            shiny::icon("map-marker-alt")
          ), 
          shiny::h5(
            style = "color: black; display: inline-block;", 
            "Find the Location using the Search Box below:"
          )
        ), 
        
        googleway::google_mapOutput(outputId = "map_out"), 
        
        shiny::br(), 
        
        shiny::textOutput(outputId = "selected_address_out")
        
      )
      
    ), 
    
    shiny::hr(), 
    
    shiny::fluidRow(
      
      shiny::column(
        width = 12, 
        
        shiny::actionButton(
          class = "btn btn-info", 
          inputId = "submit_out_draft_btn", 
          label = "Submit"
        )
        
      )
      
    )
    
  )
  
)
