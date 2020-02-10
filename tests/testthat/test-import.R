source("../skip-import.R")

test_that("import args", {
  expect_error(import())
  expect_error(import(collection = "bar"))
  expect_error(import("/tmp_tation"))
  expect_error(import("/tmp", index = "foobar"),
               "Index")
})
# if GEOCODER_MONGODB_AVAILABLE == true
test_that("import vancouver works", {
  skip_import();

})
