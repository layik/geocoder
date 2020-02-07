test_that("setup works", {
  expect_error(setup())
  expect_error(check("foo"))
})
