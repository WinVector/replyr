

#' Compute number of columns of a data.frame (work around https://github.com/rstudio/sparklyr/issues/976 ).
#'
#'
#' @param x tbl or item that can be coerced into such.
#' @return number of columns
#'
#' @examples
#'
#' d <- data.frame(x=c(1,2))
#' replyr_ncol(d)
#'
#' @export
replyr_ncol <- function(x) {
  length(colnames(x))
}




#' Compute dimensions of a data.frame (work around https://github.com/rstudio/sparklyr/issues/976 ).
#'
#' @param x tbl or item that can be coerced into such.
#' @return dimensions (including rows)
#'
#' @examples
#'
#' d <- data.frame(x=c(1,2))
#' replyr_dim(d)
#'
#' @export
replyr_dim <- function(x) {
  nrows <- replyr_nrow(x)
  ncol <- replyr_ncol(x)
  c(nrows, ncol)
}
