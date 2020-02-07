#' Setup mongodb
#'
#' Set an R environment variable with database details. This is done so that
#' username and password of the database is kept away from your code base
#' deliberaltey.
#'
#' The functions checks and gives feedback on a valid URL to be used with
#' `mongolite::mongo`'s url parameter. To do this it needs:
#' * MONGODB_HOST
#' * MONGODB_PORT
#' * MONGODB_USER
#' * MONGODB_PASS
#' * (optional) MONGODB_DB
#' * (optional) MONGODB_COLL - for default connection
#'
#' @return mongolite::mongo valid URI
#'
#' @param db set database from parameter.
#' @param collection set collection from parameter.
#'
#' @export
#' @examples
#' \dontrun{
#' setup()
#' }
setup = function(db, collection) {
  host = check("MONGODB_HOST")
  user = check("MONGODB_USER")
  pass = check("MONGODB_PASS")
  # light checking
  port = Sys.getenv("MONGODB_PORT")
  # see mongodb docs for default port of 27017
  if(port == "") port = "27017"
  URI = sprintf("mongodb://%s:%s@%s:%s", user, pass, host, port)
  if(!is.null(db)) URI = file.path(URI, db)
  URI
}

#' Function to check environment variable
#' local function
#'
#' @param var env. var to check
#' @examples
#' \dontrun{
#' check("foobar")
#' }
check = function(var) {
  force(var)
  r = Sys.getenv(var)
  if(r == "") {
    stop(paste0("Env. variable '", var, "' is not set, please set it."))
  }
  r
}
