source("../skip-import.R")

test_that("gc_import args", {
  expect_error(gc_import())
  expect_error(gc_import(collection = "bar"))
  expect_error(gc_import("/tmp_tation"))
  expect_error(gc_import("/tmp", index = "foobar"),
               "Index")
})
# if GEOCODER_MONGODB_AVAILABLE == true
test_that("gc_import vancouver works", {
  skip_import();
  # https://github.com/uber-common/deck.gl-data/raw/master/examples/geojson/vancouver-blocks.json

})
