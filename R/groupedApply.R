
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr collect
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
#'
#' Note this is a fairly expensive operator, so it only makes sense to use
#' in situations where \code{f} itself is fairly complicated and/or expensive.
#'
#'
#' @param df remote dplyr data item
#' @param gcolumn grouping column
#' @param f transform function or pipleline
#' @param ... force later values to be bound by name
#' @param ocolumn ordering column (optional)
#' @param decreasing logical, if TRUE sort in decreasing order by ocolumn
#' @param partitionMethod method to partition the data, one of 'group_by' (depends on f being dplyr compatible), 'split' (only works over local data frames), or 'extract'
#' @param bindrows logical, if TRUE bind the rows back into a data item, else return split list
#' @param maxgroups maximum number of groups to work over (intentionally not enforced if \code{partitionMethod=='group_by'})
#' @param eagerCompute logical, if TRUE call compute on split results
#' @param restoreGroup logical, if TRUE restore group column after apply when \code{partitionMethod \%in\% c('extract', 'split')}
#' @param tempNameGenerator temp name generator produced by \code{cdata::makeTempNameGenerator}, used to record \code{dplyr::compute()} effects.
#' @return transformed frame
#'
#' @examples
#'
#' d <- data.frame(
#'   group = c(1, 1, 2, 2, 2),
#'   order = c(.1, .2, .3, .4, .5),
#'   values = c(10, 20, 2, 4, 8)
#' )
#'
#' # User supplied window functions.  They depend on known column names and
#' # the data back-end matching function names (as cumsum).
#' cumulative_sum <- function(d) {
#'   dplyr::mutate(d, cv = cumsum(values))
#' }
#' rank_in_group <- function(d) {
#'   d %.>%
#'     dplyr::mutate(., constcol = 1) %.>%
#'     dplyr::mutate(., rank = cumsum(constcol)) %.>%
#'     dplyr::select(., -constcol)
#' }
#'
#' for (partitionMethod in c('group_by', 'split', 'extract')) {
#'   print(partitionMethod)
#'   print('cumulative sum example')
#'   print(
#'     gapply(
#'       d,
#'       'group',
#'       cumulative_sum,
#'       ocolumn = 'order',
#'       partitionMethod = partitionMethod
#'     )
#'   )
#'   print('ranking example')
#'   print(
#'     gapply(
#'       d,
#'       'group',
#'       rank_in_group,
#'       ocolumn = 'order',
#'       partitionMethod = partitionMethod
#'     )
#'   )
#'   print('ranking example (decreasing)')
#'   print(
#'     gapply(
#'       d,
#'       'group',
#'       rank_in_group,
#'       ocolumn = 'order',
#'       decreasing = TRUE,
#'       partitionMethod = partitionMethod
#'     )
#'   )
#' }
#'
#' @export
gapply <- function(df,gcolumn,f,
                   ...,
                   ocolumn=NULL,
                   decreasing=FALSE,
                   partitionMethod='split',
                   bindrows=TRUE,
                   maxgroups=100,
                   eagerCompute=FALSE,
                   restoreGroup=FALSE,
                   tempNameGenerator= makeTempNameGenerator("replyr_gapply")) {
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
  df %.>%
    dplyr::ungroup(.) -> df  # make sure some other grouping isn't interfering.
  if(partitionMethod=='group_by') {
    if(!bindrows) {
      stop("replyr::gapply needs bindRows=TRUE")
    }
    # don't enforce maxgroups in this case, as large numbers of groups should not be a problem
    df %.>%
      replyr_group_by(., gcolumn) -> df
    if(!is.null(ocolumn)) {
      df <- replyr_arrange(df,ocolumn,decreasing)
    }
    if(!is.null(f)) {
      df %.>% f(.) -> df
    }
    df %.>% dplyr::ungroup(.) -> df
    return(df)
  }
  if(partitionMethod=='split') {
    if(!replyr_is_local_data(df)) {
      stop("replyr::gapply(partitionMethod='split') can only be used on local data frames")
    }
    # only works on local data frames
    if(!is.null(maxgroups)) {
      df %.>%
        replyr_uniqueValues(., gcolumn) %.>%
        replyr_nrow(.) -> ngroups
      if(ngroups>maxgroups) {
        stop("replyr::gapply maxgroups exceeded")
      }
    }
    base::split(df, df[[gcolumn]]) -> res
    if(!is.null(ocolumn)) {
      orderer <- function(di) {
        replyr_arrange(di,ocolumn,decreasing)
      }
      res <- lapply(res,orderer)
    }
    if(!is.null(f)) {
      res <- lapply(res,f)
    }
    if(restoreGroup) {
      res <- lapply(names(res),
                    function(gi) {
                      ri <- res[[gi]]
                      res[[gi]] <- wrapr::let(
                        c(GROUPCOL=gcolumn),
                        dplyr::mutate(ri, GROUPCOL=gi)
                      )
                    }
      )
    }
    if(bindrows) {
      res <- replyr_bind_rows(res,
                              tempNameGenerator=tempNameGenerator)
    }
    return(res)
  }
  if(partitionMethod=='extract') {
    df %.>%
      replyr_uniqueValues(., gcolumn) %.>%
      replyr_copy_from(., maxrow=maxgroups) -> groups
    res <- lapply(groups[[gcolumn]],
                  function(gi) {
                    df %.>% replyr_filter(., cname=gcolumn,values=gi,
                                         verbose=FALSE,
                                         tempNameGenerator=tempNameGenerator) -> gsubi
                    if(!is.null(ocolumn)) {
                      gsubi <- replyr_arrange(gsubi,ocolumn,decreasing)
                    }
                    if(!is.null(f)) {
                      gsubi <- f(gsubi)
                    }
                    if(restoreGroup) {
                      wrapr::let(
                        c(GROUPCOL=gcolumn),
                        gsubi <- dplyr::mutate(gsubi, GROUPCOL=gi)
                      )
                    }
                    if(eagerCompute) {
                      gsubi <- dplyr::compute(gsubi,
                                              name= tempNameGenerator()) # this may lose ordering, see issues/arrangecompute.Rmd
                    }
                    gsubi
                  })
    names(res) <- as.character(groups[[gcolumn]])
    if(bindrows) {
      res <- replyr_bind_rows(res,
                              tempNameGenerator=tempNameGenerator)
    }
    return(res)
  }
  stop(paste("replyr::gapply unknown partitionMethod argument:",partitionMethod))
}


#' split a data item by values in a column.
#'
#' Partitions from by values in grouping column, and returns list.  Only advised for a
#' moderate number of groups and better if grouping column is an index.
#' This plus lapply and replyr::bind_rows is powerful
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
#' d <- data.frame(group=c(1,1,2,2,2),
#'                 order=c(.1,.2,.3,.4,.5),
#'                 values=c(10,20,2,4,8))
#' dSplit <- replyr_split(d, 'group', partitionMethod='extract')
#' dApp <- lapply(dSplit, function(di) data.frame(as.list(colMeans(di))))
#' replyr_bind_rows(dApp)
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
