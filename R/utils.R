#' Reads a yaml file from a specified path.
#' @param path character. The file name of the yaml file.
#' @return a nested list as specified by the yaml file.
read_yml <- function(path) {
  yaml::yaml.load(paste(readLines(path), collapse = "\n"))
}


#' Helper function to get settings from a nested config file
#'
#' @param config list. The output from a YML file as a list.
#' @param env character. The keys of a nested to list to find the settings.
#' @return The settings if found else `NULL`.
get_config <- function(config, env) {
  if (!is.character(env)) stop("env is not a character.")
  if (!is.list(config)) stop("config is not a list.")
  if (length(env) > 1) Recall(config[[env[1]]], env[-1])
  config[[env]]
}
