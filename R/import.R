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
#' @export
#' @example
#' \dontrun{
#' gc_import("https://github.com/uber-common/deck.gl-data/raw/master/examples/geojson/vancouver-blocks.json", collection="vancouver")
#' }
gc_import = function(uri,
                     collection = "geocode",
                     local = TRUE,
                     index = "2dsphere") {
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
  con = mongolite::mongo(collection = collection, url = gc_setup())
  if(!inherits(con, "jeroen")) {
    # connection error?
    stop("Looks like connection is not available to import data.")
  }
  temp.file = uri # if remote we will flick next
  if(!local) {
    temp.file = file.path(tempdir(), "import.json")
    utils::download.file(uri, temp.file)
  }

  sf.df = geojsonsf::geojson_sf(temp.file)
  # care is needed to create the mongodb expected geojson objects
  by(sf.df, 1:nrow(sf.df), function(x){
    #' assemble a coordinates list from current read_json
    #' like [[[lon,lat], [lon, lat]]]
    #' unboxed properties
    json = geojsonsf::sf_geojson(x, atomise = TRUE )
    stopifnot(jsonify::validate_json(json))
    con$insert(json)
  })
  # crucial, create geoindex
  con$index((add = paste0('{"geometry" : "', index, '"}')))
  con$count('{}')
}
