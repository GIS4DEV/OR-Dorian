# analyze twitter data, by Joseph Holler, 2019
#following tutorial at https://www.earthdatascience.org/courses/earth-analytics/get-data-using-apis/use-twitter-api-r/
#also get advice from the rtweet page: https://rtweet.info/
#to do anything, you first need a twitter API token: https://rtweet.info/articles/auth.html 

#install packages for twitter, census, data management, and mapping
packages = c("rtweet","tidycensus","tidytext","maps","RPostgres","igraph","tm", "ggplot2","RColorBrewer","rccmisc","ggraph","here")
setdiff(packages, rownames(installed.packages()))
install.packages(setdiff(packages, rownames(installed.packages())), quietly=TRUE)

#initialize the libraries. this must be done each time you load the project
library(rtweet)
library(igraph)
library(dplyr)
library(tidytext)
library(tm)
library(tidyr)
library(ggraph)
library(tidycensus)
library(ggplot2)
library(RPostgres)
library(RColorBrewer)
library(DBI)
library(rccmisc)
library(here)

############# TEMPORAL ANALYSIS ############# 

#this is here as an example. change to the dorian3 data you processed in the previous script to try...

#create temporal data frame & graph it

dorian <- ts_data(dorian, by="hours")
ts_plot(dorian, by="hours")

############# NETWORK ANALYSIS ############# 

#this is here as an example. change to the dorian3 data you processed in the previous script to try...

#create network data frame. Other options for 'edges' in the network include mention, retweet, and reply
dorianNetwork <- network_graph(dorian, c("quote"))

plot.igraph(winterTweetNetwork)
#Please, this is incredibly ugly... if you finish early return to this function and see if we can modify its parameters to improve aesthetics

############# TEXT / CONTEXTUAL ANALYSIS ############# 

#remove urls, fancy formatting, etc. in other words, clean the text content
dorianText = dorian %>% select(text) %>% plain_tweets()

#parse out words from tweet text
dorianWords = dorianText %>% unnest_tokens(word, text)

# how many words do you have including the stop words?
count(dorianWords)

#create list of stop words (useless words) and add "t.co" twitter links to the list
data("stop_words")
stop_words = stop_words %>% add_row(word="t.co",lexicon = "SMART")

#delete stop words from dorianWords with an anti_join
dorianWords =  dorianWords %>% anti_join(stop_words) 

# how many words after removing the stop words?
count(dorianWords)

# graph frequencies of words
dorianWords %>%
  count(word, sort = TRUE) %>%
  top_n(15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() +
  labs(x = "Count",
       y = "Unique words",
       title = "Count of unique words found in tweets")

dorianWordPairs = dorianText %>% 
  mutate(text = removeWords(text, stop_words$word)) %>%
  unnest_tokens(paired_words, text, token = "ngrams", n = 2)

dorianWordPairs = separate(dorianWordPairs, paired_words, c("word1", "word2"),sep=" ")
dorianWordPairs = dorianWordPairs %>% count(word1, word2, sort=TRUE)

# graph a word cloud with space indicating association.
# you may change the filter to filter more or less than pairs with 30 instances
dorianWordPairs %>%
  filter(n >= 30) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  # geom_edge_link(aes(edge_alpha = n, edge_width = n)) +
  geom_node_point(color = "darkslategray4", size = 3) +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3) +
  labs(title = "Word Network of Tweets during Hurricane Dorian",
       x = "", y = "") +
  theme_void()

############# SPATIAL ANALYSIS ############# 

#first, sign up for a Census API here: https://api.census.gov/data/key_signup.html
#replace the key text 'yourkey' with your own key!
counties <- get_estimates("county",product="population",output="wide",geometry=TRUE,keep_geo_vars=TRUE, key="1fb2d48d1ae3f73a19d620f258ec9f823ad09b25")

#select only the states you want, with FIPS state codes in quotes in the c() list
#look up fips codes here: https://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code 
counties = filter(counties,STATEFP %in% c('54', '51', '50', '47', '45', '44', '42', '39', '37','36', '34', '33', '29', '28', '25', '24', '23', '22', '21', '18', '17','13', '12', '11', '10', '09', '05', '01') )

#map results with GGPlot
#note: cut_interval is an equal interval classification function, while cut_numer is a quantile / equal count function
#you can change the colors, titles, and transparency of points
ggplot() +
  geom_sf(data=counties, aes(fill=cut_number(DENSITY,5)), color="grey")+
  scale_fill_brewer(palette="GnBu")+
  guides(fill=guide_legend(title="Population Density"))+
  geom_point(data = dorian, aes(x=lng,y=lat),
             colour = 'purple', alpha = .5) +
  labs(title = "Tweet Locations During Hurricane Dorian")+
  theme(plot.title=element_text(hjust=0.5),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())


############### UPLOAD RESULTS TO POSTGIS DATABASE ###############

#Connectign to Postgres
#Create a con database connection with the dbConnect function.
#Change the user and password to your own!
con <- dbConnect(RPostgres::Postgres(), dbname='dsm', host='artemis', user='user', password='password') 

#list the database tables, to check if the database is working
dbListTables(con) 

#create a simple table for uploading
doriansql <- select(dorian,c("user_id","status_id","text","lat","lng"),starts_with("place"))

#write data to the database
dbWriteTable(con,'dorian',doriansql, overwrite=TRUE)

# try also writing the november tweet data to the database! Add code below:

# SQL to add geometry column of type point and crs NAD 1983: 
# SELECT AddGeometryColumn ('schemaname','dorian','geom',4269,'POINT',2, false);
# SQL to calculate geometry:
# UPDATE dorian set geom = st_transform(st_makepoint(lng,lat),4326,4269);

#make all lower-case names for counties, because PostGreSQL is not into capitalization

dbWriteTable(con,'counties',lownames(counties), overwrite=TRUE)

#disconnect from the database
dbDisconnect(con)

############### SPATIAL JOIN AND MAPPING NORMALIZED TWEETS ###############

# Either in R or in PostGIS (via QGIS DB Manager)...

# Count the number of dorian points in each county
# Count the number of november points in each county
# Set counties with no points to 0 for the november count
# Calculate the normalized difference tweet index (made this up, based on NDVI), where
# ndti = (tweets about storm – baseline twitter activity) / (tweets about storm + baseline twitter activity)
# remember to multiply something by 1.0 so that you'll get decimal devision, not integer division
# also if the denominator would end up being 0, set the result to 0

# Either in QGIS or in R...
# Map the normalized tweet difference index for Hurricane Dorian
# Try using the heatmap symbology in QGIS to visualize kernel density of tweets

############### CREATE YOUR OWN TWITTER QUERY ###############

# Before next Lab, make a copy of the 01-search-dorian.r script and modify it to query your own set of data from Twitter and prepare it for mapping just as we have done here!
# Remember that you may have to let the query run for a few hours if there are a high number of results.