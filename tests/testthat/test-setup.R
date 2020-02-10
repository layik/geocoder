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
