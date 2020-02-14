
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

# [geocoder](https://layik.github.io/geocoder/) · [![Travis build status](https://travis-ci.org/layik/geocoder.svg?branch=master)](https://travis-ci.org/layik/geocoder) [![codecov](https://codecov.io/gh/layik/geocoder/branch/master/graph/badge.svg)](https://codecov.io/gh/layik/geocoder)

Use the power of MongoDB to make spatial queries, find boundaries and
more for data analaysis from R.

# roadmap

  - import UK MSOA as example and make queries to return boundaries
  - write functions to carryout above
  - generalise even further to import other countries or LSOAs etc

# Dependencies

  - mongolite
  - geojsonsf

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

Lets add real data

``` r
# geojson file from Uberr
v.path = file.path(tempdir(), "vancouver.json")
if(!exists(v.path)) {
  v.url = "https://github.com/uber-common/deck.gl-data/raw/master/examples/geojson/vancouver-blocks.json"
  download.file(v.url, v.path)
}
v = geojsonsf::geojson_sf(v.path)
nrow(v)
#> [1] 4627
class(v)
#> [1] "sf"         "data.frame"

# create a collection in your MongoDB instancee
vancouver = mongo("vancouver")
# clear it if has been run before
vancouver$drop()
```

Quietly populate the collection

``` r

# care is needed to create the mongodb expected geojson objects
by(v, 1:nrow(v), function(x){
  #' geojsonsf package handles Mongo compliant objects in the shape of
  #' {geometry: {type: "Point", coordinates: [0,1]}} and other GeoJSON valid
  #' coordinates and type matching.
  #' unboxed properties
  json = geojsonsf::sf_geojson(x, atomise = TRUE )
  stopifnot(jsonify::validate_json(json))
  vancouver$insert(json)
})
```

Now lets query the collection

``` r
vancouver$find('{}', limit = 1)
#>      type properties.valuePerSqm properties.growth geometry.type
#> 1 Feature                   4563            0.3592       Polygon
#>                                                                                                                                                             geometry.coordinates
#> 1 -123.02496, -123.02416, -123.02404, -123.02393, -123.02385, -123.02385, -123.02496, -123.02496, 49.24072, 49.24072, 49.24068, 49.24072, 49.24072, 49.24045, 49.24046, 49.24072
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
      "maxDistance" : 100,
      "spherical" : true
    }
  }
] '
r = vancouver$aggregate(pipeline = qry)
nrow(r)
#> [1] 1
# changing the maxDistance will increase the number returned
qry = gsub(x = qry, pattern = "100", replacement = "500")
r = vancouver$aggregate(pipeline = qry)
nrow(r)
#> [1] 32
```

# public

package no longer private as there is a working function to use.

# Related work

Considered Mapit project, it is great for people who would like to have
a web interface, for the use of this package, there is the underlying
work of an R interface to MongoDB in `mongolite` and for this use casee,
it might be better to use Mongo over PostgreSQL.
