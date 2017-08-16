
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom stats setNames
NULL

# dplyr::one_of is what is causing us to depend on dplyr (>= 0.5.0)


# return temp names disjoint from a given set of names
# names: names to avoid
# k: how many temps to make
tempNamesDisjointFrom <- function(names= NULL, k= 1) {
  names <- unique(as.character(names))
  candidates <- paste0('REPLYRTMP',
                       sprintf("%012d",seq_len(k+length(names))))
  candidates <- setdiff(candidates, names)
  candidates[seq_len(k)]
}

#' Reverse a name assignment map (which are written NEWNAME=OLDNAME).
#'
#' @param nmap named list mapping with keys specifying new column names, and values as original column names.
#' @return inverse map
#'
#' @seealso \code{\link{let}}, \code{\link{replyr_apply_f_mapped}}, \code{\link{replyr_mapRestrictCols}}
#'
#' @examples
#'
#' mp <- c(A='x', B='y')
#' print(mp)
#' replyr_reverseMap(mp)
#'
#' @export
#'
replyr_reverseMap <- function(nmap) {
  nmap <- as.list(nmap)
  if(length(nmap)<=0) {
    return(nmap)
  }
  invmap <- names(nmap)
  names(invmap) <- as.character(nmap)
  as.list(invmap)
}


#' Map names of columns to known values and drop other columns.
#'
#' Restrict a data item's column names and re-name them in bulk.
#'
#' Something like \code{replyr::replyr_mapRestrictCols} is only useful to get control of a function that is not parameterized
#' (in the sense it has hard-coded column names inside its implementation that don't the match column names in our data).
#'
#' @seealso \code{\link{let}}, \code{\link{replyr_reverseMap}}, \code{\link{replyr_apply_f_mapped}}
#'
#' @param x data item to work on
#' @param nmap named list mapping with keys specifying new column names, and values as original column names.
#' @param ... force later arguments to bind by name
#' @param restrict logical if TRUE restrict to columns mentioned in nmap.
#' @param reverse logical if TRUE apply the inverse of nmap instead of nmap.
#' @return data item with columns renamed (and possibly restricted).
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
replyr_mapRestrictCols <- function(x, nmap,
                                   ...,
                                   restrict= FALSE,
                                   reverse= FALSE) {
  if(length(list(...))>0) {
    stop("replyr::replyr_mapRestrictCols unexpected argument")
  }
  nmap <- as.list(nmap)
  if(length(nmap)<=0) {
    return(x)
  }
  if(reverse) {
    nmap <- replyr_reverseMap(nmap)
  }
  if(length(unique(as.character(nmap)))!=length(nmap)) {
    stop("replyr::replyr_mapRestrictCols duplicate source columns (nmap values) in replyr_mapRestrictCols")
  }
  if(length(unique(names(nmap)))!=length(nmap)) {
    stop("replyr::replyr_mapRestrictCols duplicate destination columns (nmap keys) in replyr_mapRestrictCols")
  }
  # restrict down to names in x
  nmap <- nmap[as.character(nmap) %in% colnames(x)]
  if(!restrict) {
    dupMapping <- base::intersect(names(nmap), # destinations
                              setdiff(colnames(x), as.character(nmap)) # columns we are leaving in place
                              )
    if(length(dupMapping)>0) {
      stop(paste("replyr::replyr_mapRestrictCols destination columns colliding with un-restricted table columns:",
                 paste(dupMapping, collapse= ', ')))

    }
  }
  for(ni in names(nmap)) {
    if(is.null(ni)) {
      stop('replyr::replyr_mapRestrictCols nmap keys must not be null')
    }
    if(is.na(ni)) {
      stop('replyr::replyr_mapRestrictCols nmap keys must not be NA')
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
    if(is.na(ti)) {
      stop('replyr::replyr_mapRestrictCols nmap values must not be NA')
    }
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
  }
  if(restrict) {
    # limit down to only names we are mapping
    x <- dplyr::select(x, dplyr::one_of(as.character(nmap)))
  }
  # re-map names, re-factor mapping to two maps to avoid
  # name-aliasing issues
  intermediates <- tempNamesDisjointFrom(c(names(nmap), as.character(nmap)),
                                         k= length(nmap))
  map1 <- nmap
  names(map1) <- intermediates
  map2 <- intermediates
  names(map2) <- names(nmap)
  for(mi in list(map1, map2)) {
    for(ni in names(mi)) {
      ti <- mi[[ni]]
      if(ni!=ti) {
        x <- replyr_rename(x, newName= ni, oldName= ti)
      }
    }
  }
  x
}

#' Apply a function to a re-mapped data frame.
#'
#' @param d data.frame to work on
#' @param f function to apply.
#' @param nmap named list mapping with keys specifying new column names, and values as original column names.
#' @param ... force later arguments to bind by name
#' @param restrictMapIn logical if TRUE restrict columns when mapping in.
#' @param rmap reverse map (for after f is applied).
#' @param restrictMapOut logical if TRUE restrict columns when mapping out.
#'
#'
#' @seealso \code{\link{let}}, \code{\link{replyr_reverseMap}}, \code{\link{replyr_mapRestrictCols}}
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
#'
#' # map our data to expected column names so we can use function
#' nmap <- c(GroupColumn='Species',
#'           ValueColumn='Sepal_Length',
#'           RankColumn='rank')
#' print(nmap)
#'
#' dF <- replyr_apply_f_mapped(d, DecreaseRankColumnByOne, nmap)
#' print(dF)
#'
#'
#'
#' @export
replyr_apply_f_mapped <- function(d,
                                  f,
                                  nmap,
                                  ...,
                                  restrictMapIn = FALSE,
                                  rmap = replyr::replyr_reverseMap(nmap),
                                  restrictMapOut = FALSE) {
  if(length(list(...))>0) {
    stop("replyr_apply_f_mapped: unexpected arguments")
  }
  dMapped <- replyr_mapRestrictCols(d, nmap,
                                    restrict = restrictMapIn)
  dF <- f(dMapped)
  res <- replyr_mapRestrictCols(dF, rmap,
                                restrict = restrictMapOut)
  res
}
