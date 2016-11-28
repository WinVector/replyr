
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr collect copy_to
NULL

# rbind a bunch of items together
replyr_bind_rows <- function(lst) {
  n <- length(lst)
  if(n<=0) {
    return(NULL)
  }
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

#' grouped apply
#'
#' Partitions from by values in grouping column, applies a generic transform
#' to each group and then binds the groups back together.  This is powerfull
#' enough to implement "The Split-Apply-Combine Strategy for Data Analysis"
#' https://www.jstatsoft.org/article/view/v040i01
#'
#'
#' @param df remote dplyr data item
#' @param gcolumn grouping column
#' @param f transform function
#' @param ocolumn ordering column (optional)
#' @param ... force later values to be bound by name
#' @param maxgroups maximum number of groups to work over
#' @return transformed frame
#'
#' @examples
#'
#' library('dplyr')
#' d <- data.frame(group=c(1,1,2,2,2),
#'                 order=c(1,2,3,4,5),
#'                 values=c(10,20,2,4,8))
#'
#' cumulative_sum <- function(dg) {
#'   dg %>% mutate(cv=cumsum(values))
#' }
#'
#' sumgroup <- function(dg) {
#'   dg %>% summarize(group=min(group), # pseudo aggregation, group constant
#'                    minv=min(values),maxv=max(values))
#' }
#'
#' d %>% replyr_gapply('group',cumulative_sum,'order')
#' d %>% replyr_gapply('group',sumgroup)
#'
#' # # below only works for services which have a cumsum operator
#' # my_db <- dplyr::src_postgres(host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
#' # dR <- replyr_copy_to(my_db,d,'dR')
#' # dR %>% replyr_gapply('group',cumulative_sum,'order')
#' # dR %>% replyr_gapply('group',sumgroup)
#'
#' @export
replyr_gapply <- function(df,gcolumn,f,ocolumn=NULL,
                          ...,
                          maxgroups=1000) {
  if((!is.character(gcolumn))||(length(gcolumn)!=1)||(nchar(gcolumn)<1)) {
    stop('replyr_gapply gcolumn must be a single non-empty string')
  }
  if(!is.null(ocolumn)) {
    if((!is.character(ocolumn))||(length(ocolumn)!=1)||(nchar(ocolumn)<1)) {
      stop('replyr_gapply ocolumn must be a single non-empty string or NULL')
    }
  }
  if(length(list(...))>0) {
    stop('replyr_gapply unexpected arguments')
  }
  df %>% replyr_uniqueValues(gcolumn) %>%
    replyr_copy_from(maxrow=maxgroups) -> groups
  reslist <- lapply(groups[[gcolumn]],
                    function(gi) {
                      df %>% replyr_filter(cname=gcolumn,values=gi,verbose=FALSE) -> gsubi
                      if(!is.null(ocolumn)) {
                        gsubi %>% arrange_(ocolumn) -> gsubi
                      }
                      f(gsubi)
                    })
  reslist <- Filter(function(ri) { replyr_nrow(ri)>0 },reslist)
  replyr_bind_rows(reslist)
}
