test_that("nothing returned", {
  expect_error(gc_query())
  expect_silent(gc_query(query = "near", type = "point"))
  expect_error(gc_query(query = "geoIntersects", type = "point"))
  expect_error(gc_query(query = "geoIntersects", type = "pointtt"))
  expect_error(gc_query(query = "geoIntersects"))
})
