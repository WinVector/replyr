
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' return a cannonical name of the data service hosting a given data object
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
  expectedNames=c('src_sqlite','spark_connection','src_spark', 'src_mysql', 'src_postgres')) {
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