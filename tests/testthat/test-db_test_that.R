# dbtest uses dbtest to test dbtest
context("dbtest")

old_verbose <- options()$dbtest.verbose
options(dbtest.verbose = FALSE)

call_to_actual_database_oh_no <- function() {
  DBI::dbConnect(drv = DBI::dbDriver("Postgres"), dbname = "noexist")
}

describe("tb_test_con", {
  test_that("A missing travis db will result in a custom travis db error", {
    bad_db <- list("test" = list(dbname = "travis", user = "bogus", password = "", host = "localhost"))
    testthat::with_mock(`dbtest::read_yml` = function(...) bad_db,
      expect_error(db_test_con(), "Cannot run tests until you create a database named")) })

  test_that("A missing driver will result in a driver error", {
    testthat::with_mock(`RPostgres::Postgres` = function(...) DBI::dbDriver("noexist"),
      expect_error(db_test_con(), "Couldn't find driver noexist")) })

  test_that("A generic error will return that generic error", {
    testthat::with_mock(`RPostgres::Postgres` = function(...) stop("Error!"),
      expect_error(db_test_con(), "Error!")) })

  test_that("The connection returns", { expect_is(db_test_con(), "PqConnection") }) })


describe("with_test_db", {
  old_verbose <- options()$dbtest.verbose
  options(dbtest.verbose = FALSE)

  test_that("our actual call will error", {
    expect_error(call_to_actual_database_oh_no()) })

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
})


describe("db_test_that", {
  db_test_that("earlier database actions cannot interfere with later tests I", {
    DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
    expect_table("flights")
  })
  db_test_that("earlier database actions cannot interfere with later tests II", {
    expect_failed_test(expect_table("flights"))
  })
})

options(dbtest.verbose = old_verbose)
