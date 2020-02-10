#' Import geocode
#'
#' For now, support geojson file as that is what mongolite package tries to support.
#' Shape and others later which would also mean, keeping the package deps minimal.
#' For details see data-raw example of this package how geojson objects are imported.
#'
#' @return number of rows inserted
#'
#' @param uri file to read or remote, flick `local` param
#' @param collection set collection from parameter.
#' @param local assume `uri` being local
#' @param index a MongoDB compatible index: either 2d or 2dsphere
#'
#' #examples
#' # dontrun{
#' # import("https://github.com/uber-common/deck.gl-data/raw/master/examples/geojson/vancouver-blocks.json", collection="vancouver")
#' # }
#' @export
import = function(uri, collection = "geocode", local = TRUE, index = "2dsphere") {
  force(url)
  if(!any(grepl(pattern = index, c("2d", "2dsphere")))) {
    stop("Index must be Mongodb compliant")
  }
  if(local) {
    if(!file.exists(uri)) {
      stop("URI does not exist.")
    }
  }
  # check connection before proceding
  con = mongolite::mongo(collection = collection, url = setup())
  if(!inherits(con, "jeroen")) {
    # connection error?
    stop("Looks like connection is not available to import data.")
  }
  temp.file = uri # if remote we will flick next
  if(!local) {
    temp.file = file.path(tempdir(), "import.json")
    utils::download.file(uri, temp.file)
  }

  json = jsonlite::read_json(temp.file)
  # if all is good and there is a "json$features" we can proceed

  lapply(json$features, function(x){
    #' assemble a coordinates list from current read_json
    #' like [[[lon,lat], [lon, lat]]]
    #' so we can mongolite::insert it to the coordinates field of a page
    #' within the location collection
    m = matrix(unlist(x[['geometry']][[2]]), ncol = 2, byrow = T)
    l = list(list()) # geojson coordinates [[]]
    for (i in 1:nrow(m)) {
      l[[1]][[i]] = m[i,] # add it to the first/top dim. of the list
    }
    con$insert(list(
      properties = x[['properties']],
      geometry = list(
        type = x[['geometry']][['type']],
        coordinates = l
      )
    ))
  })
  # now geojson type is set like ["Polygon"] and must be "Polygon"
  con$update('{}','{"$set":{"geometry.type": "Polygon"}}', multiple = TRUE)
  # crucial, create geoindex
  con$index((add = paste0('{"geometry" : "', index, '"}')))
  con$count('{}')
}
