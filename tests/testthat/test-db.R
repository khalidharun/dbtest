context("db")

test_that("db_connection errors if no database.yml file is passed", {
  expect_error(db_connection(NULL))
})
