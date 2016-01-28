# Version 0.0.2.9002
- Added a get_options utility to be able to handle arbitrarily deeply nested config structures.

# Version 0.0.2.9001
- Remove the S3 dispatch because it breaks for objects with multiple classes.

# Version 0.0.2.9000
- Added rocco docs.
- Change the way `count` works in `expect_table_has`.
- Made non-breaking clarifications to various functions.

# Version 0.0.1
- Added `expect_sql_exists`, which tests that the SQL query returns something.
- Renamed `expect_sql_is` to `expect_sql_equals`.
- `expect_sql_equals` now returns the data.frame rather than the individual result.

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
