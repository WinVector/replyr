
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr collect copy_to db_drop_table
NULL


# get the db handle from a dplyr src
# Spark2 handles are DBIConnection s
# SQLite are not
dplyr_src_to_db_handle <- function(dplyr_src) {
  if("DBIConnection" %in% class(dplyr_src)) {
    return(dplyr_src)
  }
  return(dplyr_src$con)
}

#' Drop a table from a source
#'
#' @param dest remote data source
#' @param name name of table to drop
#' @return logical TRUE if table was present
#'
#' @examples
#'
#' if (requireNamespace("RSQLite", quietly = TRUE)) {
#'   my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
#'   d <- replyr_copy_to(my_db, data.frame(x=c(1,2)), 'd')
#'   print(d)
#'   dplyr::db_list_tables(my_db$con)
#'   replyr_drop_table_name(my_db, 'd')
#'   dplyr::db_list_tables(my_db$con)
#' }
#'
#' @export
#'
replyr_drop_table_name <- function(dest, name) {
  if((!is.character(name))||(length(name)!=1)||(nchar(name)<1)) {
    stop('replyr::replyr_drop_table_name name must be a single non-empty string')
  }
  force(dest)
  if("NULL" %in% class(dest)) {
    # special "no destination" case
    return(FALSE)
  }
  if('tbl' %in% class(dest)) {
    # dest was actually another data object, get its source
    dest <- dest$src
    if("NULL" %in% class(dest)) {
      stop("replyr::replyr_drop_table_name unexpected dest")
    }
  }
  # MySQL doesn't seem to always obey overwrite=TRUE
  # not filing this as MySQL isn't a preferred back end.
  found = FALSE
  tryCatch({
    cn <- dplyr_src_to_db_handle(dest)
    if(!("NULL" %in% class(cn))) {
      if(name %in% dplyr::db_list_tables(cn)) {
        found = TRUE
        dplyr::db_drop_table(cn, name)
      }
    }},
    error=function(x) { warning(x); NULL }
  )
  found
}


#' Copy data to remote service.
#'
#' @param dest	remote data source
#' @param df	local data frame
#' @param name name for new remote table
#' @param ... force later values to be bound by name
#' @param rowNumberColumn if not null name to add row numbers to
#' @return remote handle
#'
#' @examples
#'
#'
#' if (requireNamespace("RSQLite", quietly = TRUE)) {
#'   my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
#'   d <- replyr_copy_to(my_db, data.frame(x=c(1,2)), 'd')
#'   print(d)
#' }
#'
#' @export
replyr_copy_to <- function(dest, df, name = deparse(substitute(df)),
                           ...,
                           rowNumberColumn=NULL) {
  # try to force any errors early, and try to fail prior to side-effects
  if(length(list(...))>0) {
    stop('replyr::replyr_copy_to unexpected arguments')
  }
  force(dest)
  if("NULL" %in% class(dest)) {
    # special "no destination" case
    return(df)
  }
  if('tbl' %in% class(dest)) {
    # dest was actually another data object, get its source
    dest <- dest$src
    if("NULL" %in% class(dest)) {
      stop("replyr::replyr_copy_to unexpected dest")
    }
  }
  force(df)
  force(name)
  if("NULL" %in% class(df)) {
    stop("NULL df to replyr::replyr_copy_to")
  }
  if((!is.character(name))||(length(name)!=1)||(nchar(name)<1)) {
    stop('replyr::replyr_copy_to name must be a single non-empty string')
  }
  replyr_drop_table_name(dest, name)
  if(!is.null(rowNumberColumn)) {
    df[[rowNumberColumn]] <- seq_len(replyr_nrow(df))
  }
  dplyr::copy_to(dest, df, name,
                 temporary=FALSE,
                 overwrite=TRUE)
}

#' Bring remote data back as a local data frame tbl.
#'
#' @param d remote dplyr data item
#' @param maxrow max rows to allow (stop otherwise, set to NULL to allow any size).
#' @return local tbl.
#'
#' @examples
#'
#'
#' if (requireNamespace("RSQLite", quietly = TRUE)) {
#'   my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
#'   d <- replyr_copy_to(my_db,data.frame(x=c(1,2)),'d')
#'   d2 <- replyr_copy_from(d)
#'   print(d2)
#' }
#'
#' @export
replyr_copy_from <- function(d,maxrow=1000000) {
  if(!is.null(maxrow)) {
    n <- replyr_nrow(d)
    if(n>maxrow) {
      stop("replyr_copy_from maximum rows exceeded")
    }
  }
  dplyr::collect(d)
}
