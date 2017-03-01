
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr %>% ungroup select_ mutate group_by_ summarize
NULL



#' Compute number of rows of a tbl.
#'
#' @param x tbl or item that can be coerced into such.
#' @param cname name of columns to examine, must not be equal to 'replyr_private_value_n'.
#' @return unique values for the column.
#'
#' @examples
#'
#' d <- data.frame(x=c(1,2,3,3))
#' replyr_uniqueValues(d,'x')
#'
#' @export
replyr_uniqueValues <- function(x,cname) {
  if((!is.character(cname))||(length(cname)!=1)||(cname[[1]]=='replyr_private_value_n')) {
    stop('replyr_uniqueValues cname must be a single string not equal to "replyr_private_value_n"')
  }
  replyr_private_value_n <- NULL # false binding for 'replyr_private_value_n' so name does not look unbound to CRAN check
  x %>% dplyr::ungroup() %>%
    dplyr::select_(cname) %>% dplyr::mutate(replyr_private_value_n=1.0) %>%
    dplyr::group_by_(cname) %>% dplyr::summarize(replyr_private_value_n=sum(replyr_private_value_n)) -> res
  # # Can't get rid of the warning on MySQL, even the following doesn't shut it up
  # suppressWarnings(
  #   # on mutate step in MySQL:  In .local(conn, statement, ...) : Decimal MySQL column 1 imported as numeric
  #   x %>% dplyr::ungroup() %>%
  #     dplyr::select_(cname) %>% dplyr::mutate(replyr_private_value_n=1.0) %>%
  #     dplyr::group_by_(cname) %>% dplyr::summarize(replyr_private_value_n=sum(replyr_private_value_n)) %>%
  #     dplyr::compute() -> res
  # )
  res
}
