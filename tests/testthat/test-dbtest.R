context("dbtest")

call_to_actual_database_oh_no <- function() {
  DBI::dbConnect(drv = DBI::dbDriver("Postgres"), dbname = "noexist")
}

test_that("our actual call will error", {
  expect_error(call_to_actual_database_oh_no())
})

test_that("we can stub our actual db call with the test connection", {
  expect_true(with_test_db({ call_to_actual_database_oh_no(); TRUE }))
})

test_that("with_test_db produces a test_con object", {
  expect_equal(db_test_con(), with_test_db(test_con))
})
