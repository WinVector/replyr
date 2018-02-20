
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

# confirm x is a good ranked sub-group
# x <- data.frame(Sepal_Length=c(5.8,5.7),Sepal_Width=c(4.0,4.4),
#                 Species='setosa',rank=c(1,2))
# replyr_ranksummaries(x,'Species','Sepal_Length','rank',TRUE)
replyr_ranksummaries <- function(x,
                                 GroupColumnName,ValueColumnName,RankColumnName,
                                 decreasing=FALSE) {
  # let strategy
  RankColumn <- NULL # false binding for 'RankColumn' so name does not look unbound to CRAN check
  GroupColumn <- NULL # false binding for 'GroupColumn' so name does not look unbound to CRAN check
  ValueColumn <- NULL # false binding for 'ValueColumn' so name does not look unbound to CRAN check
  ValueColumn_n <- NULL # false binding for 'ValueColumn_n' so name does not look unbound to CRAN check
  # do note so bind 'RankColumn_n' as we don't intend to use tha variable, so seeing it unbound is a useful warning
  x <- dplyr::select(x,dplyr::one_of(c(GroupColumnName,ValueColumnName,RankColumnName)))
  nmap <-  c(GroupColumnName,ValueColumnName,RankColumnName,
             paste(ValueColumnName,'n',sep='_'),paste(RankColumnName,'n',sep='_'))
  names(nmap) <- c('GroupColumn','ValueColumn','RankColumn',
                   'ValueColumn_n','RankColumn_n')
  let(
    alias=nmap,
    expr={
      # do the work
      n <- replyr::replyr_nrow(x)
      x %.>%
        dplyr::filter(., !(RankColumn %in% 1:n)) %.>%
        replyr::replyr_nrow(.) -> nBadRanks
      x %.>%
        replyr::replyr_uniqueValues(., RankColumnName) %.>%
        replyr::replyr_nrow(.) -> nUniqueRanks
      # had problems with head(n=1) on sparklyr
      # https://github.com/WinVector/replyr/blob/master/issues/HeadIssue.md
      x %.>%
        replyr::replyr_uniqueValues(., GroupColumnName) %.>%
        head(.) %.>%
        replyr::replyr_copy_from(.) %.>%
        head(., n=1) -> tmp
      groupID <- tmp$GroupColumn[[1]]
      x %.>%
        replyr::replyr_uniqueValues(., GroupColumnName) %.>%
        replyr::replyr_nrow(.) -> nGroups
      # work around sparklyr Spark 1.6.2 join issue by minimizing and renaming columns
      # https://github.com/rstudio/sparklyr/issues/338
      x %.>% dplyr::select(., -GroupColumn) -> x
      x %.>%
        dplyr::mutate(., RankColumn=RankColumn+1) %.>%
        dplyr::rename(., RankColumn_n=RankColumn) %.>%
        dplyr::rename(., ValueColumn_n=ValueColumn) -> xNext
      # "by" notation from http://stackoverflow.com/questions/21888910/how-to-specify-names-of-columns-for-x-and-y-when-joining-in-dplyr
      byClause <- paste(RankColumnName,'n',sep='_')
      names(byClause) <- RankColumnName
      # this join does not work with Spark 1.6.2 due to "duplicate columns"
      dplyr::inner_join(x,xNext,byClause) -> xJ
      if(decreasing) {
        xJ %.>%
          dplyr::filter(., ValueColumn_n<ValueColumn) %.>%
          replyr::replyr_nrow(.) -> nBadOrders
      } else {
        xJ %.>%
          dplyr::filter(., ValueColumn_n>ValueColumn) %.>%
          replyr::replyr_nrow(.) -> nBadOrders
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
    }) -> res
  res
}

#' confirm data has good ranked groups
#'
#' @param x data item to work with
#' @param GroupColumnName column to group by
#' @param ValueColumnName column determining order
#' @param RankColumnName column having proposed rank (function of order)
#' @param ... force later arguments to bind by name
#' @param tempNameGenerator temp name generator produced by wrapr::mk_tmp_name_source, used to record dplyr::compute() effects.
#' @param decreasing if true make order decreasing instead of increasing.
#' @return summary of quality of ranking.
#'
#' @examples
#'
#' d <- data.frame(Sepal_Length=c(5.8,5.7),Sepal_Width=c(4.0,4.4),
#'                 Species='setosa',rank=c(1,2))
#' replyr_check_ranks(d,'Species','Sepal_Length','rank',  decreasing=TRUE)
#'
#' @export
replyr_check_ranks <- function(x,
                               GroupColumnName,ValueColumnName,RankColumnName,
                               ...,
                               decreasing= FALSE,
                               tempNameGenerator= mk_tmp_name_source("replyr_check_ranks")) {
  if(length(list(...))>0) {
    stop("replyr::replyr_check_ranks unexpected arguments.")
  }
  f <- function(xi) {  replyr_ranksummaries(xi,
                                            GroupColumnName=GroupColumnName,
                                            ValueColumnName=ValueColumnName,
                                            RankColumnName=RankColumnName,
                                            decreasing=decreasing) }
  gapply(x,GroupColumnName,f,partitionMethod='extract',
         maxgroups=NULL,
         tempNameGenerator=tempNameGenerator)
}

