
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom magrittr %>%
#' @importFrom dplyr ungroup summarize transmute
NULL

#' Compute number of rows of a tbl.
#'
#' Number of row in a table.  This function is not "group aware" it returns the total number of rows, not rows per dplyr group.
#'
#' @param x tbl or item that can be coerced into such.
#' @return number of rows
#'
#' @examples
#'
#' d <- data.frame(x=c(1,2))
#' replyr_nrow(d)
#'
#' @export
replyr_nrow <- function(x) {
  # not trusting n().
  # Commmented code doesn't work on example
  # x %>% dplyr::ungroup()  %>% dplyr::summarize(count=sum(1)) %>%
  #   as.data.frame() -> tmp
  # Code below does.
  if("NULL" %in% class(x)) {
    return(0)
  }
  tmp <- NULL
  # get empty corner case correct (counting returned NA on PostgreSQL for this)
  suppressWarnings(
    x %>% dplyr::ungroup() %>% head(n=1) %>% dplyr::collect() %>% as.data.frame() -> tmp)
  if(is.null(nrow(tmp))||(nrow(tmp)<1)||(ncol(tmp)<1)) {
    return(0)
  }
  constant <- NULL # false binding for 'constant' so name does not look unbound to CRAN check
  suppressWarnings(
    x %>% dplyr::ungroup() %>%
      dplyr::transmute(constant=1) %>% dplyr::summarize(count=sum(constant)) %>%
      dplyr::collect() %>% as.data.frame() -> tmp)
  if(is.null(nrow(tmp))||(nrow(tmp)<1)||(ncol(tmp)<1)) {
    return(0)
  }
  as.numeric(tmp[1,1,drop=TRUE])
}

