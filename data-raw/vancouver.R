# get vancouverr geojson from Uber Eng
v = jsonlite::read_json("~/Desktop/data/vancounver.geojson")
# names(v)
# [1] "type"     "name"     "crs"      "features"
# names(v$features[[1]])
# [1] "type"       "properties" "geometry"
# names(v$features[[1]][['geometry']])
# [1] "type"        "coordinates"
# those two are the only two fields we need according ot MongoDB docs
# https://docs.mongodb.com/manual/reference/geojson/

# make sure you have your own instance of mongo connected
# see mongolite docs for details
# location$drop()
location = mongolite::mongo("location")
lapply(v$features, function(x){
  #' assemble a coordinates list from current read_json
  #' like [[[lon,lat], [lon, lat]]]
  #' so we can mongolite::insert it to the coordinates field of a page
  #' within the location collection
  m = matrix(unlist(x[[3]][[2]]), ncol = 2, byrow = T)
  l = list(list()) # geojson coordinates [[]]
  for (i in 1:nrow(m)) {
    l[[1]][[i]] = m[i,] # add it to the first/top dim. of the list
  }
  location$insert(list(
    properties = x[[2]],
    geometry = list(
      type = x[[3]][[1]],
      coordinates = l
    )
  ))
})
location$index((add = '{"geometry" : "2dsphere"}'))
# apply(vsf[1:2,], 1, function(x) {
#   jsonlite::toJSON(matrix(unlist(x[['geometry']]), ncol = 2)[, 1:2])
# })
#
# identical(v$features[[1]][[3]], list(type=v$features[[1]][[3]][[1]], coordinates=v$features[[1]][[3]][[2]]))


