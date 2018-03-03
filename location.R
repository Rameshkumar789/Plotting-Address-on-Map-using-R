library(devtools)
#install_github("DerekYves/placement")
library(placement)
library(ggmap)
library(RJSONIO)
library(ggplot2)
library(leaflet)

startTime <- Sys.time()

fileToLoad <- file.choose(new = TRUE)


# Read in the CSV data and store it in a variable 
origAddress <- read.csv(fileToLoad, stringsAsFactors = FALSE)

View(origAddress)

Street=origAddress$address
City=origAddress$city
State=origAddress$State
country=origAddress$county
PinCode=origAddress$zip
origAddress$locations=paste(Street,',',City,',',State,',',country,',',PinCode,sep="")

origAddress$locationsNa=paste(City,',',State,',',country,',',PinCode,sep="")


for(i in 1:nrow(origAddress))
{
  
  require(RJSONIO)
  url <- "http://maps.google.com/maps/api/geocode/json?address="
  url <- URLencode(paste(url,origAddress$locations[i], "&sensor=false", sep = ""))
  x <- fromJSON(url, simplify = FALSE)
  if (x$status == "OK") {
    out <- "ok"
    origAddress$lng[i]<-x$results[[1]]$geometry$location$lng
    origAddress$lat[i]<-x$results[[1]]$geometry$location$lat
  } else {
    out <- "NA"
  }
  Sys.sleep(1.0)  # API only allows 5 requests per second
  print(out)
  if(out=="NA")
  {
  result <- geocode_url(origAddress$locations[i], auth="standard_api", privkey="AIzaSyCvSWsSHvcAbzPu--g1-89u7XaeUqTHkzU",
                        clean=TRUE, add_date='today', verbose=TRUE)
  origAddress$lat[i]=result$lat
  origAddress$lng[i]=result$lng
  print(origAddress$lat[i])
  print(origAddress$lng[i])
}
}
for(i in 1:nrow(origAddress)) 
{
  if(is.na(origAddress$lat[i]))
  {
    print(origAddress$lat[i])
    result <- geocode_url(origAddress$locationsNa[i], auth="standard_api", privkey="AIzaSyCvSWsSHvcAbzPu--g1-89u7XaeUqTHkzU",
                          clean=TRUE, add_date='today', verbose=TRUE)
    origAddress$lat[i]=result$lat
    origAddress$lng[i]=result$lng
    print(origAddress$lat[i])
    print(origAddress$lng[i])
    origAddress$locations[i]<-origAddress$locationsNa[i]
  }
  
}

write.csv(origAddress, "geocodedmain.csv")


m <- leaflet()
m <- addTiles(m)

for(i in 1:nrow(origAddress))
{
  m <- addMarkers(m, lng=origAddress$lng[i], lat=origAddress$lat[i], popup=origAddress$Name[i])
}
m
