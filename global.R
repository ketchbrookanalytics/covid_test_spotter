


library(shiny)
library(bslib)
library(reactable)
library(lubridate)
library(googleway)
library(mongolite)
library(config)

# Configure MongoDB
Sys.setenv(R_CONFIG_ACTIVE =  "default")
config <- config::get(file = "config.yml")

# Configure Google Places API
g_key <- readLines("google.txt")

# data <- data.frame(
#   place_id = c("asdlfkj12309", "ghasdf0356", "j203kfjsjow"), 
#   name = c("Walgreens", "Big Y", "Costco"), 
#   address = c(
#     "10 Main Street, Ellington, CT, USA", 
#     "55 Elm Drive, Vernon, CT, USA", 
#     "99 Arbor Circle, Manchester, CT, USA"
#   ), 
#   lat = rnorm(n = 3, mean = 41, sd = 0.2), 
#   lon = rnorm(n = 3, mean = -72, sd = 0.2), 
#   brand = c("BinaxNOW", "QuickVue", "Flowflex"), 
#   inventory = c("High", "Low", "Not Sure"), 
#   date = Sys.Date() |> as.character(), 
#   time = c(
#     "Morning", 
#     "Evening", 
#     "Afternoon"
#   )
# )
