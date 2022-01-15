


# Function to connect to a specific MongoDB Atlas database collection
mongo_connect <- function(collection, database, creds) {
  
  mongolite::mongo(
    collection = collection, 
    url = stringr::str_glue(
      "mongodb+srv://{creds$username}:{creds$password}@{creds$host}/{database}"
    )
  )
  
}



# Function to retrieve data from MongoDB database collection
get_data <- function(creds) {
  
  # Build the connection to the database collection
  mongo_connection <- mongo_connect(
    collection = Sys.getenv("MONGO_COLLECTION"), 
    database = Sys.getenv("MONGO_DB"), 
    creds = creds
  )
  
  # Return the top 20 results after sorting by date (descending)
  mongo_connection$find(
    sort = '{"date" : -1}', 
    limit = 20
  )
  
}



# Function to insert a new record into a specific MongoDB Atlas database 
# collection
add_record <- function(data, creds) {
  
  # Build the connection to the database collection
  mongo_connection <- mongo_connect(
    collection = Sys.getenv("MONGO_COLLECTION"), 
    database = Sys.getenv("MONGO_DB"), 
    creds = creds
  )
  
  # If the "place_id" being added already exists in the MongoDB collection...
  if (data$place_id %in% mongo_connection$find()$place_id) {
    
    # Create the 'query' argument string
    query_str <- paste0(
      '{\"place_id\":\"', data$place_id[1], '\"}'
    )
    
    # Create the 'update' argument string
    update_str <- paste0(
      '{\"$set\":{', 
      '\"brand\": \"', data$brand[1], '\"', 
      ', \"inventory\": \"', data$inventory[1], '\"', 
      ', \"date\": \"', data$date[1], '\"', 
      ', \"time\": \"', data$time[1], '\"}}'
    )
    
    # Update the record that matches the "place_id" being added, so that we 
    # don't have multiple records in the database representing the same place
    mongo_connection$update(
      query = query_str, 
      update = update_str
    )
    
  } else {
    
    # If the "place_id" being added does *not* exist in the database, add the 
    # new record
    mongo_connection$insert(data)
    
  }
  
}


# Function to remove a record from a specific MongoDB Atlas database collection, 
# conditional on if the "place_id" already exists in the collection
remove_record <- function(data, creds) {
  
  # Build the connection to the database collection
  mongo_connection <- mongo_connect(
    collection = Sys.getenv("MONGO_COLLECTION"), 
    database = Sys.getenv("MONGO_DB"), 
    creds = creds
  )
  
  # Format the "date" and "time" in the input data appropriately for removal 
  # decision logic downstream
  data$date <- as.Date(data$date)
  data$time <- factor(
    data$time, 
    levels = c("Morning", "Afternoon", "Evening"), 
    ordered = TRUE
  )
  
  # If the "place_id" being removed already exists in the Mongo database 
  # collection...
  if (data$place_id %in% mongo_connection$find()$place_id) {
    
    # Create the 'query' argument string to find the specified "place_id" value
    query_str <- paste0(
      '{\"place_id\":\"', data$place_id[1], '\"}'
    )
    
    # Return the data from the collection that matches the "place_id"
    db_data <- mongo_connection$find(
      query = query_str
    )
    
    # Format the "date" and "time" in the database data appropriately for 
    # removal decision logic downstream in next step
    db_data$date <- as.Date(db_data$date)
    db_data$time <- factor(
      db_data$time, 
      levels = c("Morning", "Afternoon", "Evening"), 
      ordered = TRUE
    )
    
    # Ensure the date/time submitted for removal is more recent than what's in 
    # the database
    
    # If the date is more recent than what's in the database, immediately remove
    # the relevant "place_id" record
    if (data$date[1] > db_data$date[1]) {
      
      # Remove the item the collection matching the "place_id"
      mongo_connection$remove(
        query = query_str
      )
      
    } else {
      
      # If the date is equivalent to what's in the database for that "place_id", 
      # remove the record if the time of day is more recent
      if (all(c(data$date[1] == db_data$date[1], data$time[1] > db_data$time[1]))) {
        
        # Remove the item the collection matching the "place_id"
        mongo_connection$remove(
          query = query_str
        )
        
      }
      
    }
    
  }
  
}
