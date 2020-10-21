install.packages("rgdal")
install.packages("maptools")
install.packages("tigris")
install.packages("leaflet")

library(dplyr)
library(ggmap)
library(stringr)
library(rgdal)
library(maptools)
library(tigris)
library(leaflet)
library(sf)
library(maps)
library(ggplot2)

#set working directory to dropbox file
setwd("C:/Users/Soohyun Hwangbo/Dropbox/0 Kinga and Sanaz/Discrimination_Project/Data/Clean_Data/Complaints")

#store complaints data
complaints<-read.csv("merged_data.csv")

#create a boolean variable that checks if a complaint has address info
#first, change address from factor to string to detect "N/A"
complaints$Respondent.Address<-as.character(complaints$Respondent.Address)
complaints$Respondent.Address<-trimws(complaints$Respondent.Address)

#identify cases that are either redacted or N/A as missing addresses
complaints$address_exists<-ifelse(complaints$addres_redacted==TRUE|
                                  complaints$Respondent.Address=="N/A"|complaints$Respondent.Address=="Unknown"
                                  |complaints$Respondent.Address=="No Address Provided"|complaints$Respondent.Address=="",
                                  FALSE,TRUE)

#georeferencing
#get API
register_google(key="AIzaSyBzF9RRgsihPHfQPdztWH7scxvQuF9aYKI",write=TRUE)

#use geocode in ggmap package
#get longitude and latitude
#geocode ONLY IF a case has address info
lonlat_output<-geocode(complaints[which(complaints$address_exists==TRUE),"Respondent.Address"])
write.csv(lonlat_output,"C:/Users/Soohyun Hwangbo/Dropbox/0 Kinga and Sanaz/Discrimination_Project/Code/Georeferencing/lonlat_data_pt1.csv")

#subset cases with address info into a separate dataframe
complaints_add<-complaints[which(complaints$address_exists==TRUE),]

#merge complaints & lon/lat for easier data comparison
complaints_add<-cbind(complaints_add, lonlat_output)

#geocoding error: how to solve the problem of "failed with error...not uniquely geocoded"
#majority of failed addresses have "#xxx" inserted (house number)
#ex: 20 Jones St #200 San Francisco CA 94102
#ex: 5689 E. Kings Canyon Rd, #101, Fresno CA 93727

#identify cases with "#" included in Respondent.Address
detect<-grepl("#",complaints_add$Respondent.Address)
complaints_add<-cbind(complaints_add,detect) #note that addresses with "#" failed in geocoding
write.csv(complaints_add,"C:/Users/Soohyun Hwangbo/Dropbox/0 Kinga and Sanaz/Discrimination_Project/Code/Georeferencing/complaints_lonlat_merged.csv",row.names = FALSE)


#####skip the geocoding part to call the saved file right away
complaints_add<-read.csv("C:/Users/Soohyun Hwangbo/Dropbox/0 Kinga and Sanaz/Discrimination_Project/Code/Georeferencing/complaints_lonlat_merged.csv")

#how to correctly geocode if addresses have "#"?
#take out "#xx" when geocoding
#replace "#" with empty string 
complaints_add$Respondent.Address<-gsub("#","",complaints_add$Respondent.Address)

#retry geocoding for cases with detect==TRUE
complaints_sharp<-complaints_add[which(complaints_add$detect==TRUE),]
complaints_sharp<-cbind(complaints_sharp,geocode(complaints_add[which(complaints_add$detect==TRUE),"Respondent.Address"]))
complaints_sharp<-complaints_sharp[,-c(38,39)]

#save the sharp address data set as well
write.csv(complaints_sharp,"C:/Users/Soohyun Hwangbo/Dropbox/0 Kinga and Sanaz/Discrimination_Project/Code/Georeferencing/complaints_sharp_merged.csv",row.names = FALSE)
complaints_sharp<-read.csv("C:/Users/Soohyun Hwangbo/Dropbox/0 Kinga and Sanaz/Discrimination_Project/Code/Georeferencing/complaints_sharp_merged.csv")

#create a function to lookup data
VLookup<-function(this,data,key,value){
  m<-match(this,data[[key]])
  data[[value]][m]
}
#merge complaints_sharp into original data set by matching with No. column
complaints_add$lon_sharp<-VLookup(complaints_add$No.,complaints_sharp,"No.","lon")
complaints_add$lat_sharp<-VLookup(complaints_add$No.,complaints_sharp,"No.","lat")

#incorporate the lon/lat values into complete columns
complaints_add$lon<-ifelse(complaints_add$detect,complaints_add$lon_sharp,complaints_add$lon)
complaints_add$lat<-ifelse(complaints_add$detect,complaints_add$lat_sharp,complaints_add$lat)

#check if there are still NA values
#some of the addresses could not be uniquely geocoded
sum(is.na(complaints_add$lon))

#what are cases that do not have "#" AND cannot be geocoded?
na<-subset(complaints_add,complaints_add$detect==FALSE & is.na(complaints_add$lon)==TRUE,)

#manually key in longitude/latitude for complaints with address typos or incorrect info
complaints_add[which(complaints_add$No.==1539),"lon"]<--121.8086
complaints_add[which(complaints_add$No.==1539),"lat"]<-39.728213

complaints_add[which(complaints_add$No.==4731),"lon"]<--121.3123
complaints_add[which(complaints_add$No.==4731),"lat"]<-37.97741	

complaints_add[which(complaints_add$No.==7401),"lon"]<--118.918139
complaints_add[which(complaints_add$No.==7401),"lat"]<-35.354307

complaints_add[which(complaints_add$No.==10016),"lon"]<--120.368436
complaints_add[which(complaints_add$No.==10016),"lat"]<-36.135092
  

#checking if all addresses are IN california
#read California state shape file
#read shp into sf object
cali<-st_read("C:/Users/Soohyun Hwangbo/Desktop/ca-state-boundary/CA_State_TIGER2016.shp")
cali<-st_transform(cali,crs = 4326)

#convert complaints data set into sf object
address_sf <- st_as_sf(complaints_add, coords = c("lon","lat"), crs = 4326)

#match both data sets to filter for points that are within CA state geometry
#if not matched, returns NA values
CA_check<-st_join(address_sf,cali,join = st_intersects)

#subset rows which are not within California
non_CA<-subset(CA_check,is.na(CA_check$ALAND))
write.csv(non_CA,file="C:/Users/Soohyun Hwangbo/Dropbox/0 Kinga and Sanaz/Discrimination_Project/Code/Georeferencing/non_Cali.csv")

#summarize the information into one column that shows whether a point is in CA or not?
#create a boolean variable that checks if an address is in California
complaints_add$address_CA<-!is.na(CA_check$AWATER)


#combine info in non_CA_updated with the main address data
nonCA_update<-read.csv("non_CA_updated.csv")

#if address_CA is FALSE, 
#match new addresses by Respondent name
nonCA_update$address_new<-as.character(nonCA_update$address_new)

#for i in 

#create column for ZIP code
#get the last element of the address string?
#get ZIP code of addresses by overlaying the geographic shapefile
zipcode_geo<-st_read("C:/Users/Soohyun Hwangbo/Desktop/ca_zip/ZCTA2010.shp")
zipcode_geo<-st_transform(zipcode_geo,crs = 4326)

#match addresses to corresponding zip code areas
zipcode_check<-st_join(address_sf,zipcode_geo,join = st_within)

#add ZIP code column to the complaints dataset
#note that this only merges CA zip codes (non-CA zip codes marked as NA values)
complaints_add$ZIP_code<-zipcode_check$ZCTA

#######################
####map visualization: county level####

#1) overlay a sample of points on California county boundaries
#load California county shape file
cali_county<-st_read("C:/Users/Soohyun Hwangbo/Desktop/ca-county-boundaries/CA_Counties_TIGER2016.shp")
cali_county<-st_transform(cali_county,crs = 4326)

#take a random sample of points
sample<-address_sf[sample.int(nrow(address_sf),100),]

#plot the points on the county map
theme_set(theme_bw())
ggplot()+geom_sf(data = cali_county)+geom_sf(data = sample)

#4 out of 100 are non-CA points
#zoom in for viewing
ggplot()+geom_sf(data = cali_county)+geom_sf(data = sample)+coord_sf(xlim=c(-125,-112))+
  labs(title = "Discrimination Claims in California")+theme_bw()


#2) create a map with colors for no. of cases by county (higher cases = darker)
#need a dataframe that counts no. of claims by county
#tag the main data set with FIPS code for county & sum them?

#st_join() matches corresponding counties for each address data using lon/lat
county_check<-st_join(address_sf, cali_county, join = st_intersects)

poly.counts(address_sf,cali_county)

plot(st_geometry(cali_county))

#count no. of cases per county
case_county_count<-count(as_tibble(county_check),GEOID,NAMELSAD) %>% 
  View()

#visualize cases per county
#using tmap
library(tmap)
tmap_mode("view")
tm_shape(county_case)+tm_fill(col = "n", palette = "Reds", style = "cont",
                                    contrast = c(0.1,1),
                                    title = "Cases per County", showNA = FALSE,
                                    id = "GEOID") + tm_borders(col = "darkgray", lwd = 0.7)+
  tm_view(basemaps = "Stamen.TonerLite")

#using ggplot
#note that default gradient in ggplot is lighter color for higher numbers
ggplot()+geom_sf(data = county_case, aes(fill = n))+scale_fill_gradient(trans = "reverse", name = "No. of cases")+scale_y_continuous(breaks = 20:30)+
  labs(title = "No. of cases by county in California")


#create a FIPS variable that tags the FIPS code of each complaint address (identifier!)
complaints_add$FIPS<-county_check$GEOID


###################
###map visualization: census tract level###
#overlay points on census tract level
cali_ctract<-st_read("C:/Users/Soohyun Hwangbo/Desktop/cali-census-tracts-SHP/california-us-census-tracts.shp")
cali_ctract<-st_transform(cali_ctract,crs = 4326)

#plot the points on the census tract map
ggplot()+geom_sf(data = cali_ctract) + geom_sf(data = sample) + coord_sf(xlim=c(-125,-112))+
  labs(title = "Discrimination Claims in California")

#match corresponding census tracts for each address
ctract_check<-st_join(address_sf, cali_ctract, join = st_within)

#count no. of cases per census tract
case_tract_count<-count(as_tibble(ctract_check),GEOID10,NAMELSAD10)

#merge the no. count column with the census tract list data set
ctract_case<-left_join(cali_ctract,case_tract_count,by="GEOID10")
ctract_case<-ctract_case[,-c(14)]
colnames(ctract_case)[colnames(ctract_case)=="NAMELSAD10.x"]<-"NAMELSAD10"

#visualize cases per census tract
#using interactive tmap
library(tmap)
tmap_mode("view")
ctract_map<-tm_shape(ctract_case)+tm_fill(col = "n", palette = "Reds", style = "cont", contrast = c(0.1,1),
                                          title = "Cases per Census Tract", showNA = FALSE, 
                                          id = "NAMELSAD10") + tm_borders(col = "darkgray", lwd = 0.7)+tm_view(basemaps = "Stamen.TonerLite")

#variable for cases per capita
ctract_case$case_percapita


#################
#merging SES variables by complaint address census tract
#bind by census tract ID?
#add census tract ID column in complaints data
complaints_add$census_FIPS<-ctract_check$GEOID10
complaints_add$census_FIPS<-as.numeric(as.character(complaints_add$census_FIPS))

census_var$census_FIPS<-as.numeric(as.character(census_var$census_FIPS))

#merge SES variables by census tract ID
complaints_add<-left_join(complaints_add,census_var,by = "census_FIPS")
complaints_add<-complaints_add[,-c(43)]

#save the final merged complaints file with ZIP, census tract FIPS, SES variables!!
write.csv(complaints_add, file = "C:/Users/Soohyun Hwangbo/Dropbox/0 Kinga and Sanaz/Discrimination_Project/Data/Clean_Data/Complaints/complaints_SESvar_merged.csv",row.names = FALSE)
