
library(EBImage)
library(shiny)
library(shinyFiles)
library(DT)
library(xlsx)


function(input, output, session) {
  # perform calculations for use in other reactive objects
  dat <- reactive({
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    img = readImage(inFile$datapath)

    #select values over Otsus threshold and set them to 1
    redImg <- img[,,1]
    colorMode(redImg)<-Grayscale # convert red channel to greyscale for use in otsu
    otsuThresh <- otsu(redImg)
    threshImg <- img[,,1] > otsuThresh
    
    # find the interior of the boundary and remove the boundary
    inpoly <- fillHull(img[,,2])-img[,,2]
    interImg <- threshImg*inpoly
    #display(interImg)
    per <- sum(interImg)/sum(inpoly)
    out <- list("img"=img,"redImg"=redImg, "threshImg"=threshImg, "interImg"=interImg, "otsuThresh"=otsuThresh,"per"=per )
    return(out)
  })
  
  output$image1 <- renderPlot({
    if (is.null(dat()))
      return(NULL)
    
    plot(dat()$img, axes = FALSE, main = "Original Image")
  })
  
  output$image2 <- renderPlot({
    if (is.null(dat()))
      return(NULL)
    dt <-dat()
    temp<-dt$img
    temp[,,1]<-dt$interImg
    plot(temp, axes = FALSE, main = "Over Threshold Interior")
  })
  
  output$plot <- renderPlot({
    if (is.null(dat()))
      return(NULL)
    hist(dat()$redImg, main = "Histogram of Interior Pixels with Otsu's Threshold", xlab = "Image Interior")
    abline(v=dat()$otsuThresh,col="darkblue")
    #ggplot(plyr::mutate(as.data.frame(dat()$redImg)),aes(value,col='red'))+
    #  geom_freqpoly(bins=20)+geom_vline(xintercept = dat()$otsuThresh)+
    #  ggtitle("Otsu Threshold Histogram")+
    #  labs(y="Number of Pixels", x="Flourescent Value")
  })
  
  output$threshCap<- renderText({ 
    if (is.null(dat()))
      return(NULL)
    
    paste("The Otsu's Threshold for this image is:", dat()$otsuThresh)
  })
  
  output$vasc<- renderText({
    if (is.null(dat()))
      return(NULL)
    paste("The percent vascularization for this image is:", dat()$per*100, "%")
  })
  
  volumes <- getVolumes()
                 
  observe({
    shinyDirChoose(input, 'directory', roots=volumes,session=session, restrictions=system.file(package='base'))
    
    if (input$batch) {
      library(EBImage)
      
      directory <- (parseDirPath(volumes, input$directory))
      newdir <-(paste(directory,"Thresholded_images", sep="/"))
      
      file.names <- dir(directory, pattern = ".tif")
      setwd(directory)
      dir.create(newdir)
      par(mfrow=c(3,2))
      percents = c()
      flagged = c()
      
      withProgress(message = 'Processing Images', value = 0,{
      for(i in 1:length(file.names)){
        
        img = readImage(file.names[i])
        
        #select values over Otsus threshold and set them to 1
        redImg <- img[,,1]
        
        # determine whether to flag the image
        if(isTRUE(sum(redImg)<input$slider)){
          flagged[i] <- ("yes")
        }
        else(flagged[i]<- ("no"))
        
        colorMode(redImg)<-Grayscale # convert red channel to greyscale for use in otsu
        otsuThresh <- otsu(redImg)
        threshImg <- img[,,1] > otsuThresh
        
        # find the interior of the boundary and remove the boundary
        inpoly <- fillHull(img[,,2])-img[,,2]
        
        #replace the red chanel with the interior
        img[,,1] <- threshImg*inpoly

        percents[i] <- sum(img[,,1])/sum(inpoly)
        
        #write thresholded image
        setwd(newdir)
        writeImage(img,file.names[i],type = "tiff")
        setwd(directory)
        
        incProgress((1/length(file.names)), detail = paste("Processing File", i))
        Sys.sleep(0.1)
      }
      })
      
      #Table
      df <- data.frame(file.names,percents,flagged)
      output$table <- renderDataTable({
        DT::datatable(df, class='cell-border stripe', colnames = c('File Name'= 2, 'Percent Vascularization'= 3),options=list(columnDefs = list(list(visible=FALSE, targets=(3))))) %>% 
          formatStyle(
          'File Name','flagged',
          backgroundColor = styleEqual(('yes'), ('yellow'))
          
        )%>%
          
        formatPercentage('Percent Vascularization',  3)
      })
    
      Thedata <- data.frame(file.names,percents,flagged)
      write.xlsx(Thedata,"ImageData.xlsx")
    }

    
  }) 
  

  

  
  
  
}
