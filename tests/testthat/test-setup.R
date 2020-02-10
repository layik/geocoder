test_that("setup works", {
  expect_error(setup())
  expect_error(check("foo"))
})

test_that("Setenv works", {
  # host = check("MONGODB_HOST")
  # user = check("MONGODB_USER")
  # pass = check("MONGODB_PASS")
  Sys.setenv(MONGODB_HOST="localhost")
  host = Sys.getenv("MONGODB_HOST")
  expect_equal(setup(), "mongodb://localhost:27017")
})

test_that("Jeroen's demo server", {
  j = "mongodb://readwrite:test@mongo.opencpu.org:43942/jeroen_test"
  # con <- mongo("mtcars", url = j)
  Sys.setenv(MONGODB_HOST="mongo.opencpu.org")
  Sys.setenv(MONGODB_USER="readwrite")
  Sys.setenv(MONGODB_PASS="test")
  Sys.setenv(MONGODB_PORT="43942")
  expect_equal(setup("jeroen_test"), j)

})
