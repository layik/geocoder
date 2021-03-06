#' Import geocode
#'
#' For now, support geojson file as that is what mongolite package tries to support.
#' Shape and others later which would also mean, keeping the package deps minimal.
#' For details see data-raw example of this package how geojson objects are imported.
#'
#' @return number of rows inserted
#'
#' @param url geojson file to read or remote, flick `local` param.
#' @param collection set collection from parameter default `geocode`.
#' @param local assume `url` being local file.
#' @param index a MongoDB compatible index: either 2d or 2dsphere.
#' @param mongo_url custom mongourl to use with `collection`,
#' default value is `'mongodb://localhost:27017'` used with `gc_setup`.
#' @param silent show messages, default is `FALSE`
#'
#' @export
#' @example
#' \dontrun{
#' gc_import(paste0("https://github.com/layik/geocoder/releases/",
#' "download/data/v10.geojson"), local = FALSE)
#' }
gc_import = function(url,
                     collection = "geocoder",
                     local = TRUE,
                     index = "2dsphere",
                     mongo_url = 'mongodb://localhost:27017',
                     silent = FALSE) {
  force(url)
  if(!any(grepl(pattern = index, c("2d", "2dsphere")))) {
    stop("Index must be Mongodb compliant")
  }
  if(local) {
    if(!file.exists(url)) {
      stop("URL does not exist.")
    }
  }
  # TODO: check connection before proceding
  con = mongolite::mongo(collection = collection,
                         url = mongo_url)
  temp.file = url # if remote we will flick next
  if(!local) {
    temp.file = file.path(tempdir(), "import.json")
    if(!exists(temp.file)) { # avoid
      utils::download.file(url, temp.file)
    }
  }

  sf.df = geojsonsf::geojson_sf(temp.file)
  gc_write_to_mongo(sf.df, con)
  # create geoindex
  con$index((add = paste0('{"geometry" : "', index, '"}')))
  c = con$count()
  message("There are '", c, "' documents in collection: ", collection)
  c
}


#' Import `sf` objects into Mongodb
#'
#' TODO: function details
#'
#' @return number of rows inserted
#'
#' @param x geojson file to read or remote, flick `local` param.
#' @param collection set collection from parameter default `geocode`.
#' @param index a MongoDB compatible index: either 2d or 2dsphere.
#' @param mongo_url custom mongourl to use with `collection`,
#' default value is `'mongodb://localhost:27017'` used with `gc_setup`.
#' @param silent show messages, default is `FALSE`
#'
#' @export
#' @example
#' \dontrun{
#' x = geojsonsf::geojson_sf(
#' paste0("https://github.com/layik/geocoder/releases/",
#' "download/data/v10.geojson")
#' gc_import_sf(x)
#' }
gc_import_sf = function(x,
                        collection = "geocoder",
                        index = "2dsphere",
                        mongo_url = 'mongodb://localhost:27017',
                        silent = FALSE) {
  # TODO: check connection before proceding
  con = mongolite::mongo(collection = collection,
                         url = mongo_url)
  gc_write_to_mongo(x, con)
  # create geoindex
  con$index((add = paste0('{"geometry" : "', index, '"}')))
  c = con$count()
  message("There are '", c, "' documents in collection: ", collection)
  c
}

#' Internal write helper function
#'
#' @param sf.df dataframe to iterate and write to `con`
#' @param con a mongodb connetion initialized with `mongolite::mongo`
#'
gc_write_to_mongo = function(sf.df, con) {
  message("Writing '", nrow(sf.df), "' documents...")
  # care is needed to create the mongodb expected geojson objects
  by(sf.df, 1:nrow(sf.df), function(x){
    #' assemble a coordinates list from current read_json
    #' like `[[[lon,lat], [lon, lat]]]`
    #' unboxed properties
    json = geojsonsf::sf_geojson(x, atomise = TRUE )
    stopifnot(jsonify::validate_json(json))
    con$insert(json)
  })
}
