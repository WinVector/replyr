# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr union_all
NULL

# list length>=1 no null entries
r_replyr_bind_rows <- function(lst) {
  n <- length(lst)
  if(n<=1) {
    return(lst[[1]])
  }
  mid <- floor(n/2)
  leftSeq <- 1:mid      # n>=2 so mid>=1
  rightSeq <- (mid+1):n # n>=2 so mid+1<=n
  left <- replyr_bind_rows(lst[leftSeq])
  right <- replyr_bind_rows(lst[rightSeq])
  dplyr::union_all(left,right) # https://github.com/rstudio/sparklyr/issues/76
}


#' bind a list of items by rows
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
