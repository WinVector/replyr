
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom stats setNames
NULL

# dplyr::one_of is what is causing us to depend on dplyr (>= 0.5.0)



#' Map names of columns to known values and drop other columns.
#'
#' Used to restrict a data item's column names and re-name them in bulk.  Note: this can be expensive operation. Except for identity assigments keys and destinations must be disjoint.
#'
#' Something like \code{replyr::replyr_mapRestrictCols} is only useful to get control of a function that is not parameterized
#' (in the sense it has hard-coded column names inside its implementation that don't the match column names in our data).
#'
#' @seealso \code{\link{let}}
#'
#' @param x data item to work on
#' @param nmap named list mapping desired column names to column names in x. Doesn't support permutations of names.
#' @param ... force later arguments to bind by name
#' @param restrict logical if TRUE restrict to columns mentioned in nmap.
#' @param reverse logical if TRUE apply the inverse of nmap intead of nmap.
#' @return data item with columns limited down to those named as nmap values, and re-named from their orignal names (nmap values) to desired names (nmap keys).
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
#' d <- data.frame(Sepal_Length=c(5.8,5.7),
#'                 Sepal_Width=c(4.0,4.4),
#'                 Species='setosa',rank=c(1,2))
#' print(d)
#'
#' # map our data to expected column names so we can use function
#' nmap <- c(GroupColumn='Species',
#'           ValueColumn='Sepal_Length',
#'           RankColumn='rank')
#' print(nmap)
#' dm <- replyr_mapRestrictCols(d,nmap)
#' print(dm)
#'
#' # can now apply code that expects hard-coded names.
#' dm <- DecreaseRankColumnByOne(dm)
#'
#' # map back to our original column names (for the columns we retained)
#' # Note: can only map back columns that were retained in first mapping.
#' replyr_mapRestrictCols(dm, nmap, reverse=TRUE)
#'
#' @export
replyr_mapRestrictCols <- function(x,nmap,
                                   ...,
                                   restrict= TRUE,
                                   reverse= FALSE) {
  if(length(list(...))>0) {
    stop("replyr::replyr_mapRestrictCols unexpected argument")
  }
  nmap <- as.list(nmap)
  if(reverse) {
    invmap <- names(nmap)
    names(invmap) <- as.character(nmap)
    nmap <- as.list(invmap)
  }
  if(length(unique(as.character(nmap)))!=length(nmap)) {
    stop("replyr::replyr_mapRestrictCols duplicate source columns (nmap values) in replyr_mapRestrictCols")
  }
  if(length(unique(names(nmap)))!=length(nmap)) {
    stop("replyr::replyr_mapRestrictCols duplicate destination columns (nmap keys) in replyr_mapRestrictCols")
  }
  if(length(setdiff(as.character(nmap), colnames(x)))>0) {
    stop("replyr::replyr_mapRestrictCols all source columns (nmap values) must be column names of x")
  }
  for(ni in names(nmap)) {
    if(is.null(ni)) {
      stop('replyr::replyr_mapRestrictCols nmap keys must not be null')
    }
    if(!is.character(ni)) {
      stop('replyr::replyr_mapRestrictCols nmap keys must be strings')
    }
    if(length(ni)!=1) {
      stop('replyr::replyr_mapRestrictCols nmap keys must be scalars')
    }
    if(nchar(ni)<=0) {
      stop('replyr::replyr_mapRestrictCols nmap keys must not be empty strings')
    }
    if(!isValidAndUnreservedName(ni)) {
      stop(paste('replyr:replyr_mapRestrictCols nmap key not a valid name: "',ni,'"'))
    }
    ti <- nmap[[ni]]
    if(is.null(ti)) {
      stop('replyr::replyr_mapRestrictCols nmap values must not be null')
    }
    if((!is.character(ti))&&(!is.name(ti))) {
      stop('replyr::replyr_mapRestrictCols nmap values must be strings or quote')
    }
    if(length(ti)!=1) {
      stop('replyr::replyr_mapRestrictCols nmap values must be scalars')
    }
    ti <- as.character(ti)
    if(nchar(ti)<=0) {
      stop('replyr::replyr_mapRestrictCols nmap values must not be empty strings')
    }
    if(ti!=ni) {
      if(ti %in% names(nmap)) {
        stop("replyr::replyr_mapRestrictCols except for identity assigments keys and destinations must be disjoint")
      }
    }
  }
  if(restrict) {
    # limit down to only names we are mapping
    x %>% dplyr::select(dplyr::one_of(as.character(nmap))) -> x
  }
  # re-map names
  for(ni in names(nmap)) {
    ti <- as.character(nmap[[ni]])
    if(ti!=ni) {
      x <- replyr_rename(x, newName= ni, oldName= ti)
    }
  }
  x
}
