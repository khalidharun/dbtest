#' Expect that the table exists in the test database.
#'
#' @param table_name character. The name of the table to test for.
#' @examples \dontrun{expect_table("flights")}
#' @export
expect_table <- function(table_name) {
  on_fail_message <- paste(table_name, "does not exist in the test database")
  testthat::expect_true(DBI::dbExistsTable(db_test_con(), table_name), on_fail_message)
}


#' Expect that a certain SQL statement will have a result.
#'
#' @param statement character. The SQL statement to run.
#' @export
expect_sql_exists <- function(statement) {
  on_fail_message <- "Your query did not return a result."
  testthat::expect_true(NROW(DBI::dbGetQuery(test_con, statement)) > 0, on_fail_message)
}


#' Expect that a certain SQL statement will evaluate to a result.
#'
#' @param statement character. The SQL statement to run.
#' @param expected ANY. The expected result.
#' @examples \dontrun{expect_sql_is("SELECT id FROM flights LIMIT 1", 1)}
#' @export
expect_sql_equals <- function(statement, expected) {
  result <- DBI::dbGetQuery(db_test_con(), statement)
  testthat::expect_equal(result, expected)
}


#' Expect that the table has a certain property.
#' @param test ANY. The test to run.
#' @param table character. The name of the table to check.
#' @examples \dontrun{
#'   expect_table_has(column("id"), table = "flights")
#'   expect_table_has(count("id") > 0, table = "flights")
#' }
#' @export
expect_table_has <- function(test, table) {
  if (!DBI::dbExistsTable(db_test_con(), table)) { stop("No such table ", table, " found.") }
  column <- function(colname) {
    colname %in% unname(unlist(DBI::dbGetQuery(db_test_con(),
      paste0("SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '",
        table, "';"))))
  }
  count <- function(colname) {
    unname(unlist(DBI::dbGetQuery(db_test_con(),
      paste0("SELECT COUNT(", colname, ") FROM ", table, ";"))))
  }
  on_fail_message <- paste(table, "did not have property", deparse(substitute(test)))
  testthat::expect_true(eval(substitute(test), envir = environment()), on_fail_message)
}
