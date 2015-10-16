#' Reads a yaml file from a specified path.
#' @param path character. The file name of the yaml file.
#' @return a nested list as specified by the yaml file.
read_yml <- function(path) {
  yaml::yaml.load(paste(readLines(path), collapse = "\n"))
}
