
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr %>% ungroup select_ mutate group_by_ summarize tbl as.tbl compute inner_join
NULL

#' Filter a tbl on a column having values in a given set.
#'
#' Note: if temp tables can't be used a regular table is created and destroyed (which may not be safe if there is another replyr_filter running at the same time).
#'
#' @param x tbl or item that can be coerced into such.
#' @param cname name of the column to test values of.
#' @param values set of values to check set membership of.
#' @param verbose logical if TRUE echo warnings
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
replyr_filter <- function(x,cname,values,verbose=TRUE) {
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
  # dplyr::*_join(jtab,by=cname,copy=TRUE) has been bombing out with:
  #   "CREATE TEMPORARY TABLE is not supported" (spark 2.0.0, hadoop 2.7)
  #   spark 1.6.2 can't join tables with matching names (even as the join condition).
  # dplyr 0.5.0, sparklyr 0.4, so need to work around.
  # Try it the right way first (this way works well on good stacks).
  res <- NULL
  good <- FALSE
  tryCatch({
    x %>% dplyr::inner_join(jtab,by=byClause,copy=TRUE) %>%
      dplyr::compute() -> res;
    good <- TRUE},
    error = function(x) {
      if(verbose) {
        warning(paste("[replyr::replyr_filter working around]",x))
      }
      NULL }
  )
  # Try to fix it.
  if((!good) && ('tbl_spark' %in% class(x))) {
    cn <- x$src$con
    tmpnam <- paste('replyr_filter_tmp',sample.int(1000000000,1),sep='_')
    tmp <- replyr_copy_to(cn,jtab,tmpnam)
    x %>% dplyr::inner_join(tmp,by=byClause) %>%
      dplyr::compute() -> res
    dplyr::db_drop_table(cn,tmpnam)
  }
  res
}
