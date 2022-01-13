

# Load packages
library(shiny)   # web apps
library(bslib)   # bootstrap UI tools
library(reactable)   # interactive tables
library(lubridate)   # working with dates
library(googleway)   # Google API handling
library(mongolite)   # MongoDB API handling
library(config)   # manage credentials in YAML
library(stringr)   # string manipulation

# Setup environmental variables
Sys.setenv(
  GOOGLE_KEY = readLines("google.txt", warn = FALSE),   # Google API key
  R_CONFIG_ACTIVE = "default",   # need this for MongoDB
  MONGO_DB = "ct_covid_tests",   # Mongo database name
  MONGO_COLLECTION = "test_data"   # Mongo collection name
)

# Get MongoDB configuration parameters
config <- config::get(file = "config.yml")
