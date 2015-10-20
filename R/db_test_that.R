#' Create a connection to a test database for testing database transactions.
#' @param ... list. Additional arguments to pass to /code{db_connection}
#' @return a database connection suitable for testing.
#' @export
db_test_con <- function(...) {
  ## Use the database.yml specified in inst/database.yml to create a test connection.
  test_database_yml <- system.file(package = "dbtest", "database.yml")
  ## Try to make a db_connection with that test specificiation.
  tryCatch({ db_connection(test_database_yml, env = "test", ...)
  }, error = function(e) {
    ## If the error contains "does not exist", we assume it is because the database
    ## specified by the test connection was not created by the user, and instead we
    ## give the user a more helpful error message explaining how they should use it.
    if (grepl("does not exist", conditionMessage(e))) {
      stop("Cannot run tests until you create a database named ", sQuote("travis"),
           "for user ", sQuote("postgres"), ". (You should be able to open ",
           "the PostgreSQL console using ", dQuote("psql postgres"),
           " from the command line. ",
           "From within there, run ", dQuote(paste0("CREATE DATABASE travis; ",
           "GRANT ALL PRIVILEGES ON DATABASE travis TO postgres;")),
           " You might also need to run ", dQuote("ALTER ROLE postgres WITH LOGIN;"),
           ")", call. = FALSE)
    ## Otherwise, we will just let the error surface so they can deal with it (e.g., bad driver).
    } else { stop(e) } }) }


#' Run a block of code where all DBI connections are mocked with the test connection.
#' @param expr expression. A block of R code to run.
#' @export
with_test_db <- function(expr) {
  ## Our goal is to mock (swap out) all connections to any databases to our test connection.
  ## Anything done within `with_test_db(...)` will be done with a test connection instead of
  ## whatever connection the package specifies, assuming that package uses DBI.

  ## This is done by replacing DBI::dbConnect with a connection to the test database.
  DBI_namespace <- getNamespace("DBI") 
  old_dbConnect <- DBI::dbConnect

  ## This is the new dbConnect function we're going to replace.
  new_dbConnect <- function(...) {
    ## New dbConnect will unmock the connection so that our test connection can actually go through.
    ## But at this point we've already captured the old connection call, so the only option will be
    ## to create our test connection.
    unmock_dbConnect(DBI_namespace, old_dbConnect)
    ## Return the test connection object.
    db_test_con()
  }

  ## For the purposes of testing we want to give the user a quick variable to refer to the test
  ## connection without recomputing it every time.  We make it available as `test_con` in their
  ## parent.frame, where the tests are run.
  test_con <- db_test_con()
  assign("test_con", test_con, envir = parent.frame())

  ## Once we're done testing, we want to make sure connections will go on as normal, so we should
  ## disconnect our test database and unmock the connection.
  on.exit({
    DBI::dbDisconnect(test_con)
    unmock_dbConnect(DBI_namespace, old_dbConnect) })
 
  ## But first we have to actually mock the connection and then evaluate their R expression with
  ## the mocked connection in place.
  mock_dbConnect(DBI_namespace, new_dbConnect)
  eval.parent(substitute(expr))
}


mock_dbConnect <- function(DBI_namespace, new_dbConnect) {
  ## Mocking is done by rewriting the dbConnect in the DBI namespace.
  unlockBinding(DBI_namespace, sym = "dbConnect")
  assign("dbConnect", new_dbConnect, envir = DBI_namespace)
}

unmock_dbConnect <- function(DBI_namespace, old_dbConnect) {
  ## Unmocking is done by rewriting the mocked dbConnect back to what it was.
  unlockBinding(DBI_namespace, sym = "dbConnect")
  assign("dbConnect", old_dbConnect, envir = DBI_namespace)
  ## We then re-lock the binding so other people aren't messing with it.
  lockBinding("dbConnect", DBI_namespace)
}


#' Run a single testthat test in a self-contained database transaction.
#'
#' This will contain your database actions to a single test, by deleting all the
#' tables in the test db before you begin.  This keeps tests from interfering
#' with each other.
#'
#' @param description character. The description of the test.
#' @param test expression. The test to execute.
#' @export
db_test_that <- function(description, test) {
  ## We use `with_test_db` to get our test database connection.
  with_test_db({
    ## We want to drop all the tables in the test database so we start fresh with every test.
    ## This way, database actions done in previous tests won't affect future tests.
    drop_all_test_tables(test_con)
    ## We then make "test_con" available to the tests, just as `with_test_db` did.
    ## However, we're assigning it in the GlobalEnv because I couldn't figure out how to
    ## get it assigned in the correct scope, given all the testthat layers between this
    ## and the actual tests.
    assign("test_con", test_con, envir = .GlobalEnv) 
    ## When we're done running the tests, clean up our test connection object so we don't
    ## pollute the global namespace.
    on.exit(rm("test_con", envir = .GlobalEnv))
    ## Run the test code.
    eval(test)
  })
}


#' Drop all the tables in the test database.
#' @param test_con DBIConnection. A connection to the test database.
drop_all_test_tables <- function(test_con) {
  lapply(DBI::dbListTables(test_con), function(t) DBI::dbRemoveTable(test_con, t))
}
