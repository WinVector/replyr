
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr glimpse
NULL


#' Show structure of table.
#'
#' @param x tbl or item that can be coerced into such.
#' @return summary text.
#'
#' @examples
#'
#' d <- data.frame(x=c(1,2))
#' replyr_str(d)
#'
#' @export
replyr_str <- function(x) {
  s <- capture.output(dplyr::glimpse(x))
  nrows <- replyr_nrow(x)
  s <- c(paste0("nrows: ",nrows),s)
  cat(paste(s,collapse='\n'))
}
