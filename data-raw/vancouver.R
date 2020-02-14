# get vancouverr geojson from Uber Eng
v = geojsonsf::geojson_sf("~/Desktop/data/vancounver.geojson")
# names(v)

# make sure you have your own instance of mongo connected
# see mongolite docs for details
# location$drop()
location = mongolite::mongo("location")
# care is needed to create the mongodb expected geojson objects
apply(v, 1, function(x){
  #' assemble a coordinates list from current read_json
  #' like [[[lon,lat], [lon, lat]]]
  #' unboxed properties
  json = geojsonsf::sf_geojson(x, atomise = TRUE )
  stopifnot(jsonify::validate_json(json))
  vancouver$insert(json)
})
location$index((add = '{"geometry" : "2dsphere"}'))

