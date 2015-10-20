DBTest [![Build Status](https://travis-ci.org/syberia/dbtest.svg?branch=master)](https://travis-ci.org/syberia/dbtest) [![Coverage Status](https://coveralls.io/repos/syberia/dbtest/badge.svg?branch=master)](https://coveralls.io/r/syberia/dbtest)
=============

DBTest is a package to provide database testing and mocking in R.

Imagine you want to make a call to a production database...

```R
DBI::dbConnect(drv = DBI::dbDriver("Postgres"), dbname = "production")
```

But in your tests, you'd prefer if your code called to a test database instead.

DBTest provides `with_test_db`, which you can use like this:

```R
dbtest::with_test_db(
  DBI::dbConnect(drv = DBI::dbDriver("Postgres"), dbname = "production")
)
```

...that connection will be reset to a test connection instead!  And all calls to the production database within your tests will be mocked as calls to the test database.

Also, in your tests `with_test_db` will create an R object called `test_con` which you can use to work with the connection.

```R
dbtest::with_test_db(DBI::dbListTables(test_con))   # test_con is a connection to the test database.
```

-

Lastly, to create separate, safe test blocks where database actions in previous tests do not affect future tests, wrap individual tests in `db_test_that` instead of `test_that`.  If you do this, you do not need to use `with_test_db`.


## Further Testing

You can then test your database with a variety of helpers:

```R
library(testthat)
library(dbtest)

db_test_that("My database has a test table", {
  expect_table("test")
})

db_test_that("My test table has a test column", {
  expect_table_has(column("test"), table = "test")
})

db_test_that("My test table has a test column with at least three entries", {
  expect_table_has(count("test") >= 3, table = "test")
})

db_test_that("'hello world' is in my test table", {
  expect_sql_exists("SELECT test FROM test WHERE value = 'hello_world'")
})

db_test_that("The first value of my test column is 'hello world'", {
  expect_sql_equals("SELECT test FROM test LIMIT 1", data.frame(test = "hello_world"))
})
```


## Installation

#### Installing the Package

```R
if (!require("devtools")) { install.packages("devtools") }
devtools::install_github("syberia/dbtest")
```

#### Creating the Test Database

```
psql postgres
CREATE DATABASE travis;
GRANT ALL PRIVILEGES ON DATABASE travis TO postgres;
ALTER ROLE postgres WITH LOGIN;
```
