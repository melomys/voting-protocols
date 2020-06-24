#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(tidyverse)
library(reshape2)
library(DT)
source("src/shiny_helpers.r")

callback = "function(table) {
      table.on('click.dt', 'tr', function() {
            table.$('tr.selected').removeClass('selected');
            $(this).toggleClass('selected');            
        Shiny.onInputChange('rows',
                            table.rows('.selected').data()[0][0]);
      });
    }"

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Voting"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
                selectInput("model_id",
                        "Model ID:",
                        choices = df[,"model_id"] )
                
        ),
        

        # Show a plot of the generated distribution
        mainPanel(
            dataTableOutput("model_table"),
            tableOutput("tmp"),
           plotOutput("modelScorePlot"),
           plotOutput("modelVotePlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$model_table <- DT::renderDataTable({
        model <- df  %>% 
            select("model_id" | "model_type" | "scoring_function" | "user_rating_function")
        model
    }, server = FALSE,
    selection = 'single')
    
    output$tmp <- renderTable({
        
        s <- input$model_table_rows_selected[1]
        
        model <- df[s,] %>% 
            select("model_id" | "model_type" | "scoring_function" | "user_rating_function")
        
        model
        }
    )

    output$modelScorePlot <- renderPlot({
        
        s <- input$model_table_rows_selected[1]
        
        id = df[[s,"model_id"]]
        
        model_score_df <- model_dfs %>%
            filter(model_id == id) %>% 
            select(starts_with("step") | starts_with("score")) 
        
        model_score_df %>%
            melt(id.vars = "step", variable.name = "posts") %>% 
            ggplot() + 
            aes(x = step, y= value, colour = posts) + 
            theme(legend.position = "none") +
            geom_line()
    })
    
    output$modelVotePlot <- renderPlot({
        
        s <- input$model_table_rows_selected[1]
        
        id = df[[s,"model_id"]]
        
        
        relative_votes_model_df <- model_dfs %>%
            filter(model_id == id) %>% 
            select(starts_with("step") | starts_with("votes")) %>% 
            relative_post_data()
        
        relative_votes_model_df %>% 
            melt(id.vars = "step", variable.name = "posts") %>% 
            ggplot() + 
            aes(x = step, y = value, colour = posts) + 
            theme(legend.position = "none") + 
            geom_line()
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
