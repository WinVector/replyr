
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom magrittr %>%
#' @importFrom dplyr ungroup select_ mutate group_by_ summarize
NULL



#' Compute number of rows of a tbl.
#'
#' @param x tbl or item that can be coerced into such.
#' @param cname name of columns to examine, assume not equal to 'n'.
#' @return unique values for the column.
#'
#' @examples
#'
#' d <- data.frame(x=c(1,2,3,3))
#' replyr_uniqueValues(d,'x')
#'
#' @export
replyr_uniqueValues <- function(x,cname) {
  if((!is.character(cname))||(length(cname)!=1)||(cname[[1]]=='n')) {
    stop('replyr_uniqueValues cname must be a single string not equal to "n"')
  }
  x %>% dplyr::ungroup() %>%
    dplyr::select_(cname) %>% dplyr::mutate(n=1) %>%
    dplyr::group_by_(cname) %>% dplyr::summarize(n=sum(n)) -> res
  res
}
