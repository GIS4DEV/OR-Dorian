# Private Data (Raw)
Store raw data in this folder as it is collected or downloaded if the data cannot be publicly distributed - license restrictions or concerns regarding ethics, privacy, or confidentiality.

Best practices are to include instructions here for accessing any private or restricted-access data.

# Instructions for accessing data

- Download Malawi's GADM Data (version 2.8) here: https://biogeo.ucdavis.edu/data/gadm2.8/gpkg/MWI_adm_gpkg.zip from this website: https://gadm.org/download_country_v2.html 

*This folder is ignored by Git versioning* with the exception of this `readme.md` file by the following lines in `.gitignore`

```gitignore
# Ignore contents of private folder, with the exception of its readme file
private/**
!private/readme.md
```
