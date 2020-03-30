library(readr)
library(glue)
library(dplyr)
library(googledrive)
library(googlesheets4)

# Set up credentials
readRenviron(".Renviron")
sheets_deauth()
#sheets_auth_configure(api_key = Sys.getenv("GARGLE_API"))
sheets_auth_configure(api_key='AIzaSyDO_e19HlbDtW2SloEuY8mcUfmEEX3Z4hc')

# Import data from Google Form----
gg_url <- "https://docs.google.com/spreadsheets/d/1gkVt6m2-lpxa3Q_Mj_ZrxAnNlezQztOQXFlzevHu1KA"
col_names <- c("State", "Institution", "N95 Masks", "Surgical Masks", 
               "Nitrile Gloves (# boxes)", "Vinyl Gloves (# boxes)", 
               "Gowns", "Ethanol (Litres)", "Other Alcohols (Litres)",
               "Face Shields", "Goggles", "Wipes (# Packages)", "Other", 
               "OtherSpec", "Centralised?", "CentralContact",  
               "DoYouWantToCoordinate","AdditionalInfo",'AreResourcesAvailable')
col_types <- paste0(c(rep("-", 4),
                      rep("c", 19)),
                    collapse = "")
form_data <- googlesheets4::read_sheet(gg_url,
                                       col_types = col_types)
names(form_data) <- col_names

# Replace NA by None
form_data <- mutate_at(form_data, vars(`N95 Masks`:Other),
                       function(col) if_else(is.na(col), "None", col)) %>% 
    mutate(`Centralised?` = if_else(is.na(`Centralised?`),
                                    "No", `Centralised?`))

#form_data <- readr::read_csv("test_data.csv")

# Separate data into 2 pieces
# 1. Contact and additional info on the side
# 2. The rest in a table
side_data_colnames <- c(
    "Email", "Name", "PhoneNumber",
    "OtherSpec", "CentralContact",
    "AdditionalInfo", "DoYouWantToCoordinate"
)

side_data <- form_data[,which(colnames(form_data) %in% side_data_colnames)]
main_data <- form_data[,which(!colnames(form_data) %in% side_data_colnames)]

# Transform to factors
main_data <- mutate_at(main_data, vars(-Institution),
                       as.factor)

server <- function(input, output) {
    
    # Interactive data with main data----
    output$tbl = DT::renderDT(
        main_data, 
        options = list(lengthChange = FALSE,
                       scrollX = TRUE,
                       autoWidth = TRUE,
                       columnDefs = list(list(width = '100px', 
                                              targets = seq_len(11) - 1))),
        rownames = NULL,
        selection = "single",
        filter = 'top'
    )
    
    default_info <- "<h3>Select a row to see additional information (if applicable).</h3>"
    additional_info <- paste0("<h3>Additional Information</h3>",
                              "<p>{OtherSpec}</p>")
    
    
    output$contact = renderUI({
        if (is.null(input$tbl_rows_selected)) {
            tags$div(HTML(default_info))
        } else {
            subset_data <- side_data[input$tbl_rows_selected,]
            if (is.na(subset_data$OtherSpec)) {
                tags$div(HTML("<h3>No Additional Information</h3>"))
            } else {
                tags$div(HTML(with(subset_data, 
                                   glue::glue(additional_info))))
            }
        }
        })
}