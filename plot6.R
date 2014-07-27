library(plyr)
library(RColorBrewer)

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

#First we need to merge the two datasets using the SCC column and two subset the data for baltimore and Los Angeles County.

completeNEI <- merge(NEI,SCC)
completeNEIBaltimore <- completeNEI[completeNEI$fips=="24510",]
completeNEILAC <- completeNEI[completeNEI$fips=="06037",]

# Same method than the last question on Mobile

mobileFactors <- levels(SCC$EI.Sector)[grepl("Mobile",levels(SCC$EI.Sector))]
mobileBaltimore <- completeNEIBaltimore[completeNEIBaltimore$EI.Sector %in% mobileFactors,]
mobileLAC <- completeNEILAC[completeNEILAC$EI.Sector %in% mobileFactors,]

#Now we can aggregate the emission per year to see how the evolved 1999 to 2008.
mobileBaltimorePerYear <- aggregate(Emissions~year, data=mobileBaltimore, sum)
mobileLACPerYear <- aggregate(Emissions~year, data=mobileLAC, sum)

## ploting the graph 

cols <- brewer.pal(4,"Oranges")
pal <- colorRampPalette(cols)
par(mfrow=c(2,1))
barplot(mobileBaltimorePerYear$Emissions, names.arg=mobileBaltimorePerYear$year, col=pal(4), main="Total PM2.5 Emissions per year from mobile sources in Baltimore", xlab="Year",ylab="Emissions (in tons)")
barplot(mobileLACPerYear$Emissions, names.arg=mobileLACPerYear$year, col=pal(4), main="Total PM2.5 Emissions per year from mobile sources in Los Angeles County", xlab="Year",ylab="Emissions (in tons)")

## I don't like dev.copy because it can be buggy sometimes, so I'll just redraw the graph in a different device.
png("plot6.png", width=720 , height=720)
par(mfrow=c(2,1))
barplot(mobileBaltimorePerYear$Emissions, names.arg=mobileBaltimorePerYear$year, col=pal(4), main="Total PM2.5 Emissions per year from mobile sources in Baltimore", xlab="Year",ylab="Emissions (in tons)")
barplot(mobileLACPerYear$Emissions, names.arg=mobileLACPerYear$year, col=pal(4), main="Total PM2.5 Emissions per year from mobile sources in Los Angeles County", xlab="Year",ylab="Emissions (in tons)")
dev.off()