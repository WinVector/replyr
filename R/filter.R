
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr ungroup mutate summarize tbl as.tbl compute inner_join
NULL

#' Filter a tbl on a column having values in a given set.
#'
#'
#' @param x tbl or item that can be coerced into such.
#' @param cname name of the column to test values of.
#' @param values set of values to check set membership of.
#' @param ... force later arguments to bind by name.
#' @param verbose logical if TRUE echo warnings
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return new tbl with only rows where cname value is in values set.
#'
#' @examples
#'
#' values <- c('a','c')
#' d <- data.frame(x=c('a','a','b','b','c','c'),y=1:6,
#'                 stringsAsFactors=FALSE)
#' replyr_filter(d,'x',values)
#'
#' @export
replyr_filter <- function(x,cname,values,
                          ...,
                          verbose=TRUE,
                          tempNameGenerator= makeTempNameGenerator("replyr_filter")) {
  if(length(list(...))>0) {
    stop("replyr::replyr_filter unexpected arguments.")
  }
  if((!is.character(cname))||(length(cname)!=1)||(cname[[1]]=='n')) {
    stop('replyr_filter cname must be a single string not equal to "n"')
  }
  vtbl <- data.frame(x=unique(values),stringsAsFactors=FALSE)
  # Spark 1.6.2 doesn't like same column names accross joins, even
  # in the by clause from dplyr.  So build a new column name.
  # "by" notation from http://stackoverflow.com/questions/21888910/how-to-specify-names-of-columns-for-x-and-y-when-joining-in-dplyr
  newname <- make.names(c(colnames(x),paste('y',cname,sep='_')),unique = TRUE)
  newname <- newname[length(newname)]
  byClause <- newname
  names(byClause) <- cname
  colnames(vtbl) <- newname
  jtab <- dplyr::as.tbl(vtbl)
  if(!replyr_is_local_data(x)) {
    cn <- replyr_get_src(x)
    jtab <- replyr_copy_to(cn, jtab, tempNameGenerator(),
                           temporary = TRUE)
  }
  # dplyr::*_join(jtab,by=cname,copy=TRUE) has been bombing out with:
  #   "CREATE TEMPORARY TABLE is not supported" (spark 2.0.0, hadoop 2.7)
  #   spark 1.6.2 can't join tables with matching names (even as the join condition).
  # which is why we copy first
  res <- NULL
  x %.>%
    dplyr::inner_join(.,jtab, by=byClause) %.>%
    dplyr::compute(., name= tempNameGenerator()) -> res
  res
}
