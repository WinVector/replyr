
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' Set names of columns to known values and drop other columns
#'
#' @seealso \code{\link{let}}
#'
#' @param x data item to work on
#' @param nmap named list mapping existing columns to desired new names. Doesn't support permutations of names.
#' @return data item with columns limitted down to those named in nmap, and re-named.
#'
#' @examples
#'
#' # an external function with hard-coded column names
#' DecreaseRankColumnByOne <- function(d) {
#'   d$RankColumn <- d$RankColumn - 1
#'   d
#' }
#'
#' # our example data, with different column names
#' d <- data.frame(Sepal_Length=c(5.8,5.7),Sepal_Width=c(4.0,4.4),
#'                 Species='setosa',rank=c(1,2))
#' print(d)
#'
#' # map our data to expected column names so we can use function
#' nmap <- c('GroupColumn','ValueColumn','RankColumn')
#' names(nmap) <-  c('Species','Sepal_Length','rank')
#' dm <- replyr_renameRestrictCols(d,nmap)
#' print(dm)
#'
#' # can now apply code that expects hard-coded names.
#' dm <- DecreaseRankColumnByOne(dm)
#'
#' # map back to our original column names (for the columns we retained)
#' invmap <- names(nmap)
#' names(invmap) <- as.character(nmap)
#' # Note: can only map back columns that were retained in first mapping.
#' replyr_renameRestrictCols(dm,invmap)
#'
#' @export
replyr_renameRestrictCols <- function(x,nmap) {
  nmap <- as.list(nmap)
  if(length(unique(nmap))!=length(nmap)) {
    stop("replyr::replyr_renameRestrictCols duplicate destination columns in replyr_renameRestrictCols")
  }
  if(length(unique(names(nmap)))!=length(nmap)) {
    stop("replyr::replyr_renameRestrictCols duplicate source columns in replyr_renameRestrictCols")
  }
  for(ni in names(nmap)) {
    if(!is.character(ni)) {
      stop('replyr::replyr_renameRestrictCols nmap keys must be strings')
    }
    if(length(ni)!=1) {
      stop('replyr::replyr_renameRestrictCols nmap keys must be strings')
    }
    ti <- nmap[[ni]]
    if(!is.character(ti)) {
      stop('replyr::replyr_renameRestrictCols nmap values must be strings')
    }
    if(length(ti)!=1) {
      stop('replyr::replyr_renameRestrictCols nmap values must be strings')
    }
    if(ti!=ni) {
      if(ti %in% names(nmap)) {
        stop("replyr::replyr_renameRestrictCols source and destination columns overlap in replyr_renameRestrictCols")
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
