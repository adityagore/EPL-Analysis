# This file parses whoscored.com for data and stores it
# file soccerdata.RData

# Load XML package
if(!require(XML)){
  install.packages("XML")
  require(XML)
} else {
  require(XML)
}


# Load RSelenium package
if(!require(RSelenium)){
  install.packages("RSelenium")
  require(RSelenium)
} else {
  require(RSelenium)
}

# Load reshape2 package
if(!require(reshape2)){
  install.packages("reshape2")
  require(reshape2)
} else {
  require(reshape2)
}

# whoscored.com url
url <- "http://www.whoscored.com/Regions/252/Tournaments/2/Seasons/4311/Stages/9155/PlayerStatistics/England-Premier-League-2014-2015"

checkForServer() # Checking if the files for remoteserver are there
startServer() # Starting the remoteserver

# fprof <- getFirefoxProfile("firefoxprofile",useBase=TRUE) # getting the firefox profile from current directory

remDr <- remoteDriver(browserName="firefox")#, extraCapabilities=fprof)

remDr$open(silent=TRUE)

remDr$navigate(url)

firstpage <- remDr$getPageSource()

firstpage.parse <- htmlParse(firstpage,asText = TRUE)
assistData.gs <- getNodeSet(firstpage.parse,"//*[@id='player-assist-table-body']/tr/td[2]/a/text()")
assistData.gs <- melt(xmlApply(assistData.gs,xmlValue),value.name="Goal Scorer")$"Goal Scorer"
assistData.ab <- getNodeSet(firstpage.parse,"//*[@id='player-assist-table-body']/tr/td[3]/a/text()")
assistData.ab <- melt(xmlApply(assistData.ab,xmlValue),value.name="Assist By")$"Assist By"
assistData.tm <- getNodeSet(firstpage.parse,"//*[@id='player-assist-table-body']/tr/td[4]/a")
assistData.tm <- melt(xmlApply(assistData.tm,xmlValue),value.name="Team")$"Team"
assistData.as <- getNodeSet(firstpage.parse,"//*[@id='player-assist-table-body']/tr/td[5]")
assistData.as <- melt(xmlApply(assistData.as,xmlValue),value.name="Assists")$"Assists"

assistData <- data.frame("Goal Scorer" = assistData.gs,
                         "Assist By" = assistData.ab,
                         "Team" = assistData.tm,
                         "Assists" = assistData.as)

webElem <- remDr$findElement(using="xpath","//*[@id='detailed-statistics-tab']/a")
