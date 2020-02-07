
<!-- [![Travis build status](https://travis-ci.org/layik/geocoder.svg?branch=master)](https://travis-ci.org/layik/geocoder) -->

<!-- [![codecov](https://codecov.io/gh/layik/geocoder/branch/master/graph/badge.svg)](https://codecov.io/gh/layik/geocoder) -->

<!-- README.md is generated from README.Rmd. Please edit that file -->

# roadmap
 * import UK MSOA as example and make queries to return boundaries
 * write functions to carryout above
 * generalise even further to import other countries or LSOAs etc
 
# geocoder

Use the power of MongoDB to make spatial queries, find boundaries and
more for data analaysis from R.

# Dependencies

  - mongolite

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
test = mongo(url = "mongodb://localhost:27017")
class(test)
#> [1] "mongo"       "jeroen"      "environment"
```

Lets add real data

``` r
# geojson file from Uberr
v.url = "https://github.com/uber-common/deck.gl-data/raw/master/examples/geojson/vancouver-blocks.json"
v.path = "/tmp/vancouver.json"
download.file(v.url, v.path)
v = jsonlite::read_json(v.path)
length(v$features)
#> [1] 4627

# the structure is as follows
# names(v)
# [1] "type"     "name"     "crs"      "features"
# names(v$features[[1]])
# [1] "type"       "properties" "geometry"
# names(v$features[[1]][['geometry']])
# [1] "type"        "coordinates"
# those two are the only two fields we need according ot MongoDB docs
# https://docs.mongodb.com/manual/reference/geojson/

# create a collection in your MongoDB instancee
vancouver = mongo("vancouver")
# clear it if has been run before
vancouver$drop()
```

Quietly populate the collection

``` r

# care is needed to create the mongodb expected geojson objects
lapply(v$features, function(x){
  #' assemble a coordinates list from current read_json
  #' like [[[lon,lat], [lon, lat]]]
  #' so we can mongolite::insert it to the coordinates field of a page
  #' within the location collection
  m = matrix(unlist(x[['geometry']][[2]]), ncol = 2, byrow = T)
  l = list(list()) # geojson coordinates [[]]
  for (i in 1:nrow(m)) {
    l[[1]][[i]] = m[i,] # add it to the first/top dim. of the list
  }
  vancouver$insert(list(
    properties = x[['properties']],
    geometry = list(
      type = x[['geometry']][['type']],
      coordinates = l
    )
  ))
})
```

Now lets query the collection

``` r
vancouver$find('{}', limit = 1)
#>   properties.valuePerSqm properties.growth geometry.type
#> 1                   4563            0.3592       Polygon
#>                                                                                                                                                             geometry.coordinates
#> 1 -123.02496, -123.02416, -123.02404, -123.02393, -123.02385, -123.02385, -123.02496, -123.02496, 49.24072, 49.24072, 49.24068, 49.24072, 49.24072, 49.24045, 49.24046, 49.24072
# now geojson type is set like ["Polygon"] and must be "Polygon"
vancouver$update('{}','{"$set":{"geometry.type": "Polygon"}}', multiple = TRUE)
#> List of 3
#>  $ modifiedCount: int 4627
#>  $ matchedCount : int 4627
#>  $ upsertedCount: int 0
# try now
vancouver$find('{}', limit = 1)
#>   properties.valuePerSqm properties.growth geometry.type
#> 1                   4563            0.3592       Polygon
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

# Related work

Considered Mapit project, it is great for people who would like to have
a web interface, for the use of this package, there is the underlying
work of an R interface to MongoDB in `mongolite` and for this use casee,
it might be better to use Mongo over PostgreSQL.
