
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' Set names of columns to known values and drop other columns
#'
#' @param x data item to work on
#' @param nmap named list mapping existing columns to desired new names. Doesn't support permutations of names.
#' @return data item with columns limitted down to those named in nmap, and re-named.
#'
#' @examples
#'
#' d <- data.frame(Sepal_Length=c(5.8,5.7),Sepal_Width=c(4.0,4.4),
#'                 Species='setosa',rank=c(1,2))
#' nmap <- c('GroupColumn','ValueColumn','RankColumn')
#' names(nmap) <-  c('Species','Sepal_Length','rank')
#' replyr_renameRestrictCols(d,nmap)
#'
#'
#' @export
replyr_renameRestrictCols <- function(x,nmap) {
  if(length(unique(nmap))!=length(nmap)) {
    stop("duplicate destination columns in replyr_renameRestrictCols")
  }
  if(length(unique(names(nmap)))!=length(nmap)) {
    stop("duplicate source columns in replyr_renameRestrictCols")
  }
  for(ni in names(nmap)) {
    ti <- nmap[[ni]]
    if(ti!=ni) {
      if(ti %in% names(nmap)) {
        stop("source and destination columns overlap in replyr_renameRestrictCols")
      }
    }
  }
  # limit down to only names we are mapping
  #do.call(dplyr::select_,c(list(x),as.list(names(nmap)))) -> x
  x %>% dplyr::select(dplyr::one_of(names(nmap))) -> x
  # re-map names
  for(ni in names(nmap)) {
    ti <- nmap[[ni]]
    if(ti!=ni) {
      x %>% dplyr::rename_(.dots=stats::setNames(ni,ti)) -> x
    }
  }
  x
}
