context("db")
database.yml <- system.file(package = "dbtest", "database.yml")

test_that("db_connection errors if no database.yml file is passed", {
  expect_error(db_connection(NULL, env = "test")) })

test_that("db_connection errors if database.yml is passed but nonexistant", {
  expect_error(db_connection("path/to/nonexistant/file", env = "test")) })

test_that("db_connection errors if the env is not in the database.yml", {
  expect_error(db_connection(database.yml, env = "nonexistant")) })

test_that("db_connection can give a test connection", {
  expect_equal(db_test_con(),
    do.call(DBI::dbConnect, append(list(drv = DBI::dbDriver('Postgres')),
      yaml::yaml.load(paste(readLines(database.yml), collapse = "\n"))$test[-1]))) })
