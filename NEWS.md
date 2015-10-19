# Version 0.0.0.9006
- Make available for R 3.1

# Version 0.0.0.9002-9005

- Introduces `db_test_that`, a safe test wrapper for isolating database actions.
- Introduces database testing helpers, such as `expect_table`, `expect_table_has`, and `expect_sql_is`.

# Version 0.0.0.9001

- `db_test_con` passes along errors making for easier debugging.
- Uses RPostgres::Postgres for the test driver explicitly rather than trying to search for it.
- Non-functional changes and additional test coverage to allow the package to work on Travis.

# Version 0.0.0.9000

- The beginning.
