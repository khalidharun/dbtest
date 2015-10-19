context("expect")

old_verbose <- options()$dbtest.verbose
options(dbtest.verbose = FALSE)


describe("expect_table", {
  db_test_that("expect_table is a passing test when there is a table", {
    DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
    expect_table("flights")
  })
  db_test_that("expect_table is a failing test when there is no table", {
    expect_failed_test(expect_table("flights"))
  })
  db_test_that("expect_table has an on failure message", {
    expect_equal(get_failure_message(expect_table("flights"))[[2]],
      "flights does not exist in the test database")
  })
})

describe("expect_sql_exists", {
  db_test_that("expect_sql_exists is a passing test when the SQL query returns a result", {
    DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
    DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
    expect_sql_exists("SELECT id FROM flights WHERE id = 1")
  })
  db_test_that("expect_sql_is is a failing test when the SQL query doesn't match", {
    DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
    DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
    expect_failed_test(expect_sql_exists("SELECT id FROM flights WHERE id = 2"))
  })
})

describe("expect_sql_is", {
  db_test_that("expect_sql_is errors when there is no table", {
    expect_error(expect_sql_is("SELECT id FROM flights LIMIT 1", 1), "does not exist")
  })
  db_test_that("expect_sql_is is a passing test when the SQL query matches", {
    DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
    DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
    expect_sql_is("SELECT id FROM flights LIMIT 1", 1)
  })
  db_test_that("expect_sql_is is a failing test when the SQL query doesn't match", {
    DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
    DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
    expect_failed_test(expect_sql_is("SELECT id FROM flights LIMIT 1", 2))
  })
})

describe("expect_table_has", {
  describe("column", {
    db_test_that("expect_table_has errors when there is no table", {
      expect_error(expect_table_has(column("id"), table = "flights"), "No such table")
    })
    db_test_that("expect_table_has is a passing test when the column is present", {
      DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
      expect_table_has(column("id"), table = "flights")
    })
    db_test_that("expect_table_has is a failing test when the column isn't present", {
      DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
      expect_failed_test(expect_table_has(column("noexist"), table = "flights"))
    })
    db_test_that("expect_table_has has an on failure message I", {
      DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
      expect_equal(
        get_failure_message(expect_table_has(column("noexist"), table = "flights"))[[2]],
        "flights did not have property column(\"noexist\")")
    })
  })
  describe("count", {
    db_test_that("expect_table_has errors when there is no table", {
      expect_error(expect_table_has(count("id") > 1, table = "flights"), "No such table")
    })
    db_test_that("expect_table_has is a passing test when the query is true I", {
      DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      expect_table_has(count("id") > 1, table = "flights")
    })
    db_test_that("expect_table_has is a failing test when the query is false", {
      DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      expect_failed_test(expect_table_has(count("id") > 2, table = "flights"))
    })
    db_test_that("expect_table_has has an on failure message II", {
      DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      expect_equal(
        get_failure_message(expect_table_has(count("id") > 2, table = "flights"))[[2]],
        "flights did not have property count(\"id\") > 2")
    })
    db_test_that("expect_table_has is a failing test when the query is true II", {
      DBI::dbGetQuery(test_con, "CREATE TABLE flights (id int);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      DBI::dbGetQuery(test_con, "INSERT INTO flights (id) VALUES (1);")
      expect_table_has(count("id") > 2, table = "flights")
    })
  })
})

options(dbtest.verbose = old_verbose)
