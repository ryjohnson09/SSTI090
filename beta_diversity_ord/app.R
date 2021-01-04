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
            
            # Which days to include
            checkboxGroupInput(
                inputId = "days",
                label = "Select visit days:",
                choices = c("0", "14", "28", "56", "90"),
                selected = c("0", "14", "28", "56", "90")
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
                         label = "Run Ordination"),
            
            hr(),
            
            # Customize Plot
            selectInput(inputId = "color_by",
                        label  = h4("Color points by:"),
                        choices = c("Body Site" = "Body_Site",
                                    "Day" = "Day",
                                    "None" = "None")),
            
            selectInput(inputId = "shapes_by",
                        label  = h4("Apply Shapes to:"),
                        choices = c("Body Site" = "Body_Site",
                                    "Day" = "Day",
                                    "None" = "None")),
            
            selectInput(inputId = "ellipse_by",
                        label  = h4("Add Ellipses By:"),
                        choices = c("Body Site" = "Body_Site",
                                    "Day" = "Day",
                                    "None" = "None"), 
                        selected = "None"),
            
            sliderInput(inputId = "pointsize",
                        label = h4("Point Size"),
                        min = 0.5,
                        max = 5,
                        value = 2)
            
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
        
        # Select days
        ps_days <- eval(rlang::expr(subset_samples(ps_body, Day %in% !!input$days)))
        
        # Convert to relative abundance?
        if (input$counts_or_relabun == "Relative Abundance"){
            transform_sample_counts(ps_days, function(x) x / sum(x) * 100)
        } else {
            ps_days
        }
    })
    
    # Run Ordination
    ord_data <- eventReactive(input$run_ord,{
        ordinate(ps_data(), input$ord)
    })
    
    # Plot Ordination
    output$ord_plot <- renderPlot({
        
        # Shapes and Color
        if (input$color_by == "None" & input$shapes_by != "None"){
            
            ps_plot <- plot_ordination(ps_data(),
                                       ord_data(),
                                       type = "sample",
                                       shape = input$shapes_by
            )
        } else if (input$color_by != "None" & input$shapes_by == "None"){
            ps_plot <- plot_ordination(ps_data(),
                                       ord_data(),
                                       type = "sample",
                                       color = input$color_by)
        } else if (input$color_by == "None" & input$shapes_by == "None"){
            ps_plot <- plot_ordination(ps_data(),
                                       ord_data(),
                                       type = "sample")
        } else if (input$color_by != "None" & input$shapes_by != "None"){
            ps_plot <- plot_ordination(ps_data(),
                                       ord_data(),
                                       type = "sample",
                                       shape = input$shapes_by,
                                       color = input$color_by)
        } else {
            stop("Plot aesthetics not working")
        }
        
        # Ellipses
        if (input$ellipse_by != "None"){
            ps_plot_ellip <- ps_plot + stat_ellipse(aes_string(color = input$ellipse_by))
        } else {
            ps_plot_ellip <- ps_plot
        }
        
        # Plot size
        ps_plot_ellip +
            geom_point(size = input$pointsize)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
