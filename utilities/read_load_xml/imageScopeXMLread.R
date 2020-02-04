#---- imageScopeXMLread.identity ----
#' @title Read imagescope imagescope xml
#'
#' @description Read imagescope xml annotations (circle, rectangle, and number pointer) file to R dataframe.
#'              The dataframe can be load into imageScopeXMLcreate.R  
#'
#' @param fullFileName xml full path
#' @export list of dataframe
#'        imageInfoDf Data frame of image information. (required. 1 obs only) 
#'                 1. fullpath: WSI path and name 
#'                 2. resolution: image MPP 
#'        circleDf Data frame of image information. (optioin. mutiple obs available) 
#'                 1. raduisPixel: raduis length in pixel
#'                 2. x0: x value of the center pixel
#'                 3. y0: y value of the center pixel
#'        rectangleDf Data frame of image information. (optioin. mutiple obs available) 
#'                 1. xLength: x length in pixel
#'                 2. yLength: y length in pixel
#'                 3. x0: x value of the center pixel
#'                 4. y0: y value of the center pixel
#'        NumberDf Data frame of number pointer. (optioin. mutiple obs available)  
#'                 1. x0: x value of the pointer
#'                 2. y0: y value of the pointer
#'
imageScopeXMLread <- function(fullFileName) {

  # This function returns a list, for example,
  #   "Annotation", "Annotation", ".attrs"
  xmlList <- xmlToList(fullFileName)
  
  imageInfoDf <- data.frame()
  circleDf = data.frame() 
  rectangleDf <- data.frame()
  NumberDf <- data.frame()
  for (iXML in 1:length(xmlList)) {

    if (names(xmlList)[iXML] == ".attrs") {

      attrs = xmlList[[iXML]]
      imageInfoDf= data.frame(resolution = as.numeric(attrs[['MicronsPerPixel']]),
                              fullpath = fullFileName)

      
    }else{
      # Focus on the annotation and get the attributes
      annotation <- xmlList[[iXML]]
      annotationAttrs <- as.list(annotation$.attrs)
      # Type 4 annotation attribute
      #   includes circle and square annotation areas
      if (annotationAttrs$Type == 4){
        # annotation$Regions is a list of regions, starting with "RegionAttributeHeaders"
        # and followed by individual annotations named "Region"
        regions <- annotation$Regions
        for (iRegion in 1:length(regions)) {
          
          desc <- names(regions)[iRegion]
          
          if (desc != "Region") next()
          
          region <- regions[[iRegion]]
          regionAttrs <- as.list(region$.attrs)
          if (regionAttrs$Type == "1") {
            
            tempVertex = region$Vertices[[1]]
            x1 = as.numeric(tempVertex["X"])
            y1 = as.numeric(tempVertex["Y"])
            tempVertex = region$Vertices[[2]]
            x2 = as.numeric(tempVertex["X"])
            y2 = as.numeric(tempVertex["Y"])
            tempVertex = region$Vertices[[3]]
            x3 = as.numeric(tempVertex["X"])
            y3 = as.numeric(tempVertex["Y"])
            tempVertex = region$Vertices[[4]]
            x4 = as.numeric(tempVertex["X"])
            y4 = as.numeric(tempVertex["Y"])
            xMax = max(x1,x2,x3,x4)
            xMin = min(x1,x2,x3,x4)
            yMax = max(y1,y2,y3,y4)
            yMin = min(y1,y2,y3,y4)
            x0 = (xMax+xMin)/2
            y0 = (yMax+yMin)/2
            xLength = xMax-xMin
            yLength = yMax-yMin
            rectangleDf <- rbind(
              rectangleDf,
              data.frame(
                x0 = x0,
                y0 = y0,
                xLength = xLength,
                yLength = yLength
                
              )
            )
          }else if(regionAttrs$Type == "2"){
            tempVertex = region$Vertices[[1]]
            x1 = as.numeric(tempVertex["X"])
            y1 = as.numeric(tempVertex["Y"])
            tempVertex = region$Vertices[[2]]
            x2 = as.numeric(tempVertex["X"])
            y2 = as.numeric(tempVertex["Y"])
            raduisPixel = abs(x2-x1)/2
            x0 = (x1+x2)/2
            y0 = (y1+y2)/2
            circleDf <- rbind(
              circleDf,
              data.frame(
                x0 = x0,
                y0 = y0,
                raduisPixel = raduisPixel
              )
            )
          }else{
            print("There should only be type 1 (rectangle) or 2 (circle) regions.")
          }
        }
      }else if(annotationAttrs$Type == 9) {
        # Type 9 annotation attribute
        #   includes the mark and count anotation
        # annotation$Regions is a list of regions, starting with "RegionAttributeHeaders"
        # and followed by individual annotations named "Region"
        regions <- annotation$Regions
        for (iRegion in 1:length(regions)) {
          
          desc <- names(regions)[iRegion]
          
          if (desc != "Region") next()
          region <- regions[[iRegion]]
          regionAttrs <- as.list(region$.attrs)
          if (regionAttrs$Type == "5") {
            NumberDf <- rbind(
              NumberDf,
              data.frame(
                x0 = as.numeric(region$Vertices$Vertex["X"]),
                y0 = as.numeric(region$Vertices$Vertex["Y"])
              )
            )
          }else{
            print("There should only be type 5 (mark and count) regions.")
          }
        }
      }
    }
  }
  return(list(imageInfoDf = imageInfoDf,
              circleDf = circleDf,
              rectangleDf = rectangleDf,
              NumberDf = NumberDf))

}
