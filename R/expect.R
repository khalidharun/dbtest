#' Expect that the table exists in the test database.
#'
#' @param table_name character. The name of the table to test for.
#' @examples \dontrun{expect_table("flights")}
#' @export
expect_table <- function(table_name) {
  on_fail_message <- paste(table_name, "does not exist in the test database")
  testthat::expect_true(DBI::dbExistsTable(test_con, table_name), on_fail_message)
}


#' Expect that a certain SQL statement will evaluate to a result.
#'
#' @param statement character. The SQL statement to run.
#' @param expected ANY. The expected result.
#' @examples \dontrun{expect_sql_is("SELECT id FROM flights LIMIT 1", 1)}
#' @export
expect_sql_is <- function(statement, expected) {
  result <- unname(unlist(DBI::dbGetQuery(db_test_con(), statement)))
  testthat::expect_equal(result, expected)
}

# expect_table_has(column("id"), table = "flights")
# expect_table_has(count("id") > 0, table = "flights")
