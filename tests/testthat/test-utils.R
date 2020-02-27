test_that("nothing returned", {
  expect_error(gc_query())
  expect_silent(gc_query(query = "near", type = "point"))
  expect_error(gc_query(query = "geoIntersects", type = "point"))
  expect_error(gc_query(query = "geoIntersects"))
})

test_that("GeoJSON geomtypes work", {
  expect_error(gc_query(query = "geoIntersects", type = "pointtt"))
  expect_error(gc_query(query = "geoIntersects", type = "multipointtt"))
  expect_error(gc_query(query = "geoIntersects", type = "poygonn"))
  expect_error(gc_query(query = "geoIntersects", type = "multipolygonnn"))
  expect_error(gc_query(query = "geoIntersects", type = "linestring"))
  expect_error(gc_query(query = "geoIntersects", type = "multilinestringg"))
  expect_error(gc_query(query = "geoIntersects", type = "GeometryCollectionn"))
})
