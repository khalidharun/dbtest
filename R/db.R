#' Obtain a connection to a database.
#'
#' Your database.yml should look like:
#'
#' development:
#'   adapter: PostgreSQL
#'   username: <username>
#'   password: <password>
#'   database: <name>
#'   host: <domain>
#'   port: <port #>
#'
#' @param database.yml character. The location of the database.yml file
#'   to use. This could, for example, some file in the config directory.
#' @param env character. What environment to use from the database.yml.
#'   In the example database.yml, the environment is \code{development}.
#' @param verbose logical. Whether or not to print messages indicating
#'   loading is in progress. Defaults to \code{TRUE}.
#' @return the database connection specified by your database.yml file.
#' @export
db_connection <- function(database.yml, env, verbose = TRUE) {
  if (is.null(database.yml)) { stop("Please pass a file name to a database.yml file.") }
  if (!file.exists(database.yml)) {
    stop("Provided database.yml file does not exist: ", database.yml)
  }

  if (isTRUE(verbose) && !identical(options()$dbtest.verbose, FALSE)) {
    message("* Loading database connection...\n")
  }

  ## Read the yaml file for the database.yml
  config <- read_yml(database.yml)
  ## Check to make sure that an env is specified
  if (!missing(env) && !is.null(env)) {
    if (!env %in% names(config)) {
      stop(paste0("Unable to load database settings from database.yml ",
              "for environment '", env, "'"))
    }
    ## Load the configuration for that environment
    config <- config[[env]]
    ## If there is only one config we can just load it.
  } else if (missing(env) && length(config) == 1) {
    config <- config[[1]]
  }
  ## Authorization arguments needed by the DBMS instance
  do.call(DBI::dbConnect, append(list(drv = RPostgres::Postgres()),
    config[!names(config) %in% "adapter"]))
}


#' Helper function to build the connection.
#'
#' @param con connection. Could be characters of yaml file path with optional environment,
#'   or a function passed by user to establish the connection, or a database connetion object.
#' @param env character. What environment to use when `con` is a the yaml file path.
#' @return a list of database connection and if it can be re-established.
#' @export
build_connection <- function(con, env) {
  UseMethod("build_connection")
}

## Use S3 method dispatch to create connections for a variety of input parameters.
build_connection.DBIConnection <- function(con, env) { con }
build_connection.character <- function(con, env) { db_connection(con, env) }
build_connection.function <- function(con, env) { con() }

## Handle input that is not DBIConnection, character, or function.
build_connection.default <- function(con, env) {
  if (length(grep("SQLConnection", class(con)[1])) > 0) {
    return(con)
  } else {
    stop("The connection passed should be a DBIConnection, a SQLConnection, ",
      "a string specifying a database.yml, or a function.  Instead, I got",
      " a ", class(con), ".")
  }
}


#' Helper function to check the database connection.
#'
#' @param con SQLConnection.
#' @return `TRUE` or `FALSE` indicating if the database connection is good.
#' @export
is_db_connected <- function(con) {
  ## The database is connected if we can run a simple query on the connection and get a result. 
  res <- tryCatch(DBI::dbGetQuery(con, "SELECT 1")[1, 1], error = function(e) NULL)
  if (is.null(res) || res != 1) FALSE else TRUE
}
