
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.


#' Obsolete with dplyr 0.7.0 and forward
#'
#' @param dplyr_src remote data handle
#' @return dplyr_src
#'
#'
#' @export
#'
dplyr_src_to_db_handle <- function(dplyr_src) {
  return(dplyr_src)
}


#' list tables
#'
#' Work around connection v.s. handle issues \url{https://github.com/tidyverse/dplyr/issues/2849}
#'
#'
#' @param con connection
#' @return list of tables names
#'
#'
#' @examples
#'
#' if (requireNamespace("RSQLite", quietly = TRUE)) {
#'    my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#'    RSQLite::initExtension(my_db)
#'   d <- replyr_copy_to(my_db, data.frame(x=c(1,2)), 'd',
#'                       overwrite=TRUE, temporary=TRUE)
#'   print(d)
#'   print(replyr_list_tables(my_db))
#'   DBI::dbDisconnect(my_db)
#' }
#'
#' @export
#'
replyr_list_tables <- function(con) {
  cn <- dplyr_src_to_db_handle(con)
  dplyr::db_list_tables(cn)
}

#' check for a table
#'
#' Work around connection v.s. handle issues \url{https://github.com/tidyverse/dplyr/issues/2849}
#'
#' @param con connection
#' @param name character name to check for
#' @return TRUE if table present
#'
#'
#' @examples
#'
#' if (requireNamespace("RSQLite", quietly = TRUE)) {
#'   my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#'   RSQLite::initExtension(my_db)
#'   d <- replyr_copy_to(my_db, data.frame(x=c(1,2)), 'd')
#'   print(d)
#'   print(replyr_has_table(my_db, 'd'))
#'   DBI::dbDisconnect(my_db)
#' }
#'
#' @export
#'
replyr_has_table <- function(con, name) {
  cn <- dplyr_src_to_db_handle(con)
  dplyr::db_has_table(cn, name)
}

#' Get the "remote data source" where a data.frame like object lives.
#'
#'
#' @param df data.frame style object
#' @return source (string if data.frame, tbl, or data.table, NULL if unknown, remote source otherwise)
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
    if('con' %in% names(df$src)) {
      return(df$src$con)
    }
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
  if(is.null(d)) {
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
  if(is.null(d)) {
    return(FALSE)
  }
  sc <- replyr_get_src(d)
  if(is.null(sc) || is.character(sc)) {
    return(FALSE)
  }
  if(length(grep('spark_', tolower(class(sc))))>0) {
    return(TRUE)
  }
  if('con' %in% names(sc)) {
    if(length(grep('spark_', tolower(class(sc$con))))>0) {
      return(TRUE)
    }
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
  if(is.null(d)) {
    return(FALSE)
  }
  sc <- replyr_get_src(d)
  if(is.null(sc) || is.character(sc)) {
    return(FALSE)
  }
  if(length(grep('mysql', tolower(class(sc))))>0) {
    return(TRUE)
  }
  if('con' %in% names(sc)) {
    if(length(grep('mysql', tolower(class(sc$con))))>0) {
      return(TRUE)
    }
  }
  return(FALSE)
}

