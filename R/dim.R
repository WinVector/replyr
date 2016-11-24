
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' Compute dimensions of a tbl.
#'
#' @param x tbl or item that can be coerced into such.
#' @return dimensions (including rows)
#'
#' @examples
#'
#' d<- data.frame(x=c(1,2))
#' replyr_dim(d)
#'
#' @export
replyr_dim <- function(x) {
  dims <- dim(x)
  nrows <- replyr_nrow(x)
  dims[1] <- nrows
  dims
}
