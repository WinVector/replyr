
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' Get column classes.
#'
#' @param x tbl or item that can be coerced into such.
#' @return list of column classes.
#'
#' @examples
#'
#' d <- data.frame(x=c(1,2))
#' replyr_colClasses(d)
#'
#' @export
replyr_colClasses <- function(x) {
  x  %.>%
    dplyr::ungroup(.) %.>%
    head(.) %.>%
    dplyr::collect(.) %.>%
    as.data.frame(.) -> topx
  classes <- lapply(topx,class)
  names(classes) <- colnames(topx)
  classes
}

#' Run test on columns.
#'
#' Applies user function to head of each column.  Good for determing things
#' such as column class.
#'
#' @param x tbl or item that can be coerced into such.
#' @param f test function (returning logical, not depending on data length).
#' @param n number of rows to use in calculation.
#' @return logical vector of results.
#'
#' @examples
#'
#' d <- data.frame(x=c(1,2),y=c('a','b'))
#' replyr_testCols(d,is.numeric)
#'
#' @export
replyr_testCols <- function(x, f, n = 6L) {
  x %.>%
    head(., n=n) %.>%
    dplyr::collect(.) %.>%
    as.data.frame(.) -> topx
  vapply(topx,f,logical(1))
}
