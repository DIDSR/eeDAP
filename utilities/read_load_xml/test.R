library(XML)
source('imageScopeXMLread.R')
source('imageScopeXMLcreate.R')
filename = 'C:/000_whole_slides/tissue40x-8B.xml'
annotationDf <- imageScopeXMLread(filename)
outputxml <- imageScopeXMLcreate(imageInfoDf=annotationDf$imageInfoDf,circleDf = annotationDf$circleDf,rectangleDf = annotationDf$rectangleDf,NumberDf = annotationDf$NumberDf)
