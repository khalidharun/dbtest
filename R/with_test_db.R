#' Create a connection to a test database for testing database transactions.
#' @return a database connection suitable for testing.
#' @export
db_test_con <- function(...) {
  conn <- try(db_connection(
    system.file(package = "dbtest", "database.yml"), env = "test", ...), silent = TRUE)
  if (is(conn, 'try-error')) {
    stop("Cannot run tests until you create a database named ", sQuote("travis"),
         "for user ", sQuote("postgres"), ". (You should be able to open ",
         "the PostgreSQL console using ", dQuote("psql postgres"),
         " from the command line. ",
         "From within there, run ", dQuote(paste0("CREATE DATABASE travis; ",
         "GRANT ALL PRIVILEGES ON DATABASE travis TO postgres;")),
         " You might also need to run ", dQuote("ALTER ROLE postgres WITH LOGIN;"),
         ")", call. = FALSE)
  }
  conn
}


#' Run a block of code where all DBI connections are mocked with the test connection.
#' @param expr. A block of R code to run.
#' @export
with_test_db <- function(expr) {
  DBI_namespace <- getNamespace("DBI") 
  old_dbConnect <- DBI::dbConnect

  new_dbConnect <- function(...) {
    # We have to unmock it so we can actually deliver our test connection
    # But it won't be unmocked until we're already delivering the new db connection.
    unmock_dbConnect(DBI_namespace, old_dbConnect)
    db_test_con()
  }

  test_con <- db_test_con()
  assign("test_con", test_con, envir = parent.frame())

  on.exit({
    DBI::dbDisconnect(test_con)
    unmock_dbConnect(DBI_namespace, old_dbConnect) })
 
  mock_dbConnect(DBI_namespace, new_dbConnect)
  eval.parent(substitute(expr))
}


mock_dbConnect <- function(DBI_namespace, new_dbConnect) {
  unlockBinding(DBI_namespace, sym = "dbConnect")
  assign("dbConnect", new_dbConnect, envir = DBI_namespace)
}

unmock_dbConnect <- function(DBI_namespace, old_dbConnect) {
  unlockBinding(DBI_namespace, sym = "dbConnect")
  assign("dbConnect", old_dbConnect, envir = DBI_namespace)
  lockBinding("dbConnect", DBI_namespace)
}
