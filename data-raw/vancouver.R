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
  jl = jsonify::to_json(st_drop_geometry(x))
  jl = substring(text = jl, 2, nchar(jl) - 1)
  json = paste0(
    '{"properties": ', jl, ',',
    '"geometry": ', sfc_geojson(st_geometry(x)),'}'
  )
  stopifnot(jsonify::validate_json(json))
  location$insert(json)
})
location$index((add = '{"geometry" : "2dsphere"}'))

