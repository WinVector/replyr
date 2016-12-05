
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr collect copy_to arrange_
NULL


#' grouped ordered apply
#'
#' Partitions from by values in grouping column, applies a generic transform
#' to each group and then binds the groups back together.  Only advised for a
#' moderate number of groups and better if grouping column is an index.
#' This is powerfull
#' enough to implement "The Split-Apply-Combine Strategy for Data Analysis"
#' https://www.jstatsoft.org/article/view/v040i01
#'
#'
#' @param df remote dplyr data item
#' @param gcolumn grouping column
#' @param f transform function or pipleline
#' @param ... force later values to be bound by name
#' @param ocolumn ordering column (optional)
#' @param decreasing if TRUE sort in decreasing order by ocolumn
#' @param partitionMethod method to partition the data, one of 'group_by' (depends on f being dplyr compatible), 'split' (only works over local data frames), or 'extract'
#' @param bindrows if TRUE bind the rows back into a data item, else return split list
#' @param maxgroups maximum number of groups to work over (intentionally not enforced if partitionMethod=='group_by')
#' @param eagerCompute if TRUE call compute on split results
#' @return transformed frame
#'
#' @examples
#'
#' library('dplyr')
#' d <- data.frame(group=c(1,1,2,2,2),
#'                 order=c(.1,.2,.3,.4,.5),
#'                 values=c(10,20,2,4,8))
#'
#' # User supplied window functions.  They depend on known column names and
#' # the data back-end matching function names (as cumsum).
#' cumulative_sum <- . %>% arrange(order) %>% mutate(cv=cumsum(values))
#' rank_in_group <- . %>% mutate(constcol=1) %>%
#'           mutate(rank=cumsum(constcol)) %>% select(-constcol)
#'
#' for(partitionMethod in c('group_by','split','extract')) {
#'   print(partitionMethod)
#'   print('cumulative sum example')
#'   print(d %>% gapply('group',cumulative_sum,ocolumn='order',
#'                      partitionMethod=partitionMethod))
#'   print('ranking example')
#'   print(d %>% gapply('group',rank_in_group,ocolumn='order',
#'                      partitionMethod=partitionMethod))
#'   print('ranking example (decreasing)')
#'   print(d %>% gapply('group',rank_in_group,ocolumn='order',decreasing=TRUE,
#'                      partitionMethod=partitionMethod))
#' }
#'
#' @export
gapply <- function(df,gcolumn,f,
                   ...,
                   ocolumn=NULL,
                   decreasing=FALSE,
                   partitionMethod='group_by',
                   bindrows=TRUE,
                   maxgroups=100,
                   eagerCompute=FALSE) {
  if((!is.character(gcolumn))||(length(gcolumn)!=1)||(nchar(gcolumn)<1)) {
    stop('replyr::gapply gcolumn must be a single non-empty string')
  }
  if(!is.null(ocolumn)) {
    if((!is.character(ocolumn))||(length(ocolumn)!=1)||(nchar(ocolumn)<1)) {
      stop('replyr::gapply ocolumn must be a single non-empty string or NULL')
    }
  }
  if(length(list(...))>0) {
    stop('replyr::gapply unexpected arguments')
  }
  df %>% dplyr::ungroup() -> df  # make sure some other grouping isn't interfering.
  if(partitionMethod=='group_by') {
    if(!bindrows) {
      stop("replyr::gapply needs bindRows=TRUE")
    }
    # don't enforce maxgroups in this case, as large numbers of groups should not be a problem
    df %>% dplyr::group_by_(gcolumn) -> df
    if(!is.null(ocolumn)) {
      if(decreasing) {
        #df %>% dplyr::arrange_(.dots=stats::setNames(paste0('desc(',ocolumn,')'),ocolumn)) -> df
        df %>% dplyr::arrange_(interp(~desc(x),x=as.name(ocolumn))) -> df
      } else {
        df %>% dplyr::arrange_(ocolumn) -> df
      }
    }
    if(!is.null(f)) {
      df %>% f -> df
    }
    df %>% dplyr::ungroup() -> df
    return(df)
  }
  if(partitionMethod=='split') {
    # only works on local data frames
    if(!is.null(maxgroups)) {
      df %>% replyr_uniqueValues(gcolumn) %>% replyr_nrow() -> ngroups
      if(ngroups>maxgroups) {
        stop("replyr::gapply maxgroups exceeded")
      }
    }
    df %>% base::split(df[[gcolumn]]) -> res
    if(!is.null(ocolumn)) {
      if(decreasing) {
        orderer <- function(di) {
          dplyr::arrange_(di,interp(~desc(x),x=as.name(ocolumn)))
        }
      } else {
        orderer <- function(di) {
          dplyr::arrange_(di,ocolumn)
        }
      }
      res <- lapply(res,orderer)
    }
    if(!is.null(f)) {
      res <- lapply(res,f)
    }
    if(bindrows) {
      res <- replyr_bind_rows(res)
    }
    return(res)
  }
  if(partitionMethod=='extract') {
    df %>% replyr_uniqueValues(gcolumn) %>%
      replyr_copy_from(maxrow=maxgroups) -> groups
    res <- lapply(groups[[gcolumn]],
                  function(gi) {
                    df %>% replyr_filter(cname=gcolumn,values=gi,verbose=FALSE) -> gsubi
                    if(!is.null(ocolumn)) {
                      if(decreasing) {
                        #gsubi %>% dplyr::arrange_(.dots=stats::setNames(paste0('desc(',ocolumn,')'),ocolumn)) -> gsubi
                        gsubi %>% dplyr::arrange_(interp(~desc(x),x=as.name(ocolumn))) -> gsubi
                      } else {
                        gsubi %>% dplyr::arrange_(ocolumn) -> gsubi
                      }
                    }
                    if(!is.null(f)) {
                      gsubi <- f(gsubi)
                    }
                    if(eagerCompute) {
                      gsubi <- dplyr::compute(gsubi) # this may lose ordering, see issues/arrangecompute.Rmd
                    }
                    gsubi
                  })
    names(res) <- as.character(groups[[gcolumn]])
    if(bindrows) {
      res <- replyr_bind_rows(res)
    }
    return(res)
  }
  stop(paste("replyr::gapply unknown partitionMethod argument:",partitionMethod))
}


#' split a data item by values in a column.
#'
#' Partitions from by values in grouping column, and returns list.  Only advised for a
#' moderate number of groups and better if grouping column is an index.
#' This plus lapply and replyr::bind_rows is powerfull
#' enough to implement "The Split-Apply-Combine Strategy for Data Analysis"
#' https://www.jstatsoft.org/article/view/v040i01
#'
#'
#' @param df remote dplyr data item
#' @param gcolumn grouping column
#' @param ... force later values to be bound by name
#' @param ocolumn ordering column (optional)
#' @param decreasing if TRUE sort in decreasing order by ocolumn
#' @param partitionMethod method to partition the data, one of 'split' (only works over local data frames), or 'extract'
#' @param maxgroups maximum number of groups to work over
#' @param eagerCompute if TRUE call compute on split results
#' @return list of data items
#'
#' @examples
#'
#' library('dplyr')
#' d <- data.frame(group=c(1,1,2,2,2),
#'                 order=c(.1,.2,.3,.4,.5),
#'                 values=c(10,20,2,4,8))
#' d %>% replyr_split('group')
#'
#' @export
replyr_split <- function(df,gcolumn,
                         ...,
                         ocolumn=NULL,
                         decreasing=FALSE,
                         partitionMethod='extract',
                         maxgroups=100,
                         eagerCompute=FALSE) {
  if(!(partitionMethod %in% c('split','extract'))) {
    stop('replyr::replyr_split partitionMethod must be split or extract')
  }
  if(length(list(...))>0) {
    stop('replyr::replyr_split unexpected arguments')
  }
  gapply(df,gcolumn,f=NULL,ocolumn=ocolumn,
         decreasing=decreasing,bindrows=FALSE,
         partitionMethod=partitionMethod,
         maxgroups=maxgroups,eagerCompute=eagerCompute)
}
