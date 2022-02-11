

# Load packages
library(shiny)   # web apps
library(bslib)   # bootstrap UI tools
library(reactable)   # interactive tables
library(lubridate)   # working with dates
library(googleway)   # Google API handling
library(mongolite)   # MongoDB API handling
library(config)   # manage credentials in YAML
library(stringr)   # string manipulation

# Get MongoDB configuration parameters
config <- config::get(file = "config.yml")
