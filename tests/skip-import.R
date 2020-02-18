# To run certain functions we need an internet connection.
# pref a fast one

# rough!
library(httr)
r <- GET("localhost:27017")

skip_import = function() {
  if(r$status_code != "200" |
     !curl::has_internet() |
     !identical(Sys.getenv("GEOCODER_MONGODB_AVAILABLE"), "true"))
    skip("No connection or mongodb to run tests")
}



