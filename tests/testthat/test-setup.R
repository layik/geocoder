reset = function(host, user, pass, port) {
  Sys.setenv(MONGODB_HOST=host)
  Sys.setenv(MONGODB_USER=user)
  Sys.setenv(MONGODB_PASS=pass)
  Sys.setenv(MONGODB_POST=port)
}
test_that("gc_setup works", {
  host = Sys.getenv("MONGODB_HOST")
  Sys.unsetenv("MONGODB_HOST")
  expect_error(gc_setup())
  expect_error(check("foo"))
  # reset
  Sys.setenv(MONGODB_HOST = host)
})

test_that("Setenv works", {
  # host = check("MONGODB_HOST")
  # user = check("MONGODB_USER")
  # pass = check("MONGODB_PASS")
  host = Sys.getenv("MONGODB_HOST")
  user = Sys.getenv("MONGODB_USER")
  pass = Sys.getenv("MONGODB_PASS")
  port = Sys.getenv("MONGODB_PORT")
  #unset
  Sys.unsetenv("MONGODB_USER")
  Sys.unsetenv("MONGODB_PASS")
  Sys.unsetenv("MONGODB_PORT")
  #set
  Sys.setenv(MONGODB_HOST="localhost")
  host = Sys.getenv("MONGODB_HOST")
  expect_equal(gc_setup(), "mongodb://localhost:27017")
  # reset
  reset(host, user, pass, port)
})

test_that("Jeroen's demo server", {
  # con <- mongo("mtcars", url = j)
  j = "mongodb://readwrite:test@mongo.opencpu.org:43942/jeroen_test"
  host = Sys.getenv("MONGODB_HOST")
  user = Sys.getenv("MONGODB_HOST")
  pass = Sys.getenv("MONGODB_PASS")
  port = Sys.getenv("MONGODB_PORT")
  # set
  Sys.setenv(MONGODB_HOST="mongo.opencpu.org")
  Sys.setenv(MONGODB_USER="readwrite")
  Sys.setenv(MONGODB_PASS="test")
  Sys.setenv(MONGODB_PORT="43942")
  expect_equal(gc_setup("jeroen_test"), j)
  con = mongolite::mongo("mtcars", url = gc_setup("jeroen_test"))
  expect_true(is(con, "jeroen"))
  reset(host, user, pass, port)
})
