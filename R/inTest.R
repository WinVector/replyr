
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr ungroup mutate summarize tbl as.tbl compute left_join
NULL

#' Product a column noting if another columns values are in a given set.
#'
#'
#' @param x tbl or item that can be coerced into such.
#' @param cname name of the column to test values of.
#' @param values set of values to check set membership of.
#' @param nname name for new column
#' @param ... force later parameters to bind by name
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @param verbose logical if TRUE echo warnings
#' @return table with membership indications.
#'
#' @examples
#'
#' values <- c('a','c')
#' d <- data.frame(x=c('a','a','b',NA,'c','c'),y=1:6,
#'                 stringsAsFactors=FALSE)
#' replyr_inTest(d,'x',values,'match')
#'
#' @export
replyr_inTest <- function(x,cname,values,nname,
                          ...,
                          tempNameGenerator= makeTempNameGenerator("replyr_inTest"),
                          verbose=TRUE) {
  if(length(list(...))>0) {
    stop("replyr::replyr_inTest unexpected arguments.")
  }
  if((!is.character(cname))||(length(cname)!=1)||(cname[[1]]=='n')) {
    stop('replyr_inTest cname must be a single string not equal to "n"')
  }
  if((!is.character(nname))||(length(nname)!=1)||(nname[[1]]=='n')) {
    stop('replyr_inTest nname must be a single string not equal to "n"')
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
  vtbl[[nname]] <- TRUE
  jtab <- dplyr::as.tbl(vtbl)
  if(!replyr_is_local_data(x)) {
    cn <- replyr_get_src(x)
    jtab <- replyr_copy_to(cn, jtab,
                           tempNameGenerator(),
                           temporary = TRUE)
  }
  # dplyr::*_join(jtab,by=cname,copy=TRUE) has been bombing out with:
  #   "CREATE TEMPORARY TABLE is not supported" (spark 2.0.0, hadoop 2.7)
  #   spark 1.6.2 can't join tables with matching names (even as the join condition).
  # dplyr 0.5.0, sparklyr 0.4, so need to work around.
  # Try it the right way first (this way works well on good stacks).
  res <- NULL
  good <- FALSE
  x %>% dplyr::left_join(jtab,by=byClause) %>%
    dplyr::compute(name= tempNameGenerator()) -> res
  # replace NA with false
  RCOL <- NULL # declare no external binding
  let(
    list(RCOL=nname),
    res %>% dplyr::mutate(RCOL=!is.na(RCOL)) -> res
  )
  res
}
