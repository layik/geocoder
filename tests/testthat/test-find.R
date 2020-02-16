source("../skip-import.R")

context("gc-find")

test_that("can find vancouver geometries", {
  skip_import()
  # import
  gc_import(paste0("https://github.com/layik/geocoder/releases/",
                   "download/data/v10.geojson"),
            local = FALSE,
            collection="test_v10")
  temp.file = file.path(tempdir(), "import.json")
  sf.df = geojsonsf::geojson_sf(temp.file)
  v = mongolite::mongo(collection="test_v10")
  kv = data.frame(properties.growth=c(0.3592))
  r = gc_find(kv)
  # should be one
  expect_equal(nrow(r), 1)
  # test with full_url
  r = gc_find(kv, full_url = "mongodb://localhost:27017/test")
  expect_equal(nrow(r), 1)
  # destroy collection
  v$drop()
  # cleanup
  file.remove(temp.file)
})
