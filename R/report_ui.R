


in_ui <- shiny::tagList(
  
  shiny::fluidRow(
    
    shiny::column(
      width = 3, 
      
      shiny::selectizeInput(
        inputId = "select_type_in", 
        label = "Brand", 
        choices = c("BinaxNOW", "QuickVue", "Flowflex", "Other", "Not Sure"), 
        options = list(
          placeholder = "Choose One...", 
          onInitialize = I('function() { this.setValue(""); }')
        )
      )
      
    ), 
    
    shiny::column(
      width = 3, 
      
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
      )
      
    ), 
    
    shiny::column(
      width = 3, 
      
      shiny::dateInput(
        inputId = "select_date_in", 
        label = "Date Spotted", 
        min = Sys.Date() %m-% months(1), 
        max = Sys.Date() %m+% lubridate::days(1), 
        format = "mm/dd/yyyy"
      )
      
    ), 
    
    shiny::column(
      width = 3, 
      
      shiny::selectizeInput(
        inputId = "select_time_of_day_in", 
        label = "Time of Day Spotted", 
        choices = c("Morning", "Afternoon", "Evening"), 
        options = list(
          placeholder = "Choose One...", 
          onInitialize = I('function() { this.setValue(""); }')
        )
      )
      
    )

  ), 
  
  shiny::hr(), 
  
  shiny::fluidRow(
    
    shiny::column(
      width = 12, 
      
      shiny::h4("Please Select the Location Where You Saw Tests In Stock")#, 
      
      # googleway::google_mapOutput(outputId = "map")
      
    )
    
  )
  
)


out_ui <- shiny::tagList(
  
  shiny::fluidRow(
    
    shiny::column(
      width = 3, 
      
      shiny::dateInput(
        inputId = "select_date_out", 
        label = "Date", 
        min = Sys.Date() %m-% months(1), 
        max = Sys.Date() %m+% lubridate::days(1), 
        format = "mm/dd/yyyy"
      )
      
    ), 
    
    shiny::column(
      width = 3, 
      
      shiny::selectizeInput(
        inputId = "select_time_of_day_out", 
        label = "Time of Day", 
        choices = c("Morning", "Afternoon", "Evening"), 
        options = list(
          placeholder = "Choose One...", 
          onInitialize = I('function() { this.setValue(""); }')
        )
      )
      
    )
    
  ), 
  
  shiny::hr(), 
  
  shiny::fluidRow(
    
    shiny::column(
      width = 12, 
      
      shiny::h4("Please Select the Location Where You Saw Tests Out of Stock")#, 
      
      # googleway::google_mapOutput(outputId = "map")
      
    )
    
  )
  
)
