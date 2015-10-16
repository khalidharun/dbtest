context("dbtest")

old_verbose <- options()$dbtest.verbose
options(dbtest.verbose = FALSE)

call_to_actual_database_oh_no <- function() {
  DBI::dbConnect(drv = DBI::dbDriver("Postgres"), dbname = "noexist")
}

test_that("our actual call will error", {
  expect_error(call_to_actual_database_oh_no())
})

with_test_db({
  test_that("stubbing the test connection doesn't error", {
  expect_true({ call_to_actual_database_oh_no(); TRUE }) }) })

test_that("the connection is stubbed to the test connection", {
  expect_equal(db_test_con(), with_test_db(call_to_actual_database_oh_no())) })

test_that("with_test_db produces a test_con object", {
  expect_equal(db_test_con(), with_test_db(test_con)) })

test_that("DBI operations can be done on the test_con", {
  expect_equal(DBI::dbListTables(db_test_con()), with_test_db(DBI::dbListTables(test_con)))
})

options(dbtest.verbose = old_verbose)
