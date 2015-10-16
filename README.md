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
