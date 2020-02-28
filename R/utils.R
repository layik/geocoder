#' Generate JSON MongoDB spatial query
#'
#' See MongoDB
#' \url{https://docs.mongodb.com/manual/reference/operator/query-geospatial/}
#' for details of spatial queries. This functions generates only:
#' `geoIntersects`, `geoWithin`, `near` or `nearSphere`.
#'
#'
#' @return JSON valid MongoDB query
#'
#' @param ... different params.
#' @param query MongoDB query type which must be
#' one of `geoIntersects`, `geoWithin`, `near` or `nearSphere`.
#' @param type geom type which must be a valid GeoJSON type
#' @param coords list of coordinates which matches `type`
#' Or just provide a valid sf with one row as both type and coords.
#'
#' @export
#' @example {
#' gc_query(query="near", type = "point", coords = c(0,1))
#' }
gc_query = function(query, type, coords, ...) {
  qtypes = c("geoIntersects", "geoWithin", "near", "nearSphere")
  geom.types = c("Point", "MultiPoint", "LineString", "MultiLineString",
                 "Polygon", "MultiPolygon", "GeometryCollection")
  if(is.null(query) || nchar(query) == 0) {
    stop("MongoDB spatial query type is required: ",
         paste(qtypes, collapse = ", "), ".")
  }
  # build geoIntersects
  if(query == "geoIntersects") {
    if(is.null(type)) {
      stop("For query '", query, "' type is required.")
    }
    if(!any(grepl(pattern = type, x = geom.types, ignore.case = TRUE))) {
      stop("Type '", type, "' must be one of: ",
           paste(geom.types, collapse = ", "), ".")
    }
    if(is.null(coords)) {
      stop("For query '", query, "' coordinates are required.")
    }
  }

  # build geoWithin
  if(query == "geoWithin") {
    geoWithinTypes = c("Polygon", "MultiPolygonPolygon")
    if(is.null(type) || !any(grepl(type, geoWithinTypes))){
      stop("Type '", type, "' must be one of: ",
           paste(geoWithinTypes, collapse = ", "), ".")
    }
    if(is.null(coords)) {
      stop("For query '", query, "' coordinates are required.")
    }
  }
  # build near or nearSphere
  input = list(...)
  maxDistance = input[["maxDistance"]]
  minDistance = input[["minDistance"]]
  if(query == "near" || query == "nearSphere") {
    if(!is.null(type) && tolower(type) != "point") {
      warning("For near query, type must be a Point. Ignoring: ", type)
    }
    if(length(coords) != 2) {
      stop("For near query, only two coordinates is needed.")
    }
    if(!is.null(maxDistance) || !is.null(minDistance)) {
      if(!is.numeric(maxDistance) || !is.numeric(minDistance)) {
        stop("For near query, max and min distance must be numeric.")
      }
    }
  }

  # generate the JSON
  r = paste0('{ "$', query, '":{ geometry": ')
  # generate the geometry
  make_json = function(sf_func) {
    g = sf::st_sfc(sf_func(coords))
    geojsonsf::sfc_geojson(g)
  }
  geom = NULL
  if(tolower(type) == "point") {
    geom = make_json(sf::st_point)
  } else {
    switch(tolower(type),
           multipoint={
             geom = make_json(sf::st_multipoint)
           },
           linestring={
             geom = make_json(sf::st_linestring)
           },
           multilinestring={
             geom = make_json(sf::st_multilinestring)
           },
           polygon={
             geom = make_json(sf::st_polygon)
           },
           multipolygon={
             geom = make_json(sf::st_multipolygon)
           },
           stop("Unknown geojson type.")
    )
  }
  r = paste0(r, geom,' } } }')
  jsonify::validate_json(r)
  r
}
