# To run certain functions we need an internet connection.
# pref a fast one
skip_import = function() {
  if(!curl::has_internet() |
     !identical(Sys.getenv("GEOCODER_MONGODB_AVAILABLE"), "true"))
    skip("No connection or mongodb to run tests")
}
