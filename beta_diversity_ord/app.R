# Beta Diversity Shiny App

library(shiny)
library(drake)
library(phyloseq)

# Read in Data
loadd(ps_filt)

# UI ----------------------------------------------------
ui <- fluidPage(# Application title
    titlePanel("Beta Diveristy Ordination"),
    
    # Sidebar with a inputs
    sidebarLayout(
        sidebarPanel(
            # Which ordination to perform
            selectInput(
                "ord",
                "Choose Ordination:",
                choices = c("DCA", "CCA", "RDA", "CAP", "DPCoA", "NMDS", "MDS", "PCoA"),
                selected = "NMDS"
                
            ),
            # Which Body Sites to include
            checkboxGroupInput(
                inputId = "body_sites",
                label = "Choose Body Sites:",
                choices = c("Nares", "Oropharynx", "Inguinal",
                            "Perianal", "Abscess"),
                selected = "Nares"
            ),
            # Use read counts or ASV relative abundance?
            radioButtons(
                inputId = "counts_or_relabun",
                label = "Use read counts or ASV relative abundance?",
                choices = c("Read Counts",
                            "Relative Abundance")
            ),
            
            # Action button for above computation
            actionButton(inputId = "run_ord",
                         label = "Run Ordination")
        ), 
    
        
        # Show ordination plot
        mainPanel(plotOutput("ord_plot"))
    ))


# Server ----------------------------------------------
server <- function(input, output) {

    # Ordination Data
    ps_data <- eventReactive(input$run_ord, {
        
        # Select Body sites
        ps_body <- eval(rlang::expr(subset_samples(ps_filt, Body_Site %in% !!input$body_sites)))
        
        # Convert to relative abundance?
        if (input$counts_or_relabun == "Relative Abundance"){
            transform_sample_counts(ps_body, function(x) x / sum(x) * 100)
        } else {
            ps_body
        }
    })
    
    # Run Ordination
    ord_data <- eventReactive(input$run_ord,{
        ordinate(ps_data(), input$ord)
    })
    
    # Plot Ordination
    output$ord_plot <- renderPlot({
        plot_ordination(ps_data(), ord_data(), type = "sample", color = "Body_Site")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
