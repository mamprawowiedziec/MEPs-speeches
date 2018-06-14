

library(shiny)
library(DT)
library(devtools)
library(tidyverse)
library(pool)
library(lubridate)
#library(rvest)
#library(readr)
library(shinyjs)
#library(shinyFilters)
library(stringr)

#library(DBI)


if(!require(tidyverse)) install.packages("tidyverse")
library(tidyverse)

if(!require(pool)) install.packages("pool")
library(pool)

if(!require(lubridate)) install.packages("lubridate")
library(lubridate)

if(!require(shinyjs)) install.packages("shinyjs")
library(shinyjs)

if(!require(DBI)) install.packages("DBI")
library(DBI)

# if(!require(shinycssloaders)) install.packages("shinycssloaders")
# library(shinycssloaders)

# if(!require(europarl)) install_github("rOpenGov/europarl")
# library(europarl)

if(!require(shinyBS)) install.packages("shinyBS")
library(shinyBS)




source("functions.R")

cat('start\n')

config <- as.data.frame(read_config())

pool <- dbPool(
  drv = RMySQL::MySQL(),
  dbname = config$value[1],
  host = config$value[2],
  username = config$value[3],
  password = config$value[4]
)



conn <- poolCheckout(pool)
dbSendQuery(conn, "SET NAMES utf8;")
# do something with conn
lang <- dbGetQuery(conn, 'SELECT * FROM languages')
lang$id <- str_sub(lang$id, 1, 2)
lang$full_name <- str_sub(lang$full_name,2, length(lang$full_name) - 1)
terms <-dbGetQuery(conn, "SELECT DISTINCT term FROM term_of_office WHERE term >= '6';")
poolReturn(conn)


#poolReturn(conn)
onStop(function() {

  killDbConnections()
})

# ===========================




cat('start load filter/start options\n')

 load("./data/filter_options_8.Rda")
# 
 load("./data/start_options_8.Rda", verbose = TRUE,.GlobalEnv)

cat('end load\n')

# variables 


text_about <- paste0("The interactive database MEPs' Speeches in Plenary is designed to help journalists, experts, activists, 
and citizens track political debates in the European Parliament. <br>
                     The MEPs' Speeches in Plenary collects and allows to browse through MEPs
                     plenary statements of the 2014-2019 term (both in speech and in writing). 
                     The main functionality is filtering MEPs statements using keywords (e.g. 'migration', 'energy union', etc.).
                     The tool allows filtering the statements also by date, party or fraction.
                     The results of a query can be downloaded to .csv files and visualised on graphs and charts. 
                     Soon the tool will collect data also from the two previous terms to allow tracking MEPs' statements since the 2004 enlargement of the EU. <br>",
                    
                    
                    "The interactive database has been developed by <a target='_blank' href='https://mamprawowiedziec.pl/'> MamPrawoWiedziec.pl </a>
                    in cooperation with the <a target='_blank' href='https://github.com/mi2-warsaw'> MI^2 </a> group lead by Przemysław Biecek, 
                    a data scientist and professor at the University of Warsaw and the Warsaw University of Technology.
                    It has been created in R and R/Shiny. <br>
                    <br>
                    
                    <a target='_blank' href='https://mamprawowiedziec.pl/'> MamPrawoWiedziec.pl </a>, run by Association 61 based in Warsaw, is a non-partisan web portal 
                    publishing political analyses and maintaining the largest database of Polish officials. 
                    Its editorial team collects data about Polish politicians: their bios, opinions, declarations of assets, 
                    promises and political activities. <br>
                    <a target='_blank' href='https://github.com/mi2-warsaw'> MI^2 </a> is a group of students and graduates of MiNI PW and MIM UW, 
                    interested in data analysis, large data, complex data, bio-med data.
                    <br> <br>
                    The MEPs' Speeches in Plenary was created as part of the 
                    Closer to V4 Policy project funded by the 
                    <a target='_blank' href='https://www.visegradfund.org/'> International Visegrad Fund </a>.<br>"
)
