
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

# confirm x is a good ranked sub-group
replyr_ranksummaries <- function(x,
                                 GroupColumnName,ValueColumnName,RankColumnName,
                                 decreasing=FALSE) {
  # # renaming strategy
  # nmap <- c('GroupColumn','ValueColumn','RankColumn')
  # names(nmap) <-  c(GroupColumnName,ValueColumnName,RankColumnName)
  # x <- replyr_renameRestrictCols(x,nmap)

  # let strategy
  nmap <-  c(GroupColumnName,ValueColumnName,
             paste(ValueColumnName,'x',sep='_'),paste(ValueColumnName,'y',sep='_'),
             RankColumnName)
  names(nmap) <- c('GroupColumn','ValueColumn',
                   'ValueColumn_x','ValueColumn_y',
                   'RankColumn')
  let(
    alias=nmap,
    expr={
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
    })() -> res
  res
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

