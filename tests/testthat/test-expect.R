context("expect")

old_verbose <- options()$dbtest.verbose
options(dbtest.verbose = FALSE)

#TODO: Move this to a helper file
with_mocked_testthat <- function(expr) {
  testthat::with_mock(`testthat::get_reporter` = function(...) {
    list(add_result = function(...) { NULL }) }, expr) }

test_passed <- function(expr) {
  with_mocked_testthat(expr)$passed
}

get_failure_message <- function(expr) {
  strsplit(with_mocked_testthat(expr)$failure_msg, "\n")[[1]]
}

expect_failed_test <- function(test) {
  expect_false(test_passed(test))
}

describe("with_mocked_testthat", {
  test_that("it can extract an error without erroring", {
    expect_failed_test(expect_true(FALSE))
  })
})


with_test_db({
  describe("expect_table", {
    test_that("expect_table is a passing test when there is a table", {
      #TODO: Move this wrapper to a generic `db_test_that`?
      lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
      DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
      expect_table("flights")
    })
    test_that("expect_table is a failing test when there is no table", {
      lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
      expect_failed_test(expect_table("flights"))
    })
    test_that("expect_table has an on failure message", {
      lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
      expect_equal(get_failure_message(expect_table("flights"))[[2]],
        "flights does not exist in the test database")
    })
  })

  describe("expect_sql_is", {
    test_that("expect_sql_is errors when there is no table", {
      lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
      expect_error(expect_sql_is("SELECT id FROM flights LIMIT 1", 1), "does not exist")
    })
    test_that("expect_sql_is is a passing test when the SQL query matches", {
      lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
      DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      expect_sql_is("SELECT id FROM flights LIMIT 1", 1)
    })
    test_that("expect_sql_is is a failing test when the SQL query doesn't match", {
      lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
      DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      expect_failed_test(expect_sql_is("SELECT id FROM flights LIMIT 1", 2))
    })
  })

  describe("expect_table_has", {
    describe("column", {
      test_that("expect_table_has errors when there is no table", {
        lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
        expect_error(expect_table_has(column("id"), table = "flights"), "No such table")
      })
      test_that("expect_table_has is a passing test when the column is present", {
        lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
        DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
        expect_table_has(column("id"), table = "flights")
      })
      test_that("expect_table_has is a failing test when the column isn't present", {
        lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
        DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
        expect_failed_test(expect_table_has(column("noexist"), table = "flights"))
      })
      test_that("expect_table_has has an on failure message I", {
        lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
        DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
        expect_equal(
          get_failure_message(expect_table_has(column("noexist"), table = "flights"))[[2]],
          "flights did not have property column(\"noexist\")")
      })
    })
    describe("count", {
      test_that("expect_table_has errors when there is no table", {
        lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
        expect_error(expect_table_has(count("id") > 1, table = "flights"), "No such table")
      })
      test_that("expect_table_has is a passing test when the query is true I", {
        lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
        DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
        DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
        DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
        expect_table_has(count("id") > 1, table = "flights")
      })
      test_that("expect_table_has is a failing test when the query is false", {
        lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
        DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
        DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
        DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
        expect_failed_test(expect_table_has(count("id") > 2, table = "flights"))
      })
      test_that("expect_table_has has an on failure message II", {
        lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
        DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
        DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
        DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
        expect_equal(
          get_failure_message(expect_table_has(count("id") > 2, table = "flights"))[[2]],
          "flights did not have property count(\"id\") > 2")
      })
      test_that("expect_table_has is a failing test when the query is true II", {
        lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
        DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
        DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
        DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
        DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
        expect_table_has(count("id") > 2, table = "flights")
      })
    })
  })
})

options(dbtest.verbose = old_verbose)
