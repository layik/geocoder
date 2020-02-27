#' Generate JSON MongoDB spatial query
#'
#' See
#' https://docs.mongodb.com/manual/reference/operator/query-geospatial/
#'
#' @return JSON valid MongoDB query
#'
#' @param ... different params. Requires query type which must be
#' one of `geoIntersects`, `geoWithin`, `near` or `nearSphere`.
#'
#' @export
#' @example
#' \dontrun{
#' gc_query(query="near", type = "point", coordinates = sf::st_point(0,1))
#' }
gc_query = function(...) {
  qtypes = c("geoIntersects", "geoWithin", "near", "nearSphere")
  geom.types = c("Point", "MultiPoint", "LineString", "MultiLineString",
                 "Polygon", "MultiPolygon", "GeometryCollection")
  input = list(...)
  query = input[['query']]
  if(is.null(query) || nchar(query) == 0) {
    stop("MongoDB spatial query type is required: ",
         paste(qtypes, collapse = ", "), ".")
  }
  type = input[["type"]]
  coords = input[["coordinates"]]
  # build geoIntersects
  if(query == "geoIntersects") {
    if(is.null(type) || grepl(pattern = type, x = geom.types)) {
      stop("For query '", query, "' type is required.")
    }
    if(is.null(coords)) {
      stop("For query '", query, "' coordinates are required.")
    }
  }

  # build geoWithin

  # build near

  # build nearSphere
}
