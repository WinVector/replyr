
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' Return a cannonical name of the data service hosting a given data object.
#'
#'
#' @param df data object
#' @param expectedNames some names to canonicalize to.
#' @return cannonical service name (lenght 1 character array)
#'
#' @examples
#'
#' replyr_dataServiceName(data.frame(x=1))
#' replyr_dataServiceName(dplyr::as.tbl(data.frame(x=1)))
#'
#' @export
replyr_dataServiceName <- function(df,
  expectedNames=c('src_sqlite','spark_connection','src_spark',
                  'src_mysql', 'src_postgres')) {
  cls <- class(df)
  if(length(cls)<=1) {
    return(cls)  # "data.frame" case
  }
  if(('tbl' %in% cls) && all(cls %in% c("data.frame","tbl","tbl_df"))) {
    return("tbl")
  }
  srvcls <- sort(class(df$src))
  if(is.null(srvcls)) {
    # give up
    return(paste(sort(cls),collapse=' '))
  }
  for(m in expectedNames) {
    if(m %in% srvcls) {
      return(m)
    }
  }
  # give up
  return(paste(sort(srvcls),collapse=' '))
}

#' Get the "remote data source" where a data.frame like object lives.
#'
#' NOT TESTED YET!
#'
#' @param df data.frame style object
#' @return source (string if data.frame, tlb, or data.table, NULL if unknown, remote source otherwise)
#'
#' @examples
#'
#' replyr_get_src(data.frame(x=1:2))
#'
#' @export
replyr_get_src <- function(df) {
  cls <- class(df)
  if((length(cls)<=1) && ('data.frame' %in% cls)) {
    return('data.frame')
  }
  if(all(cls %in% c('tbl', 'tbl_df', 'data.frame'))) {
    return("tbl")
  }
  if(all(cls %in% c('data.table', 'data.frame'))) {
    return("data.table")
  }
  if(any(c('tbl_spark') %in% cls)) {
    if(requireNamespace('sparklyr', quietly = TRUE)) {
      sc <- sparklyr::spark_connection(df)
      if(!is.null(sc)) {
        return(sc)
      }
    }
  }
  # fall back to common slots
  if('src' %in% names(df)) {
    return(df$src)
  }
  # unknown
  return(NULL)
}
