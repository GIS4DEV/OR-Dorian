# Metadata
Organize and store documentation and metadata in this folder.

Metadata files should be listed for relevant data sources in [data/data_metadata.csv](../data_metadata.csv)

# Twitter Data in dorian.Rdata

This data was acquried with the `rtweet` package and `search tweets` Twitter API with two searches.

The `dorian` data frame contains tweets for hurricane Dorian, searched on September 11, 2019 with the following code:
```r
dorian <- search_tweets("dorian OR hurricane OR sharpiegate", n=200000, include_rts=FALSE, token=twitter_token, geocode="32,-78,1000mi", retryonratelimit=TRUE)
```

The `november` data frame contains tweets without any text filter for the same geographic region, searched on November 19, 2019 with the following code:
```r
november <- search_tweets("-filter:verified OR filter:verified", n=200000, include_rts=FALSE, token=twitter_token, geocode="32,-78,1000mi", retryonratelimit=TRUE)
```

Note that the code requries a valid `twitter_token` object in order to run correctly, and the `search_tweets` function cannot conduct a historical search. If you need to reproduce these results, you will need historic access to archived twitter data, and some tweets may have been edited or removed since the search was conducted.

Following the search, the data was also filtered for more precise geographic locations and converted into point features with the following code.

```r
#convert GPS coordinates into lat and lng columns
dorian <- lat_lng(dorian,coords=c("coords_coords"))
november <- lat_lng(november,coords=c("coords_coords"))

#select any tweets with lat and lng columns (from GPS) or designated place types of your choosing
dorian <- subset(dorian, place_type == 'city'| place_type == 'neighborhood'| place_type == 'poi' | !is.na(lat))
november <- subset(november, place_type == 'city'| place_type == 'neighborhood'| place_type == 'poi' | !is.na(lat))

#convert bounding boxes into centroids for lat and lng columns
dorian <- lat_lng(dorian,coords=c("bbox_coords"))
november <- lat_lng(november,coords=c("bbox_coords"))
```

See the code in `01-search_dorain.r` for details.