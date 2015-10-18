# We want to get information about failed tests without actually creating failed tests.
# So we use testthat to mock itself (so meta!) to turn the test reporter off.
with_mocked_testthat <- function(expr) {
  testthat::with_mock(`testthat::get_reporter` = function(...) {
    list(add_result = function(...) { NULL }) }, expr) }

test_passed <- function(expr) {
  with_mocked_testthat(expr)$passed
}

get_failure_message <- function(expr) {
  strsplit(with_mocked_testthat(expr)$failure_msg, "\n")[[1]]
}

expect_failed_test <- function(test) {
  expect_false(test_passed(test))
}


describe("with_mocked_testthat", {
  test_that("it can extract an error without erroring", {
    expect_failed_test(expect_true(FALSE))
  })
})
