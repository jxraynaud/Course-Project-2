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

#First we need to merge the two datasets using the SCC column

completeNEI <- merge(NEI,SCC)

#To subset the data to only get the emissions from Coal combustion related sources we will use the column EI.Sector.
#THus we need to create a vector containing the labels with "Comb" and "Coal" from the levels(SCC$EI.Sector) vector.

CombCoalFactors <- levels(SCC$EI.Sector)[grepl("Comb",levels(SCC$EI.Sector)) & grepl("Coal",levels(SCC$EI.Sector))]
CombCoal <- completeNEI[completeNEI$EI.Sector %in% CombCoalFactors,]

#Now we can aggregate the emission per year to see how the evolved 1999 to 2008.
yearCombCoalEmissions <- aggregate(Emissions~year, data=CombCoal, sum)

## ploting the graph 

cols <- brewer.pal(4,"Oranges")
pal <- colorRampPalette(cols)
barplot(yearCombCoalEmissions$Emissions, names.arg=yearCombCoalEmissions$year, col=pal(4), main="Total PM2.5 Emissions per year from Coal Combustion related sources", xlab="Year",ylab="Emissions (in tons)")

## I don't like dev.copy because it can be buggy sometimes, so I'll just redraw the graph in a different device.
png("plot4.png", width=480 , height=480)
barplot(yearCombCoalEmissions$Emissions, names.arg=yearCombCoalEmissions$year, col=pal(4), main="TTotal PM2.5 Emissions per year from Coal Combustion related sources", xlab="Year",ylab="Emissions (in tons)")
dev.off()