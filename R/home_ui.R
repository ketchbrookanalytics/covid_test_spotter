


home_ui <- shiny::tagList(
  
  shiny::fluidRow(
    
    shiny::column(
      width = 6, 
      shiny::actionButton(
        class = "btn btn-success", 
        style = "color: white; padding: 15px 32px;", 
        inputId = "report_in_btn", 
        label = "Click to Report Tests In Stock", 
        width = "100%"
      )
    ), 
    
    shiny::br(), 
    shiny::br(), 
    shiny::br(), 
    
    shiny::column(
      width = 6, 
      shiny::actionButton(
        class = "btn btn-danger", 
        style = "padding: 15px 32px;", 
        inputId = "report_out_btn", 
        label = "Click to Report Tests Out of Stock", 
        width = "100%"
      )
    )
    
  ), 
  
  shiny::hr(), 
  
  shiny::fluidRow(
    
    shiny::column(
      width = 12,
      reactable::reactableOutput(outputId = "table")
    )
    
  )
  
)