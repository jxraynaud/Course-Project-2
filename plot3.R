library(plyr)
library(RColorBrewer)
library(ggplot2)

## Checks if the data exists and is in the correct path
## DL and unzip the file if something is missing

if(!file.exists("data") | !file.exists("data/summarySCC_PM25.rds") | !file.exists("data/Source_Classification_Code.rds")){
        temp <- tempfile() # Create a temp file to store the zip
        download.file("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip",temp) # DL it
        unzip(temp,exdir="data", list=FALSE, overwrite=TRUE) # unzip it in ./data/ and overwrite any previous file (to insure data consistency)
        unlink(temp) # Remove the file from the system
        rm(temp) # Delete the unneeded pointer to the file
}

## Now we can load the data

NEI <- readRDS("data/summarySCC_PM25.rds")
SCC <- readRDS("data/Source_Classification_Code.rds")

## We need to subset Baltimore City (on fips = 24510)

BaltimoreNEI <- NEI[NEI$fips=="24510",]
BaltimoreNEI$year <- as.factor(BaltimoreNEI$year)


## We simply do the same thing than in question 1 using this dataset 
## And using a different pal, hopping to obtain a less ugly graph ;)

## aggregate the emissions per year and per type of source

yearEmissionsBaltimore <- aggregate(Emissions~year + type, data=BaltimoreNEI, sum)

## ploting the graph using qplot from ggplot2 library (should produce one graph per type of source)

cols <- brewer.pal(4,"Oranges")
pal <- colorRampPalette(cols)
qplot(x=year, y=Emissions, fill=type, data=yearEmissionsBaltimore, geom="bar", stat="identity", position="dodge", main="Total PM2.5 Emission per year and type in Baltimore")

## I don't like dev.copy because it can be buggy sometimes, so I'll just redraw the graph in a different device.
png("plot3.png", width=720 , height=480)
qplot(x=year, y=Emissions, fill=type, data=yearEmissionsBaltimore, geom="bar", stat="identity", position="dodge", main="Total PM2.5 Emission per year and type in Baltimore")
dev.off()