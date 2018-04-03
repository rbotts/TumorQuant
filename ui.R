fluidPage(
  
  # Application title
  titlePanel("Tumor Image Processing"),
  
  sidebarLayout(
    
    # Sidebar with a slider input
    sidebarPanel(
      conditionalPanel(condition="input.conditionedPanels == 'Single Image Processing'",
      helpText("Please select a .tif file from the 
               folder you wish to view the updated images and histogram for.
               You can change the file by once again clicking on the 'Browse' button."),
      
      #File input                 
      fileInput("file1", "Choose a File"
                )
      ),
      conditionalPanel(condition= "input.conditionedPanels == 'Batch Image Processing'",
                       helpText("Please select the directory for the folder you would like to 
                                    batch process by clicking on the 'Folder Select' button. 
                                    When the folder has been selected, click the button labeled
                                    'Start Processing'to begin. Wait for the files to be processed."),
                       shinyFiles::shinyDirButton('directory', 'Folder select', 'Please select a folder'),
                       actionButton("batch", "Start Processing"),
                       helpText("Select a minimum number of pixels in image for valid image"),
                       sliderInput("slider", label= "slider",min= 200, max=100000, value=20000)
                       ),
      conditionalPanel(condition= "input.conditionedPanels == 'HELP ME'",
                       helpText("Thank you for using our app!"),
                       helpText("To the right you will find some instructions on how to use the app.")
    )),
    
    # Show outputs
    mainPanel(
      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  
                  
                  tabPanel("Single Image Processing", helpText("Here you will see the Otsu's Threshold Histogram for the selected file.
                                              The threshold is marked with the vertical black line. The threshold value will also be printed below."),
                           fluidRow(column(width = 12,plotOutput("plot"))),
                           fluidRow(column(width = 12,textOutput("threshCap"))),
                           br(),
                           helpText("Below you will find both the original image located in the file you 
                                      chose and the updated black and white threshold image. The percent vascularization for 
                                      the file is displayed below the images."),
                           fluidRow(column(width = 6,plotOutput("image1")), column(width = 6,plotOutput("image2"))),
                           fluidRow(column(width = 12,textOutput("vasc"))),
                           br(),
                           br()
                           ),
                  
                  
                  tabPanel("Batch Image Processing",
                           helpText("Here is a table containing the percent vascularization of the tumor images you selected. The images in yellow are flagged based 
                                    on the number chosen using the slider"),
                           DT::dataTableOutput("table")
                           ),
                  
                  
                  tabPanel("HELP ME", helpText(tags$h4("Single Image Processing")),
                           helpText("1. Click on the 'Single Image Processing' tab. button on the left hand side of the app"),
                           helpText("2. Click on the button on the left hand side of the app"),
                           helpText(tags$h6("-This allows you to choose a file")),
                           helpText(tags$h6("-Please make sure the images are .tif files")),
                           helpText("3. The histogram and images will be located on the left hand side. This takes a minute so be patient."),
                           helpText(tags$h4("Batch Processing (multiple images)")),
                           helpText("If you wish to batch process multiple images in a new folder follow these instructions:"),
                           helpText("1. Click on the “Batch Processing” tab"),
                           helpText("2. Click folder select button"),
                           helpText("3. Select the path directory by clicking on the folder paths"),
                           helpText("4. Select the count number using to slider to choose how to flag images."),
                           helpText("5. When you have finished selecting the path and slider value, click on the button that says “Start Processing”"),
                           helpText("6. You may have to wait a while if the folder contains many images"),
                           helpText("7. When the batchprocessing is finished, a table will appear"),
                           helpText("8. A new excel file with the data can be found in the chosen folder"),
                           helpText(tags$caption(" -NOTE: you can determine if this is working if a new folder appears labeled 
                                    threshold_images inside the folder where you selected to batch process the 
                                    images and that there are new images within the new folder")),
                           helpText(tags$h4("Viewing Other Tabs in the App")),
                           helpText("1. The default tab is the “Single Image Processing” Tab"),
                           helpText(tags$h6("-This tab shows the original image and the thresholded 
                                    image selected through the Browse button. It also provides the Otsu's 
                                            Threshold histogram for the selected image file")),
                           helpText("2. The second tab is the “Batch Processing” Tab"),
                           helpText(tags$h6("-Under this tab is a print out of the percent vascularization 
                                    and file names from the images in the chosen folder")),
                           helpText(tags$h6("-You can seach for specific files using the search tool.
                                            You may also choose how many rows you wish to see at a time.")),
                           helpText("3. The third tab is the“HELP ME”tab"),
                           helpText(tags$h6("-This tab contains a short guide on how to use the app")),
                           helpText(tags$h4("Analyzing the results")),
                           helpText("-The percentages found under the table tab give the percent 
                                    vascularization for the tumor image. This is done by analyzing the percentage 
                                    of white pixels within the box given by the Threshold 
                                    image that is produced by the app."),
                           helpText("-An excel file will be generated and placed in the directory of the images being processed 
                                    with the vascularity percents and image names."),
                           helpText("-A new folder will be added to the directory chosen that contains the thresholded images.")
                           
                  ),
  
                  id = "conditionedPanels"          
      )
      
    )
  )
)

  

