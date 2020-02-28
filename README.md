
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

# [geocoder](https://layik.github.io/geocoder/) · [![Travis build status](https://travis-ci.org/layik/geocoder.svg?branch=master)](https://travis-ci.org/layik/geocoder) [![codecov](https://codecov.io/gh/layik/geocoder/branch/master/graph/badge.svg)](https://codecov.io/gh/layik/geocoder) [![Project Status: WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

Use the power of MongoDB to make spatial queries, find boundaries and
more for data analaysis from R.

# roadmap

  - list of UK geocodes (most used)
  - list of another country’s?
  - enable generating MongoDB spatial queries

# Dependencies

  - `mongolite` (main dependency)
  - `geojsonsf` (perfect package for link between `sf` and Mongo
    spatial)
  - `jsonify` (helping with validation)
  - `sf`

# Import vancouver geojson data

Given a local docker instance of MongoDb

``` bash
# on Linux
docker pull mongo
docker run -d -p 27017:27017 --name mongodb mongo
# docker should be running at 27017
```

``` r
library(mongolite)
library(sf)
#> Linking to GEOS 3.7.2, GDAL 2.4.2, PROJ 5.2.0
test = mongo(url = "mongodb://localhost:27017")
class(test)
#> [1] "mongo"       "jeroen"      "environment"
```

Lets add real data (a small slice of [Uber’s
Vancouver](https://github.com/uber-common/deck.gl-data/raw/master/examples/geojson/vancouver-blocks.json)
dataset.)

``` r
# geojson file from Uberr
v.path = file.path(tempdir(), "vancouver.json")
if(!exists(v.path)) {
  v.url = paste0("https://github.com/layik/geocoder/releases/",
                 "download/data/v10.geojson")
  download.file(v.url, v.path)
}
v = geojsonsf::geojson_sf(v.path)
nrow(v)
#> [1] 10
class(v)
#> [1] "sf"         "data.frame"

# create a collection in your MongoDB instancee
vancouver = mongo("vancouver")
# clear it if has been run before
vancouver$drop()
vancouver$count()
#> [1] 0
```

Quietly populate the collection

``` r
library(geocoder)
gc_import_sf(v, collection = "vancounver")
#> Writing '10' documents...
#> There are '60' documents in collection: vancounver
```

Now lets query the collection

``` r
vancouver$find('{}', limit = 1)
#> data frame with 0 columns and 0 rows
vancouver$index((add = '{"geometry" : "2dsphere"}'))
#>   v key._id key.geometry              name             ns
#> 1 2       1         <NA>              _id_ test.vancouver
#> 2 2      NA     2dsphere geometry_2dsphere test.vancouver
#>   2dsphereIndexVersion
#> 1                   NA
#> 2                    3

# define a querry as mongolite does not accept somee queries
# a little cheating with copy and paste of one lon lat from the polygons in the data
qry <- '[
  {
    "$geoNear" : { 
      "near" : { "type" : "Point", "coordinates" : [ -123.1107886, 49.2718859 ] },
      "distanceField" : "dist.calculated",
      "maxDistance" : 3000,
      "spherical" : true
    }
  }
] '
r = vancouver$aggregate(pipeline = qry)
nrow(r)
#> [1] 0
# changing the maxDistance will increase the number returned
qry = gsub(x = qry, pattern = "3000", replacement = "6000")
r = vancouver$aggregate(pipeline = qry)
nrow(r)
#> [1] 0
```

# development

To run all the tests, you will require mongo to run. Once you are sure
that you have an instance (for example a container running as outliend
above), you will need a flag in your R environment
`GEOCODER_MONGODB_AVAILABLE=true`. You can use R package
`usethis::edit_r_environ()`.

But the steps should be straightforward for an R developer:

  - clone the repo

  - from RStudio (cmd/ctrl + T)

  - OR from R console:
    
      - just run `testthat::test_dir("pathToRepo/tests/testthat")`

<!-- end list -->

``` r
library("geocoder")
testthat::test_dir("tests/testthat")
#> ✓ |  OK F W S | Context
#> 
⠏ |   0       | gc-find
⠋ |   1       | gc-find
✓ |   4       | gc-find [1.4 s]
#> 
⠏ |   0       | gc-import
⠼ |   5       | gc-import
✓ |   6       | gc-import [1.2 s]
#> 
⠏ |   0       | gc-import-sf
✓ |   1       | gc-import-sf
#> 
⠏ |   0       | gc-setup
⠼ |   5       | gc-setup
✓ |   6       | gc-setup [0.7 s]
#> 
⠏ |   0       | gc-query
✓ |  23       | gc-query
#> 
#> ══ Results ═══════════════════════════════════════════════════════════════════
#> Duration: 3.7 s
#> 
#> OK:       40
#> Failed:   0
#> Warnings: 0
#> Skipped:  0
```

# Acknowledgement

This work is funded under the
[Turing](https://www.turing.ac.uk/research/research-projects/turing-geovisualization-engine)
GeoVisualization Engine project.

# Related work

Considered [Mapit](https://github.com/mysociety/mapit) project, it is
great for people who would like to have a web interface, for the use of
this package, there is the underlying work of an R interface to MongoDB
in `mongolite` and for this use casee, it might be better to use Mongo
over PostgreSQL.

The list of UK geocodes, looks like before the ONS open geography
portal, was compiled [here](https://github.com/martinjc/UK-GeoJSON).
