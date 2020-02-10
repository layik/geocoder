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
#'
#' @export
#' @examples {
#' host = Sys.getenv("MONGODB_HOST")
#' Sys.setenv(MONGODB_HOST="localhost")
#' setup()
#' Sys.setenv(MONGODB_HOST=host)
#' }
gc_setup = function(db) {
  host = check("MONGODB_HOST")
  # light checking
  user = Sys.getenv("MONGODB_USER")
  pass = Sys.getenv("MONGODB_PASS")
  port = Sys.getenv("MONGODB_PORT")
  # see mongodb docs for default port of 27017
  if(port == "") port = "27017"
  URI = sprintf("%s:%s", host, port)
  if(pass != "" || user != "") { # pass expects user too
    URI = sprintf("%s:%s@%s", user, pass, URI)
  } else {
    if(pass == "" && user != "") {
      URI = sprintf("%s@%s", user, URI)
    }
  }
  URI = sprintf("mongodb://%s", URI)
  if(!missing(db) && !is.null(db)) URI = file.path(URI, db)
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
