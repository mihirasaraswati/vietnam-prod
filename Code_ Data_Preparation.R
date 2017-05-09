# Library Load ------------------------------------------------
library(survey)
library(dplyr)


# Read Data - Person File -------------------------------------------------
#read-in person data
per <- readRDS("./Raw_Data/pusab15.rds")

# Assign Data Types - Person File - Demographic Vars ------------------------------------
## Military Service (MIL)
per$MIL[which(is.na(per$MIL)==TRUE)] <- "b"
per$MIL <- factor(per$MIL, levels = c("b", 1:4), labels = c("< 17 yrs", "Active Duty", "Veteran", "Reserve/Guard", "Never Served"))
per$MIL <- factor(per$MIL)

## Consolidate VPS levels into new variable Period
Period <- per$VPS
Period[Period==11] <- "WWII"
Period[Period %in% c(9, 10)] <- "Korea"
Period[Period %in% c(6,7,8)] <- "Vietnam"
Period[Period %in% c(4,5)] <- "Gulf I"
Period[Period %in% c(1,2,3)] <- "Gulf II"
Period[Period %in% c(2,3,5,7,8,10)] <- "Multiple"
Period[Period %in% c(12,13,14,15)] <- "Peacetime"

per <- cbind(per, Period)
rm(Period)

##Served in Vietnam War August 1964 - April 1975 (MLPE)
per$MLPE <- factor(per$MLPE, levels = c(0:1), labels = c("Did Not Serve", "Served"))

## Age (AGEP) Convert to discrete variable
#(none needed) (17-24, 25-34, 35-44, 45-54, 55-64, 65-74 and 75+)
Ager <- cut(per$AGEP, c(0, 17, 25, 35, 45, 55, 65, 75, 85, 95, 100), right = FALSE)
per <- cbind(per, Ager)
rm(Ager)

## Gender (SEX)
per$SEX <- factor(per$SEX, levels = c(1:2), labels = c("Male", "Female"))

## Race/ethnicity (RAC1P) NOT Hispanic
#Create new variable RaceNH to account for hispanic (HISP) status
RaceNH <- character(length = nrow(per))
per <- cbind(per, RaceNH, stringsAsFactors = FALSE)
rm(RaceNH)
#White NH
per <- per %>% mutate(RaceNH = replace(RaceNH, which(HISP==1 & RAC1P==1), "White NH"))
#Black NH
per <- per %>% mutate(RaceNH = replace(RaceNH, which(HISP==1 & RAC1P==2), "Black NH"))
#AIAN NH
per <- per %>% mutate(RaceNH = replace(RaceNH, which(HISP==1 & RAC1P %in% c(3:5)), "AIAN NH"))
#Asian NH
per <- per %>% mutate(RaceNH = replace(RaceNH, which(HISP==1 & RAC1P==6), "Asian NH"))
#NHOPI NH
per <- per %>% mutate(RaceNH = replace(RaceNH, which(HISP==1 & RAC1P==7), "NHOPI NH"))
#Some Other Race (SOR) NH
per <- per %>% mutate(RaceNH = replace(RaceNH, which(HISP==1 & RAC1P==8), "SOR NH"))
#Two or more races (2+ Race NH)
per <- per %>% mutate(RaceNH = replace(RaceNH, which(HISP==1 & RAC1P==9), "2+ Race NH"))
#Hispanic
per <- per %>% mutate(RaceNH = replace(RaceNH, which(HISP>=2 ), "Hispanic"))

## Race/ethnicity (RAC1P) NOT Hispanic COLLAPSED
#Create new variable RaceNHC to account for hispanic (HISP) status
RaceNHC <- per$RaceNH
RaceNHC[RaceNHC=="White NH"] <- "White"
RaceNHC[RaceNHC=="Black NH"] <- "Black"
RaceNHC[RaceNHC=="AIAN NH"] <- "AIAN"
RaceNHC[RaceNHC %in% c("Asian NH", "NHOPI NH")] <- "Asian/NHOPI"
RaceNHC[RaceNHC %in% c("SOR NH", "2+ Race NH")] <- "Other"
RaceNHC[RaceNHC=="Hispanic"] <- "Hispanic"
per <- cbind(per, RaceNHC)
rm(RaceNHC)

## Race/ethnicity (RAC1P) Includes Hispanic
#Create new variable RaceHis to account for hispanic (HISP) status
RaceHis <- character(length = nrow(per))
per <- cbind(per, RaceHis, stringsAsFactors = FALSE)
rm(RaceHis)
#White 
per <- per %>% mutate(RaceHis = replace(RaceHis, which(RAC1P==1), "White"))
#Black
per <- per %>% mutate(RaceHis = replace(RaceHis, which(RAC1P==2), "Black"))
#AIAN
per <- per %>% mutate(RaceHis = replace(RaceHis, which(RAC1P %in% c(3:5)), "AIAN"))
#Asian
per <- per %>% mutate(RaceHis = replace(RaceHis, which(RAC1P==6), "Asian"))
#NHOPI
per <- per %>% mutate(RaceHis = replace(RaceHis, which(RAC1P==7), "NHOPI"))
#Some Other Race (SOR)
per <- per %>% mutate(RaceHis = replace(RaceHis, which(RAC1P==8), "SOR"))
#Two or more races (2+ Race)
per <- per %>% mutate(RaceHis = replace(RaceHis, which(RAC1P==9), "2+ Race"))
#Hispanic
per <- per %>% mutate(RaceHis = replace(RaceHis, which(HISP>=2 ), "Hispanic"))

## Marital Status (MAR)
per$MAR <- factor(per$MAR, levels = c(1:5), labels = c("Married", "Widowed", "Divorced", "Separated", "Never Married"))
per$MAR <- droplevels(per$MAR)

## Location State (ST)
#ACS data dictionary has a typo. Arizona is incorrectly abbreviated as AR instead of AZ
st.code <- read.csv("ACS_ST_Code.csv", header = TRUE, sep = ",", colClasses = c("character"))
per$ST <- factor(per$ST, levels = st.code$Code, labels = st.code$State)
rm(st.code)
per$ST <- factor(per$ST)

## Disability Recode (DIS)
per$DIS <- factor(per$DIS, levels = c(1:2), labels = c("With", "Without"))

## Veterans Service Connected Disability Rating (DRATX)
per$DRATX <- factor(per$DRATX, levels = c(1:2), labels = c("Yes", "No"))

## Veteran Service Connected Disability Rating (DRAT)
per$DRAT <- factor(per$DRAT, levels = c(1:6), labels = c("0%", "10-20%", "30-40%", "50-60%", "70% <", "Not Reported"))

## Independent Living Difficulty (DOUT)
per$DOUT <- factor(per$DOUT, levels = c(1:2), labels = c("Yes", "No"))

# Assign Data Types - Person File - Socio-economics Vars ---------------------------------

## (SCHL) Education Level - Consolidate SCHL levels into new variable Educ
#Create new variable Educ
Educ <- character(length = nrow(per))
per <- cbind(per, Educ, stringsAsFactors = FALSE)
rm(Educ)
#Recode Educ levels
#Less than HS
per <- per %>% mutate(Educ = replace(Educ, which(SCHL %in% c(1:15)), "Less than HS Grad"))
#HS Grad
per <- per %>% mutate(Educ = replace(Educ, which(SCHL %in% c(16:17)), "HS Grad"))
#Some College
per <- per %>% mutate(Educ = replace(Educ, which(SCHL %in% c(18:20)), "Some College"))
#Bachelor's Degree
per <- per %>% mutate(Educ = replace(Educ, which(SCHL==21), "Bachelor's Degree"))
#Advanced Degree
per <- per %>% mutate(Educ = replace(Educ, which(SCHL %in% c(22:24)), "Advanced Degree"))

## (COW) Class of worker - describing the relationship to the employer
CowR <- character(length = nrow(per))
per <- cbind(per, CowR, stringsAsFactors = FALSE)
rm(CowR)
#Private
per <- per %>% mutate(CowR = replace(CowR, which(COW %in% c(1,2,8)), "Private"))
#Government
per <- per %>% mutate(CowR = replace(CowR, which(COW %in% c(3,4,5)), "Govt"))
#Self-employed
per <- per %>% mutate(CowR = replace(CowR, which(COW %in% c(6,7)), "Self-employed"))
#Unemployed
per <- per %>% mutate(CowR = replace(CowR, which(COW==9), "Unemployed"))
#Convert blanks to NAs
per <- per %>% mutate(CowR = replace(CowR, which(CowR==""), NA))

## (ESR) Employment Status Recode - Consolidate Employment status recode 
#Armed Forces levels are not included since we're focused on Vets and General Population
#Create EmpPct variable
EmpPct <- character(length = nrow(per))
per <- cbind(per, EmpPct, stringsAsFactors = FALSE)
rm(EmpPct)
#Employed
per <- per %>% mutate(EmpPct = replace(EmpPct, which(ESR %in% c(1:2)), "Employed"))
#Unemployed
per <- per %>% mutate(EmpPct = replace(EmpPct, which(ESR==3), "Unemployed"))
#Not In Labor Forces
per <- per %>% mutate(EmpPct = replace(EmpPct, which(ESR==6), "Not in Labor Force"))

## Income-to-poverty ratio recode (POVPIP)
Pov <- character(length = nrow(per))
per <- cbind(per, Pov, stringsAsFactors = FALSE)
rm(Pov)
#Assign poverty levels to Pov
per <- per %>% mutate(Pov = replace(Pov, which(POVPIP >= 0 & POVPIP <= 99), 1))
per <- per %>% mutate(Pov = replace(Pov, which(POVPIP >= 100 & POVPIP <= 149), 2))
per <- per %>% mutate(Pov = replace(Pov, which(POVPIP >= 150 & POVPIP <= 199), 3))
per <- per %>% mutate(Pov = replace(Pov, which(POVPIP >= 200 & POVPIP <= 299), 4))
per <- per %>% mutate(Pov = replace(Pov, which(POVPIP >= 300 & POVPIP <= 399), 5))
per <- per %>% mutate(Pov = replace(Pov, which(POVPIP >= 400), 6))
per <- per %>% mutate(Pov = replace(Pov, which(is.na(POVPIP)==TRUE), NA))

#Poverty Roll-Up
Povty <- character(length = nrow(per))
per <- cbind(per, Povty, stringsAsFactors = FALSE)
rm(Povty)
per <- per %>% mutate(Povty = replace(Povty, which(Pov == 1), "In Poverty"))
per <- per %>% mutate(Povty = replace(Povty, which(Pov > 1), "At or Above Poverty"))
per <- per %>% mutate(Povty = replace(Povty, which(is.na(Pov)==TRUE), NA))

##Personal Earning(PERNP)
Pernpc <- character(length = nrow(per))
per <- cbind(per, Pernpc, stringsAsFactors = FALSE)
rm(Pernpc)
per$Pernpc <- cut(per$PERNP, c(seq(0, 100000, 20000), 1164000), right = FALSE)

#Personal Income (PINCP)
Pincpc <- character(length = nrow(per))
per <- cbind(per, Pincpc, stringsAsFactors = FALSE)
rm(Pincpc)
per$Pincpc <- cut(per$PINCP, c(seq(0, 100000, 20000), 1655000), right = FALSE)

#Retirement Income
Retpc <- character(length = nrow(per))
per <- cbind(per, Retpc, stringsAsFactors = FALSE)
rm(Retpc)
per$Retpc <- cut(per$RETP, c(seq(0, 125000, 25000), 333000), right = FALSE)

##Health Insurance Coverage (HICOV)
per$HICOV <- factor(per$HICOV, levels = c(1:2), labels = c("Yes", "No"))

## ( HINS1-7)Health Insurance Coverage - Create new variale that combines HICOV, PRIVCOV, PUBCOV
HITYPE<- character(length = nrow(per))
per <- cbind(per, HITYPE, stringsAsFactors = FALSE)
rm(HITYPE)

per$HITYPE[which(per$HICOV ==2)] <- "No Coverage"
per$HITYPE[which(per$HICOV=="Yes" & per$PRIVCOV==1 & per$PUBCOV==2)] <- "Private Only"
per$HITYPE[which(per$HICOV=="Yes" & per$PRIVCOV==2 & per$PUBCOV==1)] <- "Public Only"
per$HITYPE[which(per$HICOV=="Yes" & per$PRIVCOV==1 & per$PUBCOV==1)] <- "Public and Private"
#Convert blanks to NA
per$HITYPE[per$HITYPE==""] <- NA

## Used/Enrolled VA health care (HINS6 -vahc)
per$HINS6 <- factor(per$HINS6, levels=c(1:2), labels = c("Uses VA", "Does Not Use VA"))

## Specific Insurance Type (Ins)
#Consolidate values in HINS1:HINS7 into a single categorical variable Ins
#Create Ins variable and combine with person dataset
Ins <- character(length = nrow(per))
per <- cbind(per, Ins, stringsAsFactors = FALSE)
rm(Ins)
#Identify "VA Only" users
per <- per %>% mutate(Ins = replace(Ins, which(HINS6=="Uses VA" & HINS1==2 & HINS2==2 & HINS3==2 & HINS4==2 & HINS5==2 & HINS7==2), "VA Only"))
#VA & Private
per <- per %>% mutate(Ins = replace(Ins, which(HINS6=="Uses VA" & (HINS1==1 | HINS2==1) & (HINS3==2 & HINS4==2 & HINS5==2 & HINS7==2)), "VA & Private"))
#VA & Public
per <- per %>% mutate(Ins = replace(Ins, which(HINS6=="Uses VA" & (HINS1==2 & HINS2==2) & (HINS3==1 | HINS4==1 | HINS5==1 | HINS7==1)), "VA & Public"))
#VA, Public, & Private
per <- per %>% mutate(Ins = replace(Ins, which(HINS6=="Uses VA" & (HINS1==1 | HINS2==1) & (HINS3==1 | HINS4==1 | HINS5==1 | HINS7==1)), "VA, Public & Private"))
#Direct Only
per <- per %>% mutate(Ins = replace(Ins, which(HINS2==1 & HINS1==2 & HINS3==2 & HINS4==2 & HINS5==2 & HINS6=="Does Not Use VA" & HINS7==2), "Direct"))
#Medicare Only
per <- per %>% mutate(Ins = replace(Ins, which(HINS3==1 & HINS1==2 & HINS2==2 & HINS4==2 & HINS5==2 & HINS6=="Does Not Use VA" & HINS7==2), "Medicare"))
#Medicaid Only
per <- per %>% mutate(Ins = replace(Ins, which(HINS4==1 & HINS1==2 & HINS2==2 & HINS3==2 & HINS5==2 & HINS6=="Does Not Use VA" & HINS7==2), "Medicaid"))
#Tricare Only
per <- per %>% mutate(Ins = replace(Ins, which(HINS5==1 & HINS1==2 & HINS2==2 & HINS3==2 & HINS4==2 & HINS6=="Does Not Use VA" & HINS7==2), "Tricare"))
#IHS 
per <- per %>% mutate(Ins = replace(Ins, which(HINS7==1 & HINS1==2 & HINS2==2 & HINS3==2 & HINS4==2 & HINS5==2 & HINS6=="Does Not Use VA"), "IHS"))
#Employer & VA
per <- per %>% mutate(Ins = replace(Ins, which(HINS1==1 & HINS2==2 & HINS3==2 & HINS4==2 & HINS5==2 & HINS6=="Does Not Use VA" & HINS7==2), "Employer & VA"))
#Employer & Tricare
per <- per %>% mutate(Ins = replace(Ins, which(HINS1==1 & HINS2==2 & HINS3==2 & HINS4==2 & HINS5==1 & HINS6=="Does Not Use VA" & HINS7==2), "Employer & Tricare"))
#Convert blanks to NAs
per <- per %>% mutate(Ins = replace(Ins, which(Ins==""), NA))



# Create Survey Object - Person File ----------------------------------------

#create data frame with profile variables
per_prof <- select(per, RT, SERIALNO, MIL, Period, MLPE, AGEP, Ager, SEX, RaceNH, RaceNHC, MAR, ST, DIS, DRATX, DRAT, DOUT, Educ, CowR, EmpPct, Pov, Povty, HICOV, HITYPE, HINS6, Ins, RETP, Retpc, PERNP, Pernpc, PINCP, Pincpc, PWGTP, pwgtp1:pwgtp80)
#clear workspace
rm(per)

#create survey design object - PROFILE Variables
prof_design <- svydesign(id = ~1, 
                         weights = per_prof$PWGTP,
                         data = per_prof,
                         repweights = "pwgtp[0-9]+",
                         type = "JKn",
                         scale = 4/80, 
                         rscales = rep(1,80),
                         combined.weights = TRUE
)

#Subset survey design object for Vietnam Veterans
viet_design <- subset(prof_design, MIL=="Veteran" & Period=="Vietnam")
#save
saveRDS(viet_design, file = "Data_Viet_Design.Rds")

##create survey design object - General Population AGE OVER 55
per55_design <- subset(prof_design, AGEP >=55 & MIL=="Never Served")
#save
saveRDS(per55_design, file = "Data_Per55_Design.Rds")
#clear workspace
rm(prof_design)


# ###HOUSING FILE DATA PREPARATION -------------------------------------------

# Read Data - Housing File ------------------------------------------------
hou <- readRDS("./Raw_Data/husab15.rds")

# Assign Data Types - Housing File ----------------------------------------
#Housing Type (TYPE)
hou$TYPE <- factor(hou$TYPE, levels = c(1:3), labels = c("Housing Unit", "Institutional GQ", "Non-Institutional GQ"))

#Housing Tenure (TEN)
hou$TEN <- factor(hou$TEN, levels = c(1:4), labels = c("Own w/ Mortgage", "Own Free Clear", "Rent", "No Rent" ))

#Group Quarter (TEN - GQ)
GQ <- character(length = nrow(hou))
hou <- cbind(hou, GQ, stringsAsFactors = FALSE)
rm(GQ)
hou <- hou %>% mutate(GQ = replace(GQ, which(is.na(TEN)==TRUE), NA))
hou <- hou %>% mutate(GQ = replace(GQ, which(TEN!="GQ/Vacant"), "Not in GQ"))

#Housing Tenure (TEN - Own)
Own <- character(length = nrow(hou))
hou <- cbind(hou, Own, stringsAsFactors = FALSE)
rm(Own)
hou <- hou %>% mutate(Own = replace(Own, which(is.na(TEN)==TRUE), NA))
hou <- hou %>% mutate(Own = replace(Own, which(TEN=="Own w/ Mortgage" | TEN=="Own Free Clear"), "Owns Home"))
hou <- hou %>% mutate(Own = replace(Own, which(TEN=="Rent" | TEN=="No Rent"), "Rent/Rent Free"))

#Type of HOusehold
HouseType <- character(length = nrow(hou))
hou <- cbind(hou, HouseType, stringsAsFactors = FALSE)
rm(HouseType)
hou <- hou %>% mutate(HouseType = replace(HouseType, which(is.na(HHT)== TRUE), NA))
hou <- hou %>% mutate(HouseType = replace(HouseType, which(HHT==1), "Married Couple"))
hou <- hou %>% mutate(HouseType = replace(HouseType, which(HHT==2), "Family HH Male"))
hou <- hou %>% mutate(HouseType = replace(HouseType, which(HHT==3), "Family HH Female"))
hou <- hou %>% mutate(HouseType = replace(HouseType, which(HHT>3), "Non Family HH"))

#Number of Persons in House (NP)
People <- character(length = nrow(hou))
hou <- cbind(hou, People, stringsAsFactors = FALSE)
rm(People)
hou <- hou %>% mutate(People = replace(People, which(NP==0), "Vacant Unit"))
hou <- hou %>% mutate(People = replace(People, which(NP==1), "1"))
hou <- hou %>% mutate(People = replace(People, which(NP==2), "2"))
hou <- hou %>% mutate(People = replace(People, which(NP==3), "3"))
hou <- hou %>% mutate(People = replace(People, which(NP>3), "3+"))

#Presence of Children
Kids <- character(length = nrow(hou))
hou <- cbind(hou, Kids, stringsAsFactors = FALSE)
rm(Kids)
hou <- hou %>% mutate(Kids= replace(Kids, which(is.na(NOC)==TRUE), NA))
hou <- hou %>% mutate(Kids= replace(Kids, which(NOC==0), "No Kids"))
hou <- hou %>% mutate(Kids= replace(Kids, which(NOC>=1), "Kids in HH"))

#Presence of 65 and over
Elder <- character(length = nrow(hou))
hou <- cbind(hou, Elder, stringsAsFactors = FALSE)
rm(Elder)
hou <- hou %>% mutate(Elder= replace(Elder, which(is.na(R65)== TRUE), NA))
hou <- hou %>% mutate(Elder= replace(Elder, which(R65==0), "No Elder"))
hou <- hou %>% mutate(Elder= replace(Elder, which(R65==1), "1 Elder"))
hou <- hou %>% mutate(Elder= replace(Elder, which(R65==2), "2+ Elder"))

#Presence of 18 and under
Teen <- character(length = nrow(hou))
hou <- cbind(hou, Teen, stringsAsFactors = FALSE)
rm(Teen)
hou <- hou %>% mutate(Teen = replace(Teen, which(is.na(R18)== TRUE), NA))
hou <- hou %>% mutate(Teen = replace(Teen, which(R18==0), "No Teen"))
hou <- hou %>% mutate(Teen = replace(Teen, which(R18==1), "1+ Teen"))

#Food Stamp (FS)
hou$FS <- factor(hou$FS, levels = c(1:2), labels = c("Yes", "No"))

#Number of Automobiles (VEH - Autos)
Autos <- character(length = nrow(hou))
hou <- cbind(hou, Autos, stringsAsFactors = FALSE)
rm(Autos)
hou <- hou %>% mutate(Autos = replace(Autos, which(is.na(VEH)==TRUE), NA))
hou <- hou %>% mutate(Autos = replace(Autos, which(VEH == 0), "0"))
hou <- hou %>% mutate(Autos = replace(Autos, which(VEH == 1), "1"))
hou <- hou %>% mutate(Autos = replace(Autos, which(VEH == 2), "2"))
hou <- hou %>% mutate(Autos = replace(Autos, which(VEH == 3 | VEH == 4 | VEH== 5 | VEH == 6), "3+"))

#Access to the Internet (ACCESS - Internet)
Internet <- character(length = nrow(hou))
hou <- cbind(hou, Internet, stringsAsFactors = FALSE)
rm(Internet)
hou <- hou %>% mutate(Internet = replace(Internet, which(is.na(ACCESS)== TRUE), NA))
hou <- hou %>% mutate(Internet = replace(Internet, which(ACCESS==1 | ACCESS==2), "Yes"))
hou <- hou %>% mutate(Internet = replace(Internet, which(ACCESS==3), "No"))

#Broadband - Mobile Broadband Plan (BROADBND)
MobileBB <- character(length = nrow(hou))
hou <- cbind(hou, MobileBB, stringsAsFactors = FALSE)
rm(MobileBB)
hou <- hou %>% mutate(MobileBB = replace(MobileBB, which(is.na(BROADBND)==TRUE), NA))
hou <- hou %>% mutate(MobileBB = replace(MobileBB, which(BROADBND==1), "Yes"))
hou <- hou %>% mutate(MobileBB = replace(MobileBB, which(BROADBND==2), "No"))

# Create Survey Object - Housing File -------------------------------------

#subset hou to select relevant variables
hou <- select(hou, c(RT, SERIALNO, TYPE, TEN, GQ, Own, HouseType, NP, People, Kids, Elder, Teen, FS, Autos, VEH, Internet, MobileBB, WGTP, wgtp1:wgtp80))

#create the survey design object with relevant variables only
hou_prof_design <- svrepdesign(repweights = 'wgtp[0-9]+', 
                               weights = ~WGTP, 
                               data = hou,
                               type = "JKn",
                               scale = 4/80, 
                               rscales = rep(1,80),
                               mse = TRUE
)
#save
# saveRDS(hou_prof_design, file = "Data_Hou_Prof_Design.Rds")
#clear workspace
rm(hou)

#subset hou_prof_design to select Vietnam era vets
hou_viet_design <- subset(hou_prof_design, SERIALNO %in% viet_design$variables$SERIALNO)
#save
saveRDS(hou_viet_design, file = "Data_Hou_Viet_Design.Rds")
rm(viet_design)

#subset hou_prof_design to select General Pop (Age over 55)
hou55_design <- subset(hou_prof_design, SERIALNO %in% per55_design$variables$SERIALNO)
#save
saveRDS(hou55_design, file = "Data_Hou55_Design.Rds")
rm(hou_prof_design, per55_design)


# Create Survey Objects (Vietnam and General Population) for Group Quarters ---------------------------------

####Vietnam Vet GQ Survey Object - Creating a new survey design object where the TYPE variable from the Housing file can be combined with the Weights from the Person File

#select SERIALNO from hou_viet that are in GQ
hou_viet_gq_serialno <- hou_viet_design$variables$SERIALNO[which(hou_viet_design$variables$TYPE %in% c("Institutional GQ", "Non-Institutional GQ"))]
# select TYPE column, subset on GQ
hou_viet_typegq <- hou_viet_design$variables$TYPE[which(hou_viet_design$variables$TYPE %in% c("Institutional GQ", "Non-Institutional GQ"))]
#new survey object that consists of Vietnam Vets in GQ
per_viet_gq <- subset(per_prof, SERIALNO %in% hou_viet_gq_serialno)
per_viet_gq <- cbind(per_viet_gq, hou_viet_typegq)
per_viet_gq <- per_viet_gq %>% rename(TYPE = hou_viet_typegq)

per_vietgq_design <- svrepdesign(repweights = 'pwgtp[0-9]+', 
                                 weights = ~PWGTP, 
                                 data = per_viet_gq,
                                 type = "JKn",
                                 scale = 4/80, 
                                 rscales = rep(1,80),
                                 mse = TRUE
)
#Save
saveRDS(per_vietgq_design, file = "Data_Per_Viet_GQ_Design.Rds")
rm(hou_viet_design, hou_viet_gq_serialno, hou_viet_typegq, per_viet_gq, per_vietgq_design)

####General Popuation GQ Survey Object

#select SERIALNO from hou55 that are in GQ
hou55_gq_serialno <- hou55_design$variables$SERIALNO[which(hou55_design$variables$TYPE %in% c("Institutional GQ", "Non-Institutional GQ"))]
# select TYPE column, subset on GQ
hou55_typegq <- hou55_design$variables$TYPE[which(hou55_design$variables$TYPE %in% c("Institutional GQ", "Non-Institutional GQ"))]
rm(hou55_design)

#new survey object that consists of Vietnam Vets in GQ
per55_gq <- subset(per_prof, SERIALNO %in% hou55_gq_serialno)
per55_gq <- cbind(per55_gq, hou55_typegq)
per55_gq <- per55_gq %>% rename(TYPE = hou55_typegq)

per55_gq_design <- svrepdesign(repweights = 'pwgtp[0-9]+', 
                               weights = ~PWGTP, 
                               data = per55_gq,
                               type = "JKn",
                               scale = 4/80, 
                               rscales = rep(1,80),
                               mse = TRUE
)
#Save
saveRDS(per55_gq_design, file = "Data_Per55_GQ_Design.Rds")
rm(per_prof, hou55_gq_serialno, hou55_typegq, per55_gq, per55_gq_design)

