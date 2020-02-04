#---- imageScopeXMLcreate.identity ----
#' @title Generate imagescope xml
#'
#' @description Generate imagescope xml annotations (circle, rectangle, and number pointer) file for WSI image. 
#'              And write it to the image dirctory with image name.  
#'
#' @param imageInfoDf Data frame of image information. (required. 1 obs only) 
#'                    1. fullpath: WSI path and name 
#'                    2. resolution: image MPP 
#' @param circleDf Data frame of image information. (optioin. mutiple obs available) 
#'                 1. raduisPixel: raduis length in pixel
#'                 2. x0: x value of the center pixel
#'                 3. y0: y value of the center pixel
#' @param rectangleDf Data frame of image information. (optioin. mutiple obs available) 
#'                    1. xLength: x length in pixel
#'                    2. yLength: y length in pixel
#'                    3. x0: x value of the center pixel
#'                    4. y0: y value of the center pixel
#' @param NumberDf Data frame of number pointer. (optioin. mutiple obs available)  
#'                 1. x0: x value of the pointer
#'                 2. y0: y value of the pointer
# @export
#'

imageScopeXMLcreate <- function(imageInfoDf=NULL,circleDf = NULL,rectangleDf = NULL,NumberDf = NULL){
  if (is.null(imageInfoDf)) {
    print("Please provide image Infomation by imageInfoDf")
    return(NULL)
  }
  library(XML)
  
  # XML main title 
  prefix.xml <- paste0("<Annotations MicronsPerPixel = '",as.character(imageInfoDf$resolution),"'>",
                       "
                        </Annotations>")
  
  # BUILD XML TREE
  doc = xmlTreeParse(prefix.xml, useInternalNodes = T)     # PARSE STRING
  root = xmlRoot(doc)                                      # create ROOT
  headerId = 1;
  
  
  ## circle and suqare
  ## title
  if (!is.null(circleDf)||!is.null(rectangleDf)){
    Annotation1 = newXMLNode("Annotation", parent=root)           # ADD TO ROOT
    xmlAttrs(Annotation1) = c(MacroName = '',
                              MarkupImagePath = '',
                              Selected = '0',
                              Visible = '1',
                              LineColor  = '65280',
                              Type = '4',
                              Incremental = '0',
                              LineColorReadOnly = '0',
                              NameReadOnly = '0',
                              ReadOnly = '0',
                              Name = '',
                              Id = headerId)              # ADD Info
    headerId = headerId + 1
    ## Attributes1
    Attributes1 = newXMLNode("Attributes", parent=Annotation1)       # ADD TO Annotation1
    Attribute1 = newXMLNode("Attribute", parent=Attributes1)       # ADD TO Attributes1
    xmlAttrs(Attribute1) = c(Name = "Description",Id = '0',Value = '')              # ADD Info
    ## Regions1
    Regions1 = newXMLNode("Regions", parent=Annotation1)           # ADD TO Annotation1
    ## RegionAttributeHeaders1
    RegionAttributeHeaders1 = newXMLNode("RegionAttributeHeaders", parent=Regions1)           # ADD TO Regions1
    ## AttributeHeaders
    tempAttributeHeaders = newXMLNode("AttributeHeaders", parent=RegionAttributeHeaders1) 
    xmlAttrs(tempAttributeHeaders) = c(Name = "Region",Id = '9999',ColumunWidth = '-1')              # ADD Info
    tempAttributeHeaders = newXMLNode("AttributeHeaders", parent=RegionAttributeHeaders1) 
    xmlAttrs(tempAttributeHeaders) = c(Name = "Length",Id = '9997',ColumunWidth = '-1')              # ADD Info
    tempAttributeHeaders = newXMLNode("AttributeHeaders", parent=RegionAttributeHeaders1) 
    xmlAttrs(tempAttributeHeaders) = c(Name = "Area",Id = '9996',ColumunWidth = '-1')              # ADD Info
    tempAttributeHeaders = newXMLNode("AttributeHeaders", parent=RegionAttributeHeaders1) 
    xmlAttrs(tempAttributeHeaders) = c(Name = "Text",Id = '9998',ColumunWidth = '-1')              # ADD Info
    tempAttributeHeaders = newXMLNode("AttributeHeaders", parent=RegionAttributeHeaders1) 
    xmlAttrs(tempAttributeHeaders) = c(Name = "Description",Id = '1',ColumunWidth = '-1')              # ADD Info
  }
  Idcount = 1
  ## Region circle
  if (!is.null(circleDf)){
    for(i in (1:nrow(circleDf))){
        # calculate size and position
        tAreaMicrons = (circleDf[i,]$raduisPixel*imageInfoDf$resolution)^2 * pi
        tLengthMicrons = 2 * pi * circleDf[i,]$raduisPixel *imageInfoDf$resolution
        tArea = (circleDf[i,]$raduisPixel)^2 * pi
        tLength = 2 * pi * circleDf[i,]$raduisPixel
        txtopleft = circleDf[i,]$x0 - circleDf[i,]$raduisPixel
        tytopleft = circleDf[i,]$y0 - circleDf[i,]$raduisPixel
        txbotright = circleDf[i,]$x0 + circleDf[i,]$raduisPixel
        tybotright = circleDf[i,]$y0 + circleDf[i,]$raduisPixel
        
        # write to xml
        tempRegion = newXMLNode("Region", parent=Regions1)           # ADD TO Regions1
        xmlAttrs(tempRegion)=c(Selected = '0',
                               Type = '2',
                               Id = Idcount,
                               DisplayId = '1',
                               Analyze  = '0',
                               InputRegionId = '0',
                               NegativeROA = '0',
                               Text = '',
                               AreaMicrons = tAreaMicrons,
                               LengthMicrons = tLengthMicrons,
                               Area = tArea,
                               Length = tLength,
                               ImageFocus = '0',
                               ImageLocation = '',
                               Zoom = '0.022562')              # ADD Info
        tempAttributes = newXMLNode("Attributes", parent=tempRegion)           # ADD TO tempRegion
        tempVertices = newXMLNode("Vertices", parent=tempRegion)           # ADD TO tempRegion
        tVertex = newXMLNode("Vertex", parent=tempVertices)           # ADD TO tempVertices
        xmlAttrs(tVertex) = c(Z = '0',Y = tytopleft, X = txtopleft)
        tVertex = newXMLNode("Vertex", parent=tempVertices)           # ADD TO tempVertices
        xmlAttrs(tVertex) = c(Z = '0',Y = tybotright, X = txbotright)
        Idcount = Idcount + 1
    }
  }
  
  
  
  ## Region rectangle
  if(!is.null(rectangleDf)){
    for(i in (1:nrow(rectangleDf))){
      # calculate size and position
      tAreaMicrons = imageInfoDf$resolution^2 * rectangleDf[i,]$xLength * rectangleDf[i,]$yLength
      tLengthMicrons = 2 * (rectangleDf[i,]$xLength + rectangleDf[i,]$yLength) * imageInfoDf$resolution
      tArea = rectangleDf[i,]$xLength * rectangleDf[i,]$yLength
      tLength = 2 * (rectangleDf[i,]$xLength + rectangleDf[i,]$yLength)
      txtopleft = rectangleDf[i,]$x0 - rectangleDf[i,]$xLength/2
      tytopleft = rectangleDf[i,]$y0 - rectangleDf[i,]$yLength/2
      txtopright = rectangleDf[i,]$x0 + rectangleDf[i,]$xLength/2
      tytopright = rectangleDf[i,]$y0 - rectangleDf[i,]$yLength/2
      txbotleft = rectangleDf[i,]$x0 - rectangleDf[i,]$xLength/2
      tybotleft = rectangleDf[i,]$y0 + rectangleDf[i,]$yLength/2
      txbotright = rectangleDf[i,]$x0 + rectangleDf[i,]$xLength/2
      tybotright = rectangleDf[i,]$y0 + rectangleDf[i,]$yLength/2
      
      # write to xml 
      tempRegion = newXMLNode("Region", parent=Regions1)           # ADD TO Regions1
      xmlAttrs(tempRegion)=c(Selected = '0',
                             Type = '1',
                             Id = Idcount,
                             DisplayId = '1',
                             Analyze  = '0',
                             InputRegionId = '0',
                             NegativeROA = '0',
                             Text = '',
                             AreaMicrons = tAreaMicrons,
                             LengthMicrons = tLengthMicrons,
                             Area = tArea,
                             Length = tLength,
                             ImageFocus = '0',
                             ImageLocation = '',
                             Zoom = '0.022562')              # ADD Info
      tempAttributes = newXMLNode("Attributes", parent=tempRegion)           # ADD TO tempRegion
      tempVertices = newXMLNode("Vertices", parent=tempRegion)           # ADD TO tempRegion
      tVertex = newXMLNode("Vertex", parent=tempVertices)           # ADD TO tempVertices
      xmlAttrs(tVertex) = c(Z = '0',Y = tytopleft, X = txtopleft)
      tVertex = newXMLNode("Vertex", parent=tempVertices)           # ADD TO tempVertices
      xmlAttrs(tVertex) = c(Z = '0',Y = tytopright, X = txtopright)
      tVertex = newXMLNode("Vertex", parent=tempVertices)           # ADD TO tempVertices
      xmlAttrs(tVertex) = c(Z = '0',Y = tybotright, X = txbotright)
      tVertex = newXMLNode("Vertex", parent=tempVertices)           # ADD TO tempVertices
      xmlAttrs(tVertex) = c(Z = '0',Y = tybotleft, X = txbotleft)
      Idcount = Idcount + 1
    }
  }
  
  ## Plots1
  if (!is.null(circleDf)||!is.null(rectangleDf)){
    Plots1 = newXMLNode("Plots", parent=Annotation1)           # ADD TO Annotation1
  }
  
  
  
  ## number
  ## title
  if (!is.null(NumberDf)){
      Annotation2 = newXMLNode("Annotation", parent=root)           # ADD TO ROOT
      xmlAttrs(Annotation2) = c(MacroName = "",
                                MarkupImagePath = '',
                                Selected = '0',
                                Visible = '1',
                                LineColor  = '65280',
                                Type = '9',
                                Incremental = '0',
                                LineColorReadOnly = '1',
                                NameReadOnly = '0',
                                ReadOnly = '0',
                                Name = '',
                                Id = headerId)              # ADD Info
      ## InputAnnotationId
      newXMLNode("InputAnnotationId", 1, parent=Annotation2)
      
      ## Attributes2
      Attributes2 = newXMLNode("Attributes", parent=Annotation2)       # ADD TO Annotation2
      Attribute2 = newXMLNode("Attribute", parent=Attributes2)       # ADD TO Attributes2
      xmlAttrs(Attribute2) = c(Name = "Description",Id = '0',Value = '')              # ADD Info
      
      ## Regions2
      Regions2 = newXMLNode("Regions", parent=Annotation2)           # ADD TO Annotation2
      ## RegionAttributeHeaders2
      RegionAttributeHeaders2 = newXMLNode("RegionAttributeHeaders", parent=Regions2)           # ADD TO Regions1
      ## AttributeHeaders
      tempAttributeHeaders = newXMLNode("AttributeHeaders", parent=RegionAttributeHeaders2) 
      xmlAttrs(tempAttributeHeaders) = c(Name = "Region",Id = '9999',ColumunWidth = '-1')              # ADD Info
      tempAttributeHeaders = newXMLNode("AttributeHeaders", parent=RegionAttributeHeaders2) 
      xmlAttrs(tempAttributeHeaders) = c(Name = "Length",Id = '9997',ColumunWidth = '-1')              # ADD Info
      tempAttributeHeaders = newXMLNode("AttributeHeaders", parent=RegionAttributeHeaders2) 
      xmlAttrs(tempAttributeHeaders) = c(Name = "Area",Id = '9996',ColumunWidth = '-1')              # ADD Info
      tempAttributeHeaders = newXMLNode("AttributeHeaders", parent=RegionAttributeHeaders2) 
      xmlAttrs(tempAttributeHeaders) = c(Name = "Text",Id = '9998',ColumunWidth = '-1')              # ADD Info
      tempAttributeHeaders = newXMLNode("AttributeHeaders", parent=RegionAttributeHeaders2) 
      xmlAttrs(tempAttributeHeaders) = c(Name = "Description",Id = '1',ColumunWidth = '-1')              # ADD Info
      ## Region circle
      for(i in (1:nrow(NumberDf))){
        tempRegion = newXMLNode("Region", parent=Regions2)           # ADD TO Regions2
        xmlAttrs(tempRegion)=c(Selected = '0',
                               Type = '5',
                               Id = i,
                               DisplayId = i,
                               Analyze  = '0',
                               InputRegionId = '0',
                               NegativeROA = '0',
                               Text = '',
                               AreaMicrons = '0.0',
                               LengthMicrons = '0.0',
                               Area = '0.0',
                               Length = '0.0',
                               ImageFocus = '-1',
                               ImageLocation = '',
                               Zoom = '0.022562')              # ADD Info
        tempAttributes = newXMLNode("Attributes", parent=tempRegion)           # ADD TO tempRegion
        tempVertices = newXMLNode("Vertices", parent=tempRegion)           # ADD TO tempRegion
        tVertex = newXMLNode("Vertex", parent=tempVertices)           # ADD TO tempVertices
        xmlAttrs(tVertex) = c(Z = '0',Y = NumberDf$y0[i], X = NumberDf$x0[i])
        
      }
  }
  
  
  # SAVE XML TO FILE
  fileFullpath = unlist(strsplit(as.character(imageInfoDf$fullpath), "\\."))
  saveXML(doc, file=paste0(fileFullpath[1],'.xml'))
  return(doc)
}
