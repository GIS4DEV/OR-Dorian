#search geographic twitter data for Hurricane Dorian, by Joseph Holler, 2019,2020
#to search, you first need a twitter API token: https://rtweet.info/articles/auth.html 

#this script contains the code that was used to create the dorian and november data frames in dorian.Rdata. 
#note that this code will no longer work as originally run, because the code is time-sensitive.
#for students in GG323, read the code for how the data was searched, and then run the final block
#of code to download and load the resutls in Rdata format.

#install package for twitter and initialize the library
packages = c("rtweet","here")
setdiff(packages, rownames(installed.packages()))
install.packages(setdiff(packages, rownames(installed.packages())), quietly=TRUE)

library(rtweet)
library(here)

############# SEARCH TWITTER API ############# 

#reference for search_tweets function: https://rtweet.info/reference/search_tweets.html 
#don't add any spaces in between variable name and value. i.e. n=1000 is better than n = 1000
#the first parameter in quotes is the search string, searching tweet contents and hashtags
#n=10000 asks for 10,000 tweets
#if you want more than 18,000 tweets, change retryonratelimit to TRUE and wait 15 minutes for every batch of 18,000
#include_rts=FALSE excludes retweets.
#token refers to the twitter token you defined above for access to your twitter developer account
#geocode is equal to a string with three parts: longitude, latidude, and distance with the units mi for miles or km for kilometers

#set up twitter API information
#this should launch a web browser and ask you to log in to twitter
#replace app, consumer_key, and consumer_secret data with your own developer acct info
twitter_token <- create_token(
  app = "yourapp",  					#replace yourapp with your app name
  consumer_key = "yourkey",  		#replace yourkey with your consumer key
  consumer_secret = "yoursecret",  #replace yoursecret with your consumer secret
  access_token = NULL,
  access_secret = NULL
)

#get tweets for hurricane Dorian, searched on September 11, 2019
dorian <- search_tweets("dorian OR hurricane OR sharpiegate", n=200000, include_rts=FALSE, token=twitter_token, geocode="32,-78,1000mi", retryonratelimit=TRUE)


#get tweets without any text filter for the same geographic region in November, searched on November 19, 2019
#the query searches for all verified or unverified tweets, so essentially everything
november <- search_tweets("-filter:verified OR filter:verified", n=200000, include_rts=FALSE, token=twitter_token, geocode="32,-78,1000mi", retryonratelimit=TRUE)


############# LOAD THESE RESULTS - GEOG323 STUDENTS ONLY ############# 

# Please download the file from here: https://github.com/GIS4DEV/literature/raw/master/dorian/dorian.RData
# into the data\derived\private folder
# then run the following line of code to load the data into your environment

load(here("data","derived","private","dorian.RData"))

# In the following code, you can practice running the queries on dorian3

############# FIND ONLY PRECISE GEOGRAPHIES ############# 

#reference for lat_lng function: https://rtweet.info/reference/lat_lng.html
#adds a lat and long field to the data frame, picked out of the fields you indicate in the c() list
#sample function: lat_lng(x, coords = c("coords_coords", "bbox_coords"))

# list unique/distinct place types to check if you got them all
unique(dorian$place_type)

# list and count unique place types
# NA results included based on profile locations, not geotagging / geocoding. If you have these, it indicates that you exhausted the more precise tweets in your search parameters
count(dorian, place_type)

#convert GPS coordinates into lat and lng columns
#do not use geo_coords! Lat/Lng will come out inverted
dorian <- lat_lng(dorian,coords=c("coords_coords"))
november <- lat_lng(november,coords=c("coords_coords"))

#select any tweets with lat and lng columns (from GPS) or designated place types of your choosing
dorian <- subset(dorian, place_type == 'city'| place_type == 'neighborhood'| place_type == 'poi' | !is.na(lat))
november <- subset(november, place_type == 'city'| place_type == 'neighborhood'| place_type == 'poi' | !is.na(lat))

#convert bounding boxes into centroids for lat and lng columns
dorian <- lat_lng(dorian,coords=c("bbox_coords"))
november <- lat_lng(november,coords=c("bbox_coords"))


