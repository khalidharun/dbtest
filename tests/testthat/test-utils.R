context("utils")

describe("get_config", {
  settings <- list(foo = "bar")

  test_that("it returns a first level config", {
    config <- list(target = settings)
    expect_identical(settings, get_config(config, c("target")))
  })

  test_that("it returns a 2nd level config", {
    config <- list(level1 = list(target = settings))
    expect_identical(settings, get_config(config, c("level1", "target")))
  })

  test_that("it finds a deeply nested config", {
    config <- list(level1 = list(level2 = list(level3 = list(level4 = list(target = settings)))))
    expect_identical(settings, get_config(config, c("level1", "level2", "level3", "level4", "target")))
  })

  test_that("it returns NULL with a missing config key", {
    config <- list(bar = settings)
    expect_null(get_config(config, "foo"))
  })

  test_that("it returns NULL with a missing nested config key", {
    config <- list(level1 = list(bar = settings))
    expect_null(get_config(config, c("level1", "foo")))
  })

  test_that("it fails with a malformed config list", {
    config <- "surprise!"
    expect_error(regexp = "config is not a list", get_config(config, "foo"))
  })
})
