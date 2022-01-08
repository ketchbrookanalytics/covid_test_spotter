


about_ui <- shiny::tagList(
  
  shiny::fluidRow(
    
    shiny::column(
      width = 12, 
      
      shiny::div(
        class = "jumbotron", 
        shiny::h1("PLEASE NOTE:"), 
        
        shiny::h4(
          style = "color: black;", 
          "
          This website application does not use any data from state or local sources. 
          Instead, it relies ENTIRELY on the data submitted by you, the users. 
          "
        ), 
        
        shiny::h4(
          style = "color: black;", 
          "Because of this, we make ABSOLUTELY NO guarantees about the accuracy of the information."
        ), 
        
        shiny::h4(
          style = "color: black;", 
          "
          Additionally, this website application is for reporting of AT-HOME COVID-19 tests only. 
          There are many other resources already available for locating COVID-19 testing sites.
          "
        ), 
        
        shiny::p(
          class = "lead", 
          "Please refer to the State of Connecticut's Website for more information around COVID-19."
        ), 
        shiny::a(
          class = "btn btn-info btn-lg", 
          href = "https://portal.ct.gov/Coronavirus/", 
          target = "_blank", 
          "State of CT Website"
        )
      )
      
    )
    
  )
  
)