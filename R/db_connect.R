


# Function to connect to a specific MongoDB Atlas database collection
mongo_connect <- function(collection, database, creds) {
  
  mongolite::mongo(
    collection = collection, 
    url = stringr::str_glue(
      "mongodb+srv://{creds$username}:{creds$password}@{creds$host}/{database}"
    ), 
    options = mongolite::ssl_options(weak_cert_validation = T)
  )
  
}

get_data <- function(creds) {
  
  # Build the connection to the database collection
  mongo_connection <- mongo_connect(
    collection = "test_data", 
    database = "ct_covid_tests", 
    creds = creds
  )
  
  mongo_connection$find(limit = 20)
  
}



# Function to insert a new record into a specific MongoDB Atlas database 
# collection
add_record <- function(data, creds) {
  
  # Build the connection to the database collection
  mongo_connection <- mongo_connect(
    collection = "test_data", 
    database = "ct_covid_tests", 
    creds = creds
  )
  
  if (data$place_id %in% mongo_connection$find()$place_id) {
    
    query_str <- paste0(
      '{\"place_id\":\"', data$place_id[1], '\"}'
    )
    
    update_str <- paste0(
      '{\"$set\":{', 
      '\"brand\": \"', data$brand[1], '\"', 
      ', \"inventory\": \"', data$inventory[1], '\"', 
      ', \"date\": \"', data$date[1], '\"', 
      ', \"time\": \"', data$time[1], '\"}}'
    )
    
    mongo_connection$update(
      query = query_str, 
      update = update_str
    )
    
  } else {
    
    mongo_connection$insert(data)
    
  }
  
}


remove_record <- function(data, creds) {
  
  # Build the connection to the database collection
  mongo_connection <- mongo_connect(
    collection = "test_data", 
    database = "ct_covid_tests", 
    creds = creds
  )
  
  data$date <- as.Date(data$date)
  data$time <- factor(
    data$time, 
    levels = c("Morning", "Afternoon", "Evening"), 
    ordered = TRUE
  )
  
  db_data <- mongo_connection$find()
  
  
  if (data$place_id %in% mongo_connection$find()$place_id) {
    
    query_str <- paste0(
      '{\"place_id\":\"', data$place_id[1], '\"}'
    )
    
    db_data <- mongo_connection$find(
      query = query_str
    )
    
    # Ensure the date/time submitted for removal is more recent than what's in the database
    if (all(c(data$date[1] >= db_data$date[1], data$time[1] >= db_data$time[1]))) {
      
      mongo_connection$remove(
        query = query_str
      )
      
    }
    
  }
  
}



