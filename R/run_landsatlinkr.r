#' GUI for running LandsatLinkr
#'
#' GUI for running LandsatLinkr
#' @export

run_landsatlinkr = function(){
  
  #################################################################################################################
  #get the process to run
  
  correct = "No"
  while(correct == "No"){
    choices = c("Prepare MSS",
                "Prepare TM/ETM+",
                "Calibrate MSS to TM",
                "Calibrare OLI to ETM+",
                "Composite imagery")#,
                #"Fit neat lines")
    
    selection = select.list(choices, title = "Select a process to run")
    if(selection == "Prepare MSS"){process = seq(1:5)}
    if(selection == "Prepare TM/ETM+"){process = 6}
    if(selection == "Calibrate MSS to TM"){process = 7}
    if(selection == "Calibrate OLI to ETM+"){process = 8}
    if(selection == "Composite imagery"){process = 9}
    #if(selection == "Fit neat lines"){process = 9}
    
    print(paste("You have selected:",selection))
    correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
    if(correct == "Exit"){return("Stopping LLR")}
  }
  
  #################################################################################################################
  #define the number of cores to use
  
  if(sum(process %in% seq(1,9)) > 0){  
    
    correct = "No"
    while(correct == "No"){
      choices = c("Yes", "No")
      selection = select.list(choices, title = "Process in parallel using 2 cores when possible?")
      if(selection == "Yes"){cores = 2}
      if(selection == "No"){cores = 1}
      print(paste("You have selected:",selection))
      correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
      if(correct == "Exit"){return("Stopping LLR")}
    }
  }
  
  
  if(sum(process %in% seq(1,9)) > 0){  
    
    correct = "No"
    while(correct == "No"){
      choices = c("Yes", "No")
      selection = select.list(choices, title = "If files from a process already exist, should they be overwritten?")
      if(selection == "Yes"){overwrite = T}
      if(selection == "No"){overwrite = F}
      print(paste("You have selected:",selection))
      correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
      if(correct == "Exit"){return("Stopping LLR")}
    }
  }
  
  #################################################################################################################
  #prepare mss and tm/etm+ data
  #################################################################################################################
  
  #################################################################################################################
  #select a directory to process
  
  if(sum(process %in% seq(1,6)) > 0){
    correct = "No"
    while(correct == "No"){
      if(sum(process %in% seq(1,5)) > 0){
        print("please select an MSS directory to process")
        scenedir = choose.dir(caption = "Select an MSS scene directory. ex. 'C:/mss/wrs1/036032'")
      } else{
        print("please select a TM/ETM+ directory to process")
        scenedir = choose.dir(caption = "Select an TM/ETM+ scene directory. ex. 'C:/tm/wrs2/036032'")
      }
      
      print(paste("You have selected:",scenedir))
      correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
      if(correct == "Exit"){return("Stopping LLR")}
    }
    
    #reso = 60 #set default - not used anymore since we are running MSS at 60 and TM at 30
    #proj = "albers" #set default
    # if(sum(process %in% c(1,6)) > 0){
    #       choices = c("30 meter", "60 meter")
    #       selection = select.list(choices, title = "Select a pixel resolution to use")
    #       if(selection == "30 meter"){reso = 30}
    #       if(selection == "60 meter"){reso = 60}
    
    #choices = c("USGS North American Albers", "User-provided projection","Native NAD83 UTM (not recommended!)", )
    #selection = select.list(choices, title = "Select a map projection to use")
    #if(selection == "Native NAD83 UTM (not recommended!)"){proj = "default"}
    #if(selection == "USGS North American Albers"){proj = "albers"}
    #if(selection == "User-provided"){
    
    #################################################################################################################
    #define a projection
    
    correct = "No"
    while(correct == "No"){  
      print("Please define a projection to use for this project")
      print("If you need assistance, see the 'Selecting a geographic projection' section in the user manual")
      print("If you want to exit, press the 'return' key and then select 'Exist'")
      #choices = c("Manual PROJ.4 definition", "Extract PROJ.4 from a reference raster")
      #selection = select.list(choices, title = "How do you want to define the projection")
      #if(selection =="Manual PROJ.4 definition"){
      proj = readline("  Provide PROJ.4 string: ") #http://spatialreference.org/
      #       }
      #       if(selection == "Extract PROJ.4 from a reference raster"){
      #         file = choose.files(caption = "Select a raster file to extract projection information from", multi=F)
      #         proj = gdalsrsinfo(srs_def=file,o="proj4")
      #         proj = sub("'","",proj)
      #         proj = sub(" '","",proj)
      #       }
      #}
      #}
      
      print(paste("You have selected:",proj))
      correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
      if(correct == "Exit"){return("Stopping LLR")}
    }
    
    #################################################################################################################
    #provide a DEM
    
    if(sum(process %in% seq(1,5)) > 0){
      correct = "No"
      while(correct == "No"){
        print("Please select a scene corresponding DEM file")
        demfile = choose.files(caption = "Select a scene corresponding DEM file", multi=F)
        print(paste("You have selected:",demfile))
        correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
        if(correct == "Exit"){return("Stopping LLR")}
      }
    }
    #return(list(scenedir, demfile, proj, reso, process,cores))
    prepare_images(scenedir, demfile, proj=proj, process=process,cores=cores, overwrite=overwrite)
  }
  

  #################################################################################################################
  #msscal and mixel
  #################################################################################################################

  if(sum(process %in% 7:9) > 0){
    
    #################################################################################################################
    #select directories for calibration
    if(sum(process %in% 7) > 0){
      print("Beginning scene selection for MSS to TM calibration")
      print("Please see the 'Running LLR Step 3 - MSS to TM calibration' section of the user guide for assistance")
      print("-----------------------------------------------------------------------")
      correct = "No"
      while(correct == "No"){
        print("Select a MSS WRS-1 scene directory.")
        msswrs1dir = choose.dir(caption = "Select a MSS WRS-1 scene directory. ex. 'C:/mss/wrs1/036032'")
        print("Select a MSS WRS-2 scene directory.")
        msswrs2dir = choose.dir(caption = "Select a MSS WRS-2 scene directory. ex. 'C:/mss/wrs2/034032'")
        print("Select a TM/ETM+ WRS-2 scene directory.")
        tmwrs2dir = choose.dir(caption = "Select a TM/ETM+ WRS-2 scene directory. ex. 'C:/tm/wrs2/034032'")
        oliwrs2dir=NULL
        outdir=NULL
        index=NULL
        runname=NULL
        calcomprocess = 1
        
        print("-----------------------------------------------------------------------")
        print(paste("You have selected MSS WRS-1 scene:",msswrs1dir))
        print(paste("You have selected MSS WRS-2 scene:",msswrs2dir))
        print(paste("You have selected TM/ETM+ WRS-2 scene:",tmwrs2dir))
        correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
        if(correct == "Exit"){return("Stopping LLR")}
      }
    }
    
    #################################################################################################################
    #select directories for calibration
    if(sum(process %in% 8) > 0){
      print("Beginning scene selection for OLI to ETM+ calibration")
      print("Please see the 'Running LLR Step 3 - OLI to ETM+ calibration' section of the user guide for assistance")
      print("-----------------------------------------------------------------------")
      correct = "No"
      while(correct == "No"){
        print("Select a OLI WRS-2 scene directory.")
        oliwrs2dir = choose.dir(caption = "Select a OLI WRS-2 scene directory. ex. 'C:/oli/wrs1/036032'")
        print("Select a TM/ETM+ WRS-2 scene directory.")
        tmwrs2dir = choose.dir(caption = "Select a TM/ETM+ WRS-2 scene directory. ex. 'C:/tm/wrs2/034032'")
        msswrs1dir=NULL
        msswrs2dir=NULL
        outdir=NULL
        index=NULL
        runname=NULL
        calcomprocess = 2
        
        print("-----------------------------------------------------------------------")
        print(paste("You have selected OLI WRS-2 scene:",oliwrs2dir))
        print(paste("You have selected TM/ETM+ WRS-2 scene:",tmwrs2dir))
        correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
        if(correct == "Exit"){return("Stopping LLR")}
      }
    }
    
    
    #################################################################################################################
    #select directories for mosaicking
    
    if(sum(process %in% 9) > 0){
      correct = "No"
      while(correct == "No"){
        choices = c("Yes", "No")
        msswrs1dir = choose.dir(caption = "Select a MSS WRS-1 scene directory. ex. 'C:/mss/wrs1/036032'")
        answer = "Yes"
        while(answer == "Yes"){
          print("Here is what you have so far - MSS WRS-1 scene:")
          print(msswrs1dir)
          answer = select.list(choices, title = "Is there another MSS WRS-1 scene directory to add?")
          if(answer == "Yes"){msswrs1dir = c(msswrs1dir, choose.dir(caption = "Select a MSS WRS-1 scene directory. ex. 'C:/mss/wrs1/036032'"))}
        }
        
        msswrs2dir = choose.dir(caption = "Select a MSS WRS-2 scene directory. ex. 'C:/mss/wrs2/034032'")
        answer = "Yes"
        while(answer == "Yes"){
          print("Here is what you have so far - MSS WRS-2 scene:")
          print(msswrs1dir)
          answer = select.list(choices, title = "Is there another MSS WRS-2 scene directory to add?")
          if(answer == "Yes"){msswrs2dir = c(msswrs2dir, choose.dir(caption = "Select a MSS WRS-2 scene directory. ex. 'C:/mss/wrs2/034032'"))}
        }
        
        tmwrs2dir = choose.dir(caption = "Select a TM WRS-2 scene directory. ex. 'C:/tm/wrs2/034032'")
        answer = "Yes"
        while(answer == "Yes"){
          print("Here is what you have so far - TM/ETM+ WRS-2 scene:")
          print(msswrs1dir)
          answer = select.list(choices, title = "Is there another TM/ETM+ WRS-2 scene directory to add?")
          if(answer == "Yes"){tmwrs2dir = c(tmwrs2dir, choose.dir(caption = "Select a TM WRS-2 scene directory. ex. 'C:/tm/wrs2/034032'"))}
        }  
        
        print(paste("You have selected MSS WRS-1 scene:",msswrs1dir))
        print(paste("You have selected MSS WRS-2 scene:",msswrs2dir))
        print(paste("You have selected TM WRS-2 scene:",tmwrs2dir))
        correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
        if(correct == "Exit"){return("Stopping LLR")}
      }
      
      correct = "No"
      while(correct == "No"){
        print("Please select a directory to write the outputs to. ex. 'C:/composites/study_area'")
        outdir = choose.dir(caption = "Select a directory to write the outputs to. ex. 'C:/composites/study_area'")
        
        print(paste("You have selected:",outdir))
        correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
        if(correct == "Exit"){return("Stopping LLR")}
      }
      
      #         choices = c("Tasseled cap angle",
      #                     "Tasseled cap brightness",
      #                     "Tasseled cap greenness",
      #                     "Tasseled cap wetness",
      #                     "All")
      #         selection = select.list(choices, title = "Select an index to create composites for")
      #         if(selection == "Tasseled cap angle"){index = "tca"}
      #         if(selection == "Tasseled cap brightness"){index = "tcb"}
      #         if(selection == "Tasseled cap greenness"){index = "tcg"}
      #         if(selection == "Tasseled cap wetness"){index = "tcw"}
      #         if(selection == "All"){index = "all"}
      
      #################################################################################################################
      #run name
      
      correct = "No"
      while(correct == "No"){
        runname = readline("Provide a unique name for the composite series. ex. project1: ")
        print(paste("You have selected:",runname))
        correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
        if(correct == "Exit"){return("Stopping LLR")}
      }
      
      #################################################################################################################
      #use area file or coordinates
      
      choices = c("From file",
                  "Provide coordinates")
      selection = select.list(choices, title = "What area do you want to create composites for?")
      if(selection == "From file"){
        correct = "No"
        while(correct == "No"){
          useareafile = choose.files(caption = "Select a 'usearea' file", multi=F)
          print(paste("You have selected:",useareafile))
          correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
          if(correct == "Exit"){return("Stopping LLR")}
        }
      }
      
      if(selection == "Provide coordinates"){
        
        correct = "No"
        while(correct == "No"){
          check = 0
          while(check != 2){
            print("Please provide min and max xy coordinates (in image set projection units) defining a study area that intersects the image set")
            xmx = as.numeric(readline("max x coordinate: "))
            xmn = as.numeric(readline("min x coordinate: "))
            ymx = as.numeric(readline("max y coordinate: "))
            ymn = as.numeric(readline("min y coordinate: "))
            check = (xmx > xmn) + (ymx > ymn)
            if(check != 2){print("error - coordinates do not create a square - try again")}
          }
          print("You have selected:")
          print(paste("max x coordinate:",xmx ))
          print(paste("min x coordinate:",xmn ))
          print(paste("max y coordinate:",ymx ))
          print(paste("min y coordinate:",ymn ))
          correct = select.list(c("Yes","No","Exit"), title = "Is that correct?")
          if(correct == "Exit"){return("Stopping LLR")}
        }
        useareafile = file.path(outdir, paste(runname,"_usearea.tif",sep=""))
        make_usearea_file(c(msswrs1dir[1],msswrs2dir[1],tmwrs2dir[1]), useareafile, xmx, xmn, ymx, ymn)
      }
      calcomprocess = 3
    }
    #}
    #if(sum((process %in% 7) > 0)){process[1] = 1}
    #if(sum((process %in% 8) > 0)){process[process==8] = 2}
    #return(msswrs1dir,msswrs2dir,tmwrs2dir,index,outdir,runname,useareafile,cores,process)
    
    #################################################################################################################
    #execute the calibrate_and_composite function
    
    calibrate_and_composite(msswrs1dir,msswrs2dir,tmwrs2dir,oliwrs2dir,index="all",outdir,runname,useareafile,doyears="all",order="none",overlap="mean", cores=cores, process=calcomprocess, overwrite=overwrite)
  }
  
  #if(sum(process %in% 9 > 0)){
  #  dir = choose.dir(caption = "Select a composites directory from which to find image composite stacks")
  #  cores = readline("How many cores to use to process in parallel?: ")
  #  run_neatline(dir, cores)
  #}
}
