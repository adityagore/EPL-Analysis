rm(list=ls())
if(!require(httr)){
  install.packages("httr")
  require(httr)
} else {
  require(httr)
}

if(!require(RJSONIO)){
  install.packages("RJSONIO")
  require(RJSONIO)
} else {
  require(RJSONIO)
}


nullToNa <- function(x){
  if(is.null(x)){
    x <- NA
  }
  else x
}

categoryList <- list('shots'='zones',
                     'shots'='situations',
                     'shots'='accuracy',
                     'shots'='bodyparts',
                     'goals'='zones',
                     'goals'='situations',
                     'goals'='bodyparts',
                     'dribbles'='success',
                     'possession-loss'='type',
                     'aerial'='success',
                     'passes'='length',
                     'passes'='type',
                     'key-passes'='length',
                     'key-passes'='type',
                     'assists'='type',
                     'tackles'='success',
                     'interception'='success',
                     'fouls'='type',
                     'cards'='type',
                     'offsides'='type',
                     'clearances'='success',
                     'blocks'='type',
                     'saves'='shotzone'
                     )

stageId <- c('9155','7794','6531','5476','4345','3115','12496')

url <- 'http://www.whoscored.com/StatisticsFeed/1/GetPlayerStatistics'

params <- list('category'='shots','subcategory'='situations',
           'statsAccumulationType'='0',
           'isCurrent'='true',
           'playerId'='','teamIds'='',
           'matchId'='',
           'stageId'='9155',
           'tournamentOptions'='2',
           'sortBy'='Rating','sortAscending'='',
           'age'='','ageComparisonType'='','appearances'='',
           'appearancesComparisonType'='0',
           'field'='','nationality'='',
           'positionOptions'="'FW','AML','AMC','AMR','ML','MC','MR','DMC','DL','DC','DR','GK','Sub'",
           'timeOfTheGameEnd'='5','timeOfTheGameStart'='0',
           'isMinApp'='',
           'page'='1','includeZeroValues'='',
           'numberOfPlayersToPick'='1200')



headers <- c('User-Agent'='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36',
            'X-Requested-With'='XMLHttpRequest',
            'Host'='www.whoscored.com',
            'Referer'='http://www.whoscored.com/')

playerTotalStats <- data.frame("seasonId"=as.numeric())

for(j in seq_len(length(stageId))){
  params['stageId'] = stageId[j]
  for(i in seq_len(length(categoryList))){
    params['category'] = names(categoryList)[i]
    params['subcategory'] = categoryList[[i]]
    response <- GET(url,add_headers(headers),query=params)
    json.content <- as.character(rawToChar(response$content))
    playerTableStats <- fromJSON(json.content)$playerTableStats
    playerTableStats <- lapply(playerTableStats,function(x){lapply(x,nullToNa)})
    playerTableStats <- do.call(rbind,lapply(playerTableStats,data.frame,stringsAsFactors=FALSE))
    playerTotalStats <- merge(playerTotalStats,playerTableStats,
                              by=intersect(names(playerTotalStats),names(playerTableStats)),all=TRUE)
    print(stageId[j])
    print(categoryList[i])
  }
}

save(playerTotalStats,file="playerData.RData")










