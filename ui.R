library(shiny)
library(DT)

# Define UI for app that draws a histogram ----
ui <- fluidPage(
    
    # App title ----
    titlePanel("US Research/Health to Tribe PPE & Chemical inventory"),
    
    # Sidebar layout main info and table ----
    fluidRow(
        # Sidebar panel for inputs ----
        column(2,
            # Main info ----
            helpText("We are a group of researchers contacting labs throughout the US", 
                     "with surplus supplies of personal protective equipment and", 
                     "chemicals to donate to tribal clinics and governments in need during",
                     "the COVID-19 pandemic.",
                     br(), br(),
                     tags$b("If you have PPE or chemicals to donate,"),
                     tags$b("please fill in the following form"),
                     a("https://bit.ly/3dEQwoY", href = "https://bit.ly/3dEQwoY"),
                     br(), br(),
                     "Tribal representatives, tribal clinic staff, and IHS staff: to request access to the contact information for one of",
                     "the records in this table, please send an email to",
                     a("matt.z.anderson@gmail.com", href = "mailto:matt.z.anderson@gmail.com"))            
        ),
        
        # Main data ----
        column(10,
            # Main table
            DT::DTOutput("tbl"),
            hr(),
            # Additional information
            # shiny::textOutput("contact", inline = FALSE)
            uiOutput("contact")
        )
    )
)