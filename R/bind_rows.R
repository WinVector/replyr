# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr union_all
NULL

# list length>=1 no null entries
r_replyr_bind_rows <- function(lst) {
  n <- length(lst)
  if(n<=1) {
    return(dplyr::compute(lst[[1]]))
  }
  mid <- floor(n/2)
  leftSeq <- 1:mid      # n>=2 so mid>=1
  rightSeq <- (mid+1):n # n>=2 so mid+1<=n
  left <- r_replyr_bind_rows(lst[leftSeq])
  right <- r_replyr_bind_rows(lst[rightSeq])
  # ideas from https://github.com/rstudio/sparklyr/issues/76
  # would like to use union_all, but seems to have problems with Spark 2.0.0
  # (spread example from basicChecksSpark200.Rmd)
  if(length(intersect("src_spark",class(left$src)))>0) {
    res <- dplyr::union(left,right)
  } else {
    res <- dplyr::union_all(left,right)
  }
  res <- dplyr::compute(res)
  res
}


#' bind a list of items by rows (can't use dplyr::bind_rows or dplyr::combine)
#'
#' @param lst list of items to combine, must be all in same dplyr data service
#' @return single data item
#'
#' @examples
#'
#' d <- data.frame(x=1:2)
#' replyr_bind_rows(list(d,d,d))
#'
#' @export
replyr_bind_rows <- function(lst) {
  if("NULL" %in% class(lst)) {
    return(NULL)
  }
  # remove any nulls or trivial data items.
  lst <- Filter(function(ri) { replyr_nrow(ri)>0 }, lst)
  n <- length(lst)
  if(n<=0) {
    return(NULL)
  }
  r_replyr_bind_rows(lst)
}
