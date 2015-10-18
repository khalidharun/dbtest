#' Expect that the table exists in the test database.
#'
#' @param table_name character. The name of the table to test for.
#' @export
expect_table <- function(table_name) {
  on_fail_message <- paste(table_name, "does not exist in the test database")
  testthat::expect_true(DBI::dbExistsTable(test_con, table_name), on_fail_message)
}



# expect_table("flights")
# expect_sql_is("SELECT id FROM flights LIMIT 1", 1)
# expect_table_has(column("id"), table = "flights")
# expect_table_has(count("id") > 0, table = "flights")
