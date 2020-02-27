test_that("nothing returned", {
  expect_silent(gc_query(query = "near", type = "point"))
  expect_error(gc_query(query = "geoIntersects", type = "point"))
})
