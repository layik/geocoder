context("gc-query")
test_that("nothing returned", {
  expect_error(gc_query())
  expect_error(gc_query(query = "geoIntersects", type = "point"))
  expect_error(gc_query(query = "geoIntersects"))
})

test_that("geoWithin works", {
  expect_error(gc_query(query = "geoWithin", type = "point"))
  expect_error(gc_query(query = "geoWithin"))
})

test_that("near works", {
  expect_error(gc_query(query = "near", type = "point",
                        coords = c(0,1),
                        maxDistance = "1",
                        minDistance = "2"))
  expect_error(gc_query(query = "near", type = "point", coords = c(0,1,2)))
  expect_error(gc_query(query = "near", type = "point"))
  expect_error(gc_query(query = "near"))
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

test_that("generate query", {
  expect_error(gc_query(query = "geoIntersects", type = "linestring"),
               "argument \"coords\"")
  expect_is(gc_query(query = "geoIntersects", type = "linestring",
                          coords = matrix(1:6, ncol = 2)),
                  "character")
  expect_error(gc_query(query = "geoIntersects", type = "polygon",
                     coords = matrix(1:6, ncol = 2)))
  pts = matrix(1:15, , 3)
  expect_is(gc_query(query = "geoIntersects", type = "multipoint",
                     coords = pts),
            "character")
  # (mp2 = st_multipoint(pts))
  # thanks https://r-spatial.github.io/sf/reference/st.html
  outer = matrix(c(0,0,10,0,10,10,0,10,0,0),ncol=2, byrow=TRUE)
  hole1 = matrix(c(1,1,1,2,2,2,2,1,1,1),ncol=2, byrow=TRUE)
  hole2 = matrix(c(5,5,5,6,6,6,6,5,5,5),ncol=2, byrow=TRUE)
  pts = list(outer, hole1, hole2)
  pts3 = lapply(pts, function(x) cbind(x, 0))
  # (ml2 = st_multilinestring(pts3))
  expect_is(gc_query(query = "geoIntersects", type = "multilinestring",
                     coords = pts3),
            "character")
  # (pl1 = st_polygon(pts))
  pol1 = list(outer, hole1, hole2)
  pol2 = list(outer + 12, hole1 + 12)
  pol3 = list(outer + 24)
  mp = list(pol1,pol2,pol3)
  # (mp1 = st_multipolygon(mp))
  expect_is(gc_query(query = "geoIntersects", type = "multipolygon",
                     coords = mp),
            "character")
  expect_is(gc_query(query = "geoIntersects", type = "polygon",
                     coords = pts),
            "character")
})
