
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.


#' Get the "remote data source" where a data.frame like object lives.
#'
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

#' Test if data is local.
#'
#' @param d data frame
#' @return TRUE if local data (data.frame, tbl/tibble)
#'
#' @examples
#'
#' replyr_is_local_data(data.frame(x=1:3))
#'
#' @export
replyr_is_local_data <- function(d) {
  if("NULL" %in% class(d)) {
    return(TRUE)
  }
  sc <- replyr_get_src(d)
  if(is.null(sc) || is.character(sc)) {
    return(TRUE)
  }
  return(FALSE)
}

#' Test if data is Spark.
#'
#' @param d data frame
#' @return TRUE if Spark data
#'
#' @examples
#'
#' replyr_is_Spark_data(data.frame(x=1:3))
#'
#' @export
replyr_is_Spark_data <- function(d) {
  if("NULL" %in% class(d)) {
    return(FALSE)
  }
  sc <- replyr_get_src(d)
  if(is.null(sc) || is.character(sc)) {
    return(FALSE)
  }
  if(length(grep('spark_', tolower(class(sc$con))))>0) {
    return(TRUE)
  }
  if(length(grep('spark_', tolower(class(sc))))>0) {
    return(TRUE)
  }
  return(FALSE)
}

#' Test if data is MySQL.
#'
#' @param d data frame
#' @return TRUE if Spark data
#'
#' @examples
#'
#' replyr_is_MySQL_data(data.frame(x=1:3))
#'
#' @export
replyr_is_MySQL_data <- function(d) {
  if("NULL" %in% class(d)) {
    return(FALSE)
  }
  sc <- replyr_get_src(d)
  if(is.null(sc) || is.character(sc)) {
    return(FALSE)
  }
  if(length(grep('mysql', tolower(class(sc$con))))>0) {
    return(TRUE)
  }
  if(length(grep('mysql', tolower(class(sc))))>0) {
    return(TRUE)
  }
  return(FALSE)
}

