
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
  do.call(dplyr::select_,c(list(x),as.list(names(nmap)))) -> x
  # re-map names
  for(ni in names(nmap)) {
    ti <- nmap[[ni]]
    if(ti!=ni) {
      x %>% dplyr::mutate_(.dots=stats::setNames(ni,ti)) %>%
        dplyr::select_(paste0('-',ni)) -> x
    }
  }
  x
}

# confirm x is a good ranked sub-group
replyr_ranksummaries <- function(x,
                                 GroupColumnName,ValueColumnName,RankColumnName,
                                 decreasing=FALSE) {
  nmap <- c('GroupColumn','ValueColumn','RankColumn')
  names(nmap) <-  c(GroupColumnName,ValueColumnName,RankColumnName)
  x <- replyr_renameRestrictCols(x,nmap)
  # do the work
  n <- replyr::replyr_nrow(x)
  x %>% dplyr::filter(!(RankColumn %in% 1:n)) %>%
    replyr::replyr_nrow() -> nBadRanks
  x %>% replyr::replyr_uniqueValues('RankColumn') %>%
    replyr::replyr_nrow() -> nUniqueRanks
  x %>% replyr::replyr_uniqueValues('GroupColumn') %>%
    head(n=1) %>% replyr::replyr_copy_from() -> tmp
  groupID <- tmp$GroupColumn[[1]]
  x %>% replyr::replyr_uniqueValues('GroupColumn') %>%
    replyr::replyr_nrow() -> nGroups
  x %>% mutate(RankColumn=RankColumn+1) -> xNext
  # this join does not work with Spark 1.6.2 due to "duplicate columns"
  dplyr::inner_join(x,xNext,'RankColumn',suffix = c("_x", "_y")) -> xJ
  if(decreasing) {
    xJ %>% dplyr::filter(ValueColumn_y<ValueColumn_x) %>%
      replyr::replyr_nrow() -> nBadOrders
  } else {
    xJ %>% dplyr::filter(ValueColumn_y>ValueColumn_x) %>%
      replyr::replyr_nrow() -> nBadOrders
  }
  goodRankedGroup <- (nUniqueRanks==n)&&(nUniqueRanks==n)&&
    (nBadRanks==0)&&(nBadOrders==0)&&(nGroups==1)
  data.frame(goodRankedGroup=goodRankedGroup,
             groupID=groupID,
             nRows=n,
             nGroups=nGroups,
             nBadRanks=nBadRanks,
             nUniqueRanks=nUniqueRanks,
             nBadOrders=nBadOrders,
             stringsAsFactors = FALSE)
}

#' confirm data has good ranked groups
#'
#' Does not work with Spark 1.6.2 due to sparklyr join issue.  Does work with Spark 2.0.0.
#'
#' @param x data item to work with
#' @param GroupColumnName column to group by
#' @param ValueColumnName column determining order
#' @param RankColumnName column having proposed rank (function of order)
#' @param decreasing if true make order decreasing instead of increasing.
#' @return summary of quality of ranking.
#'
#' @examples
#'
#' d <- data.frame(Sepal_Length=c(5.8,5.7),Sepal_Width=c(4.0,4.4),
#'                 Species='setosa',rank=c(1,2))
#' replyr_check_ranks(d,'Species','Sepal_Length','rank',TRUE)
#'
#' @export
replyr_check_ranks <- function(x,
                               GroupColumnName,ValueColumnName,RankColumnName,
                               decreasing=FALSE) {
  f <- function(xi) {  replyr_ranksummaries(xi,
                                            GroupColumnName=GroupColumnName,
                                            ValueColumnName=ValueColumnName,
                                            RankColumnName=RankColumnName,
                                            decreasing=decreasing) }
  replyr_gapply(x,GroupColumnName,f,usegroups=FALSE,maxgroups=NULL)
}

