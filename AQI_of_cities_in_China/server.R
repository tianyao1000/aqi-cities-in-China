#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(reshape2)
library(lubridate)

source("global.R")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   #cityname = input$Cityname
    
    aqi_df = reactive({
        df_filename = paste(Get_cityname(1),".csv",sep="")
        read.csv(df_filename)
        
    })
    
    aqi_df_compare = reactive({
        df_filename = paste(Get_cityname(2),".csv",sep="")
        read.csv(df_filename)
        
    })
    
    
    
    com_status = reactive(
        {
            input$compare%%2==1
        }
    )
    
    Get_cityname = function(city_flag)
    {
        if(city_flag ==1)
        {
            Cityname = input$Cityname
            
        }
        
        if(city_flag ==2)
        {
            Cityname = input$Cityname_compare
        }
        
        cityname_index = which(Cityname==Citynames_UI)
        return(Citynames_Server[cityname_index])
    }
    
    aqi_df_preprocess = function(df)
    {
        aqi_df_table = table(df$year)
        aqi_df_annul_datanum_df = as.data.frame(aqi_df_table)
        names(aqi_df_annul_datanum_df) = c("year","data_num")
        year_data_num = 365
        
        index = which(aqi_df_annul_datanum_df$data_num<year_data_num)
        
        years_to_ignore = aqi_df_annul_datanum_df$year[index]
        
        len = length(years_to_ignore)
        aqi_df_temp = df
        for(i in 1:len)
        {
            year_ignore = years_to_ignore[i]
            aqi_df_temp = aqi_df_temp[!aqi_df_temp$year==year_ignore,]
        }
        aqi_df_temp
    }
    
    
    aqi_df_component = function(aqi_df_temp, component, avg_choice)
    {
        index = which(avg_choice==ratiobutton_names_UI)
        col_name = ratiobutton_names_Server[index]
        print(unique(aqi_df_temp[[col_name]]))
        df = aggregate(aqi_df_temp,by=list(aqi_df_temp[[col_name]]),FUN=mean)
        #print(df)
        df = data.frame(df$Group.1, df[[component]])
      
        
        names(df) = c("x","y")
        df$x = factor(df$x)
        df
    }
    
    df1 = reactive(
        {
            aqi_df_temp = aqi_df_preprocess(aqi_df())
            Component_option = input$Component_option
            Component_index = which(Component_option==AQI_components_UI)
            AQI_components_name = AQI_components_Server[Component_index]
            AVG_option = input$AVG_option
            df = aqi_df_component(aqi_df_temp,AQI_components_name,AVG_option)
            df$cityname = rep(Get_cityname(1),nrow(df))
            df
        }
    )
    
    df2 = reactive(
        {
            aqi_df_temp = aqi_df_preprocess(aqi_df_compare())
            Component_option = input$Component_option
            Component_index = which(Component_option==AQI_components_UI)
            AQI_components_name = AQI_components_Server[Component_index]
            AVG_option = input$AVG_option
            df = aqi_df_component(aqi_df_temp,AQI_components_name,AVG_option)
            df$cityname = rep(Get_cityname(2),nrow(df))
            df
        }
    )
    
    
    df= reactive(
        {
            if(com_status())
            {
                df_temp = rbind(df1(),df2())
            }
            else
            {
                df_temp = df1()
                
            }
            df_temp


    })
    
    observeEvent(input$compare, {
        value = input$compare
        if(value%%2==0)
            disable(id="Cityname_compare")
        else
            enable(id="Cityname_compare")
    })
    
    output$AQI_date_output = renderText({
      
        AQI_date = input$AQI_date
        index = which(ymd(aqi_df()$Date)==ymd(AQI_date))
        # print(ymd(AQI_date))
        # print(mdy(as.character(aqi_df()$Date[1072])))
        # print(mdy(as.character(aqi_df()$Date[1072]))==ymd(AQI_date))
        # print(index)
        Component_option = input$Component_option
        Component_index = which(Component_option==AQI_components_UI)
        AQI_components_name = AQI_components_Server[Component_index]
        
        if(length(index)==0)
        {
            "No data avaiable for the chosen date"
        }
        else
        {
            
            col = aqi_df()[[AQI_components_name]]
            res = paste(Get_cityname(1),col[index],sep=": ")
            
            if(com_status())
            {
                col2 = aqi_df_compare()[[AQI_components_name]]
                res2 = paste(Get_cityname(2),col2[index],sep=": ")

                res = paste(res,res2)
            }
            
            res 
        }
        
    })
    
    output$data_AQI_table = renderTable({
        
        AQI_date = input$AQI_date
        index = which(ymd(aqi_df()$Date)==ymd(AQI_date))
        Component_option = input$Component_option
        Component_index = which(Component_option==AQI_components_UI)
        AQI_components_name = AQI_components_Server[Component_index]
        print(index)
        if(length(index)==0)
        {
            data.frame()
        }
        else
        {
            
            df_temp = aqi_df()[index,table_output_col_index]
            citynames = Get_cityname(1)
             
            
            if(com_status())
            {
                df_temp2 = aqi_df_compare()[index,table_output_col_index]
                df_temp = rbind(df_temp,df_temp2)
                citynames = c(Get_cityname(1),Get_cityname(2))
            }
            
            df_temp$citynames = citynames
            df_temp = df_temp[,c(ncol(df_temp),1:ncol(df_temp)-1)]
        }
        
    })
    
    output$plot <- renderPlotly({
        
        #print(names(df()))
      #  print(unique(df()$x))
        plot_title = paste(input$Component_option,"data of",input$Cityname ,sep=" ")
        x_lab = substr(input$AVG_option,4,nchar(input$AVG_option))
        y_lab = input$Component_option
            p = plot_ly(df(), x = ~x, y = ~y,type="scatter",color = ~cityname,
                        marker = list(size = 25, opacity=0.5,
                                      line = list(color ='rgba(152, 0, 0, .8)',width = 2))) %>%layout(xaxis = list(title =x_lab), yaxis =  list(title =y_lab))
        p
    })

})
