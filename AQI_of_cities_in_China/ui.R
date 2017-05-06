#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)

if(!require(shinyjs))
{
    install.packages("shinyjs")
}
library(shinyjs)

sourceDir <- getSrcDirectory(function(dummy) {dummy})
setwd(sourceDir)


source("global.R")
# Define UI for application that draws a histogram
shinyUI(fluidPage(
    useShinyjs(),
  # Application title
  titlePanel("AQI data of cities in China"),
  
  # Sidebar with a slider input for number of bins 
  sidebarPanel(
      selectInput(inputId="Cityname", "Which city",
                  Citynames_UI),
      actionButton(inputId="compare", label="Compared to"),
      disabled(selectInput(inputId="Cityname_compare", "Which city",
                  Citynames_UI)),
      radioButtons(inputId="AVG_option", label="Average choice", 
                   choices = ratiobutton_names_UI),
      radioButtons(inputId="Component_option", label="AQI component", 
                   choices = AQI_components_UI),
      dateInput("AQI_date", "Date:")  
  ),
  mainPanel(
      h4('Data of chosen date'),
      verbatimTextOutput("AQI_date_output"),
      h4('All data'),
      tableOutput("data_AQI_table"),
      plotlyOutput("plot")
  )
))
