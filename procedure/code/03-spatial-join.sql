/* This SQL script serves as a guide to spatially joining tweets to counties 
 - Joseph Holler, 2021 */
 
/*
############### SPATIAL JOIN AND MAPPING NORMALIZED TWEETS ###############

# Either in R or in PostGIS (via QGIS DB Manager)...

# Count the number of dorian points in each county
# Count the number of november points in each county
# Set counties with no points to 0 for the november count
# Calculate the normalized difference tweet index (made this up, based on NDVI), 
# where ndti = (tweets about storm – baseline twitter activity) / 
#              (tweets about storm + baseline twitter activity)
# remember to multiply something by 1.0 so that you'll get decimal division
# also if the denominator would end up being 0, set the result to 0

# See 03-spatial-join.sql for tips on managing the data in PostGIS

# Either in QGIS or in R...
# Map the normalized tweet difference index for Hurricane Dorian
# Try using the heatmap symbology in QGIS to visualize kernel density of tweets
*/

-- Add geometry column named 'geom' of type point and coordinate reference system NAD 1983: 
SELECT AddGeometryColumn('schemaname','dorian','geom',4269,'POINT',2, false);

-- SQL to create point geometry, set it's SRID to WGS 1984, and transform it to NAD 1983:
UPDATE dorian set geom = st_transform(st_setsrid(st_makepoint(lng,lat),4326),4269);

-- SQL to register the geometry column for counties, replacing schemaname with your schema's name
SELECT populate_geometry_columns('schemaname.dorian'::regclass)

-- Add your steps to complete the spatial join and NDTI calculation here!

