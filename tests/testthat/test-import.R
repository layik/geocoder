source("../skip-import.R")

context("gc-import")

test_that("gc_import args", {
  expect_error(gc_import())
  expect_error(gc_import(collection = "bar"))
  expect_error(gc_import("/tmp_tation"))
  expect_error(gc_import("/tmp", index = "foobar"),
               "Index")
})
# if GEOCODER_MONGODB_AVAILABLE == true
test_that("gc_import part vancouver works", {
  skip_import();
  # import
  gc_import(paste0("https://github.com/layik/geocoder/releases/",
                   "download/data/v10.geojson"),
            local = FALSE,
            collection="test_v10")
  temp.file = file.path(tempdir(), "import.json")
  # wrong mongo_url
  expect_error(gc_import(temp.file, mongo_url="foo"),
               "failed to parse URI")
  sf.df = geojsonsf::geojson_sf(temp.file)
  v = mongolite::mongo(collection="test_v10")
  expect_equal(nrow(sf.df), v$count())
  # destroy collection
  v$drop()
  # cleanup
  file.remove(temp.file)
})

test_that("gc_import_sf works", {
  # get some crash data
  acc = stats19::accidents_sample
  acc = stats19::format_sf(acc, lonlat = T)
  # class(acc)
  s = mongolite::mongo(collection="stats19")
  gc_import_sf(acc, collection = "stats19")
  expect_equal(nrow(acc), s$count())
  s$drop()
})
