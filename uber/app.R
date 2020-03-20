# load the required packages
library(shiny)
require(shinydashboard)
library(leaflet)
library(ggplot2)
library(dplyr)
library(ggthemes)
library(lubridate)
library(tidyr)
library(DT)
library(scales)


source("uber_analysis.R")

tolerance <- 3000 # max number to plot and perform k means clustering on
min_cl_num <- 5 # minimum number of clusters
max_cl_num <- 20 # maximum number of clusters

ui <- dashboardPage(
  
  dashboardHeader(title = "Uber rides analysis"),
  dashboardSidebar(
      sidebarMenu(
      menuItem("Map View", tabName = "dashboard", icon = icon("map")),
      menuItem("More",tabName = "more", icon = icon("chart-bar"))
  )),
  
  
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",fluidRow(
          
        box(leafletOutput("map"),width = 7, tags$style(type = "text/css", "#map {height: calc(80vh - 150px) !important;}")),
        box(title = "Inputs", status = "warning", solidHeader = TRUE,width = 5,h4("K-means clustering analysis varying over the date"),
            
            sliderInput("slider", "Date Index:",
                        value = 1, min = 1, max = 184),
            
            sliderInput("kmc", "Number of Clusters:",
                        value = min_cl_num, min = min_cl_num, max = max_cl_num)),
        box(plotOutput("histhr")),
        )
      ),
      
      # Second tab content
      tabItem(tabName = "more",
              tabsetPanel(type = "tabs", 
                          tabPanel("Trips Count",
                                   fluidRow(
                                     box(title="Input",status ="primary" ,h2("View total trips by:"), solidHeader = TRUE,
                                         selectInput("wkd",h3("Week Days:"),c("Sun","Mon","Tue","Wed","Thu","Fri","Sat"),selected = NULL),
                                         selectInput("month",h3("Months:"),c("Apr","May" , "Jun" , "Jul" ,"Aug" ,"Sep"),selected = NULL)),
                                     
                                     valueBoxOutput("Total_wd_trips"),
                                     valueBoxOutput("Total_month_trips")
                                     #box(plotOutput("Trip_day_month"))
                                   )
                            ),
                          tabPanel("Plot",
                                   box(h2("Visualize by:"),width = 3,
                                  selectInput("visu",h3("select queries:"),c("Trips by day & month","Trips by day, hr & month")),
                                  conditionalPanel(
                                    condition = "input.visu ==  'Trips by day, hr & month'",
                                    selectInput("d",h3("select weekday for visualization"),
                                                c("Sun","Mon","Tue","Wed","Thu","Fri","Sat"))
                                  )
                                       ),
                                                   box(plotOutput("visu"),width = 9))
                          ),
            
            )
      )
    )
   
  )


############################SERVER#####################################
server <- shinyServer(function(input, output) {
  p=apr_to_sep_dat
  
  
  
  pal <- colorFactor( # define palette for points
    palette = "Dark2",
    domain = factor(p$hr_map))
  
  output$map = renderLeaflet({
    leaflet() %>%
      
      addProviderTiles(providers$CartoDB.Positron) %>% # layout
      
      addCircleMarkers(data = p[first_indices[input$slider]:(first_indices[input$slider]+
                                                               min(first_indices[(input$slider+1)]-first_indices[(input$slider)], tolerance)),], # adds start locations
                       lat = ~ Lat, lng = ~ Lon,
                       fillOpacity=1, 
                       radius=0.5,
                       color= ~pal(hr_map)) %>%
      
      addMarkers(data=data.frame(kmeans(p[first_indices[input$slider]:(first_indices[input$slider]+
                                                                         min(first_indices[(input$slider+1)]-first_indices[(input$slider)], tolerance)),c("Lat","Lon")],
                                        input$kmc)$centers),
                 lat = ~Lat, lng = ~ Lon,
                 label= ~ paste("Latitude:", round(Lat,3), "Longitude", round(Lon,3))) %>%
      
      addLegend("bottomright", pal = pal, values = p[first_indices[input$slider]:(first_indices[input$slider]+
                                                                                    min(first_indices[(input$slider+1)]-first_indices[(input$slider)], tolerance)),"hr_map"],
                title = paste("Date:", p[first_indices[input$slider],"Date"]),
                opacity = 1) %>%
      
      setView(lng = -73.98928, lat = 40.75042, zoom = 12) # sets zoom to be in NYC
  })

  
  output$histhr <- renderPlot({

    ggplot(data=data.frame(count(p[first_indices[input$slider]:(first_indices[input$slider]+
                                                                  min(first_indices[(input$slider+1)]-first_indices[(input$slider)], tolerance)),"hr_map"])), aes(x=x, y=freq,fill=I("red"),col=I("blue"))) +
      geom_bar(stat="identity", position="dodge", width=0.9, alpha=0.3)+
      theme(text = element_text(size = 11),
            axis.line = element_line(colour = "black"),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            plot.background = element_rect(fill = "grey92"))+ # Very important line - makes it look nice
      ggtitle(paste("Histogram of ride frequency for date:", p[first_indices[input$slider],"Date"]))

  })
  
  output$Total_wd_trips <- renderValueBox({
    
    #total Trips
    Total_wd_trips <- apr_to_sep_dat %>%
      group_by(dayofweek) %>% 
      dplyr::summarize(Total = n()) %>%
    filter(dayofweek==input$wkd) %>% select(Total)
     
    
    valueBox(
      formatC(Total_wd_trips, format="d", big.mark=','),
      paste('Total Trip on',input$wkd)
      ,icon = icon("stats",lib='glyphicon')
      ,color = "purple") 
  })
  
  
  output$Total_month_trips <- renderValueBox({
    
    #total Trips
    Total_month_trips <- apr_to_sep_dat %>%
      group_by(month) %>% 
      dplyr::summarize(Total = n()) %>%
      filter(month==input$month) %>% select(Total)
    
    
    valueBox(
      formatC(Total_month_trips, format="d", big.mark=','),
      paste('Total Trip on',input$month)
      ,icon = icon("stats",lib='glyphicon')
      ,color = "green") 
  })
  
  


  
    output$visu <- renderPlot({

      if("Trips by day & month" %in% input$visu){
        
        month_weekday <- apr_to_sep_dat %>%
          group_by(month, dayofweek) %>%
          dplyr::summarize(Total = n())
        
        ggplot(month_weekday, aes(month, Total, fill = dayofweek)) + 
          geom_bar( stat = "identity", position = "dodge") +
          ggtitle("Trips by Month and Weekdays") +
          scale_y_continuous(labels = comma) +
          scale_fill_manual(values = colors)
      }else{
        
        day_and_hour <- apr_to_sep_dat %>%
          group_by(dayofweek, hour) %>%
          dplyr::summarize(Total = n()) %>% filter(dayofweek == input$d)
        
        
        
        ggplot(day_and_hour, aes(hour,Total,fill = dayofweek)) +
          geom_bar(fill= "steelblue",stat = "identity")+
          #xlab("hours of day") + ylab("Total Trips")
          ggtitle("Trip hours during",input$d)+
          xlab("hours") + ylab("Total Trips")
        
      }
     
    })
  
    
})


shinyApp(ui,server)