#' Find geocode(s)
#'
#' The main function to find geocodes, using standard MongoDB queries,
#' with focus on particularly on returing "geometry" documents'
#' coordinates as useful objects (thinking about sfcs for instance).
#'
#' @return coordinate geospatial R objects
#'
#' @param x keys and values to return geometries with
#' @param collection set collection from parameter default `geocode`.
#' @param full_url ability to use gc_find on any mongodb
#' @param as_sf return the results as an sf object.
#'
#' @export
#' @example
#' \dontrun{
#' gc_find("key")
#' }
gc_find = function(x,
        collection = 'geocode',
        full_url,
        as_sf = TRUE ) {
  force(x)
  con = mongolite::mongo(collection = collection)
  if(!missing(full_url)) {
    con = mongolite::mongo(url = full_url,
                           collection = collection)
  }
  json = jsonify::to_json(x)
  if(substr(json, 1, 1) == "[" &&
     substr(json, nchar(json), nchar(json)) == "]") {
    json = substring(json, 2, nchar(json) - 1)
  }
  con$find(query = json)
}
