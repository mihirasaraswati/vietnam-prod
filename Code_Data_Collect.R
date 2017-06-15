# PERSON FILES - Download, Unzip, Consolidate, and Save -------------------

#Create temp file to store downloaded zip file
temp <- tempfile()

#Download Person file for Puerto Rico 
download.file(url = "https://www2.census.gov/programs-surveys/acs/data/pums/2015/1-Year/csv_ppr.zip", destfile = temp)

#unzip Person File Puerto Rico
ppr15 <- read.csv(unzip(zipfile = temp, files = c("ss15ppr.csv"),  exdir = "./Data"))

#Download Person file for US
download.file(url = "https://www2.census.gov/programs-surveys/acs/data/pums/2015/1-Year/csv_pus.zip", destfile = temp)

#unzip Person US A & B Files
pusa15 <-read.csv(unzip(zipfile = temp, files = c("ss15pusa.csv"),  exdir = "./Data"))
pusb15 <-read.csv(unzip(zipfile = temp, files = c("ss15pusb.csv"),  exdir = "./Data"))

#Combine all Person files
pusab15 <- rbind(pusa15, pusb15, ppr15)

#clear workspace
rm(pusa15, pusb15, ppr15, temp)

#Save consolidated Person files as *.Rds
saveRDS(pusab15, "./Data/pusab15.rds")

#rm Person data frame
rm(pusab15)


# HOUSING FILES - Download, Unzip, Consolidate, and Save ------------------

#Create temp file to store downloaded zip file
temp <- tempfile()

#Download HOUSING file for Puerto Rico 
download.file(url = "https://www2.census.gov/programs-surveys/acs/data/pums/2015/1-Year/csv_hpr.zip", destfile = temp)

#unzip HOUSING File Puerto Rico
hpr15 <- read.csv(unzip(zipfile = temp, files = c("ss15hpr.csv"),  exdir = "./Data"))

#Download HOUSING file for US
download.file(url = "https://www2.census.gov/programs-surveys/acs/data/pums/2015/1-Year/csv_hus.zip", destfile = temp)

#unzip HOUSING US A & B Files
husa15 <-read.csv(unzip(zipfile = temp, files = c("ss15husa.csv"),  exdir = "./Data"))
husb15 <-read.csv(unzip(zipfile = temp, files = c("ss15husb.csv"),  exdir = "./Data"))

#Combine all Person files
husab15 <- rbind(husa15, husb15, hpr15)

#clear workspace
rm(husa15, husb15, hpr15, temp)

#Save consolidated Person files as *.Rds
saveRDS(husab15, "./Data/husab15.rds")

#rm HOUSING data frame
rm(husab15)
