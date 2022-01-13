


# Execute the following R scripts
source("global.R")
source("R/home_ui.R")
source("R/about_ui.R")
source("R/report_ui.R")
source("R/db_connect.R")


# Build the Nav Bar at the top of the web page
nav_items <- function() {
  
  list(
    bslib::nav(title = "Home", home_ui, value = "home_id"), 
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


# Build the app UI
ui <- bslib::page_navbar(
  id = "nav_bar_id", 
  title = "CT COVID-19 At-Home Test Spotter", 
  
  # Customize bootstrap theme
  theme = bslib::bs_theme(
    bootswatch = "cerulean",
    fg = "#0B2B7C",  # State of CT crest blue
    bg = "#FFFFFF"   # white
  ), 
  
  # Customize the appearance of date input & drop-down selection widgets
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


# Build the app server
server <- function(input, output, session) {

  # Get most recent data from the MongoDB database collection
  data <- shiny::reactive({
    get_data(creds = config)
  })
  
  # Create the interactive table showing the data
  output$table <- reactable::renderReactable({
    reactable::reactable(
      data(), 
      filterable = TRUE, 
      showSortable = TRUE,
      defaultSorted = list(date = "desc"), 
      language = reactable::reactableLang(filterPlaceholder = "Search..."), 
      columns = list(
        place_id = reactable::colDef(show = FALSE), 
        name = reactable::colDef(name = "Name"), 
        address = reactable::colDef(
          name = "Address", sortable = FALSE, 
          cell = function(value) {
            stringr::str_replace(
              string = value, 
              pattern = ", USA$",   # remove ", USA" from end of address
              replacement = ""
            )
          }
        ), 
        lat = reactable::colDef(show = FALSE), 
        lon = reactable::colDef(show = FALSE), 
        brand = reactable::colDef(name = "Brand"), 
        inventory = reactable::colDef(name = "Inventory"), 
        date = reactable::colDef(
          name = "Date", filterable = FALSE, 
          format = reactable::colFormat(date = TRUE, locales = "en-US")
        ), 
        time = reactable::colDef(name = "Time", filterable = FALSE)
      )
    )
  })
  
  # Welcome the user in a prompt
  shiny::modalDialog(
    title = "Welcome!", 
    "This website application is meant to help Connecticut residents locate & report at-home COVID-19 tests at retail locations.", 
    shiny::br(), 
    shiny::br(), 
    "The table on this page shows the most recently spotted COVID-19 at-home tests.", 
    shiny::br(), 
    shiny::br(), 
    "The buttons above the table allow you to report where/when you saw at-home tests in stock, or where/when you saw at-home tests out of stock.", 
    shiny::br(), 
    shiny::br(), 
    "Please read the \"About\" page for more information on how this website application works.", 
    easyClose = TRUE
  ) |> 
    shiny::showModal()
  
  # Create the interactive & searchable Google map widget for "Tests In Stock" 
  output$map_in <- googleway::renderGoogle_map({
    googleway::google_map(
      key = Sys.getenv("GOOGLE_KEY"),
      search_box = TRUE,
      event_return_type = "list", 
      location = c(41.763710, -72.685097),   # coords for Hartford, CT
      map_type_control = FALSE, 
      street_view_control = FALSE
    )
  })
  
  # Capture the full address of the place selected by the user from the "Tests 
  # in Stock" Google map
  output$selected_address_in <- shiny::renderText({
    
    shiny::req(input$map_in_place_search$address)
    
    paste0("Address Selected: ", input$map_in_place_search$address)
    
  })
  
  # Create the interactive & searchable Google map widget for "Tests Out of Stock" 
  output$map_out <- googleway::renderGoogle_map({
    googleway::google_map(
      key = Sys.getenv("GOOGLE_KEY"),
      search_box = TRUE,
      event_return_type = "list", 
      location = c(41.763710, -72.685097), 
      map_type_control = FALSE, 
      street_view_control = FALSE
    )
  })
  
  # Capture the full address of the place selected by the user from the "Tests 
  # Out of Stock" Google map
  output$selected_address_out <- shiny::renderText({
    
    shiny::req(input$map_out_place_search$address)
    
    paste0("Address Selected: ", input$map_out_place_search$address)
    
  })
  
  # When the "Report Tests In Stock" button is clicked...
  shiny::observeEvent(input$report_in_btn, {

    # ... jump to the "Report Tests In Stock" page
    bslib::nav_select(
      id = "nav_bar_id", 
      selected = "nav_report_in"
    )

  })

  # When the "Report Tests Out of Stock" button is clicked...
  shiny::observeEvent(input$report_out_btn, {

    # ... jump to the "Report Tests Out of Stock" page
    bslib::nav_select(
      id = "nav_bar_id", 
      selected = "nav_report_out"
    )

  })
  
  # When the first "Submit" button is clicked (below the drop-down widgets) on 
  # the "Report Tests In Stock" page...
  shiny::observeEvent(input$submit_in_draft_btn, {
    
    # Check if any invalid inputs were provided, including if the location 
    # chosen is a *full* address located in CT
    check <- any(
      nchar(trimws(input$select_brand_in)) == 0, 
      nchar(trimws(input$select_inventory_in)) == 0, 
      nchar(trimws(input$select_date_in)) == 0, 
      nchar(trimws(input$select_time_in)) == 0, 
      length(input$map_in_place_search) == 0, 
      # "CT" must be in the address
      stringr::str_detect(
        string = input$map_in_place_search$address, 
        pattern = "CT", 
        negate = TRUE
      ), 
      # the address must start with a number 
      stringr::str_starts(
        string = input$map_in_place_search$address, 
        pattern = "^[0-9]", 
        negate = TRUE
      )
    )
    
    # If any of the "checks" were TRUE...
    if (any(check)) {
      
      # ... prompt the user to fix their inputs
      modal <- shiny::modalDialog(
        title = "Oops!", 
        "It looks like you forgot something...", 
        shiny::br(), 
        shiny::br(), 
        "Please ensure you chose an option from each drop down menu, and selected a retail location in Connecticut from the map.", 
        shiny::br(), 
        shiny::br(), 
        shiny::em("Note: The address selected from the map (and shown above the map) must be a specific retail location with a street number (e.g., \"Hartford, CT, USA\" is not a valid choice)"), 
        footer = shiny::modalButton(
          label = "Go Back"
        )
      )
      
      # if the "checks" were all FALSE (i.e., all inputs were valid)...
    } else {
      
      # ... prompt the user to verify the information provided, then submit if 
      # it appears correct
      modal <- shiny::modalDialog(
        title = "Please Review the Information Provided", 
        
        shiny::tagList(
          shiny::p(
            "By clicking \"Submit\", you verify that the following information about the COVID-19 at-home tests you saw in stock is correct to the best of your knowledge:"
          ), 
          shiny::br(), 
          shiny::p(
            "Brand:", 
            shiny::strong(input$select_brand_in)
          ), 
          shiny::p(
            "Inventory (Amount):", 
            shiny::strong(input$select_inventory_in)
          ), 
          shiny::p(
            "Date:", 
            shiny::strong(format(as.Date(input$select_date_in), "%A, %B %d, %Y"))
          ), 
          shiny::p(
            "Time of Day:", 
            shiny::strong(input$select_time_in)
          ), 
          shiny::p(
            "Location Name:", 
            shiny::strong(input$map_in_place_search$name)
          ), 
          shiny::p(
            "Address:", 
            shiny::strong(input$map_in_place_search$address)
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
    
    # Launch the appropriate modal
    shiny::showModal(modal)
    
  })
  
  # When the first "Submit" button is clicked (below the drop-down widgets) on 
  # the "Report Tests Out of Stock" page...
  shiny::observeEvent(input$submit_out_draft_btn, {
    
    # Check if any invalid inputs were provided, including if the location 
    # chosen is a *full* address located in CT
    check <- any(
      nchar(trimws(input$select_date_out)) == 0, 
      nchar(trimws(input$select_time_out)) == 0, 
      length(input$map_out_place_search) == 0, 
      # "CT" must be in the address
      stringr::str_detect(
        string = input$map_in_place_search$address, 
        pattern = "CT", 
        negate = TRUE
      ), 
      # the address must start with a number 
      stringr::str_starts(
        string = input$map_in_place_search$address, 
        pattern = "^[0-9]", 
        negate = TRUE
      )
    )
    
    # If any of the "checks" were TRUE...
    if (any(check)) {
      
      # ... prompt the user to fix their inputs 
      modal <- shiny::modalDialog(
        title = "Oops!", 
        "It looks like you forgot something...", 
        shiny::br(), 
        shiny::br(), 
        "Please ensure you chose an option from each drop down menu, and selected a retail location in Connecticut from the map.", 
        shiny::br(), 
        shiny::br(), 
        shiny::em("Note: The address selected from the map (and shown above the map) must be a specific retail location with a street number (e.g., \"Hartford, CT, USA\" is not a valid choice)"), 
        footer = shiny::modalButton(
          label = "Go Back"
        )
      )
      
      # if the "checks" were all FALSE (i.e., all inputs were valid)...
    } else {
      
      # ... prompt the user to verify the information provided, then submit if 
      # it appears correct
      modal <- shiny::modalDialog(
        title = "Please Review the Information Provided", 
        
        shiny::tagList(
          shiny::p(
            paste0(
              "By clicking \"Submit\", you verify that the following information", 
              " about the COVID-19 at-home tests you found to be out of stock is", 
              " correct to the best of your knowledge (and that you have checked", 
              " the table on the \"Home\" page to ensure there is not a more", 
              " recent update than yours):"
            )
          ), 
          shiny::br(), 
          shiny::p(
            "Date:", 
            shiny::strong(format(as.Date(input$select_date_out), "%A, %B %d, %Y"))
          ), 
          shiny::p(
            "Time of Day:", 
            shiny::strong(input$select_time_out)
          ), 
          shiny::p(
            "Location Name:", 
            shiny::strong(input$map_out_place_search$name)
          ), 
          shiny::p(
            "Address:", 
            shiny::strong(input$map_out_place_search$address)
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
    
    # Launch the appropriate modal
    shiny::showModal(modal)
    
  })
  
  
  # If the final "Submit" button is clicked on the "Reports In Stock" page...
  shiny::observeEvent(input$submit_in_final_btn, {
    
    # ... build a data frame containing the user's inputs & selectd map data
    df <- tibble::tibble(
      place_id = input$map_in_place_search$place_id, 
      name = input$map_in_place_search$name, 
      address = input$map_in_place_search$address, 
      lat = input$map_in_place_search$lat, 
      lon = input$map_in_place_search$lon, 
      brand = input$select_brand_in, 
      inventory = input$select_inventory_in, 
      date = input$select_date_in, 
      time = input$select_time_in
    )
    
    # Add (or update) the record to the MongoDB database collection
    add_record(
      data = df, 
      creds = config
    )
    
    # Remove the open modal
    shiny::removeModal()
    
    # Jump back to the "Home" page
    bslib::nav_select(
      id = "nav_bar_id", 
      selected = "home_id"
    )
    
    # Launch a new modal thanking them for their submission
    shiny::modalDialog(
      title = "Thank You for Your Submission!", 
      "To see your changes reflected on the \"Home\" page, you will need to refresh your browser"
    ) |> 
      shiny::showModal()
    
  })
  
  # If the final "Submit" button is clicked on the "Reports Out of Stock" page...
  shiny::observeEvent(input$submit_out_final_btn, {
    
    # ... build a data frame containing the user's inputs & selectd map data
    df <- tibble::tibble(
      place_id = input$map_out_place_search$place_id, 
      date = input$select_date_out, 
      time = input$select_time_out
    )
    
    # Remove the record from the MongoDB database collection
    remove_record(
      data = df,
      creds = config
    )
    
    # Remove the open modal
    shiny::removeModal()
    
    # Jump back to the "Home" page
    bslib::nav_select(
      id = "nav_bar_id", 
      selected = "home_id"
    )
    
    # Launch a new modal thanking them for their submission
    shiny::modalDialog(
      title = "Thank You for Your Submission!", 
      "To see your changes reflected on the \"Home\" page, you will need to refresh your browser"
    ) |> 
      shiny::showModal()
    
  })
  
}

# Run the app
shiny::shinyApp(ui, server)
