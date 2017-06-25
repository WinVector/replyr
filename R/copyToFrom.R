
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr collect copy_to db_drop_table
NULL



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
#'   replyr_list_tables(my_db)
#'   replyr_drop_table_name(my_db, 'd')
#'   replyr_list_tables(my_db)
#' }
#'
#' @export
#'
replyr_drop_table_name <- function(dest, name) {
  if(length(name)<=0) {
    return(FALSE)
  }
  if((!is.character(name))||(length(name)!=1)||(nchar(name)<1)) {
    stop('replyr::replyr_drop_table_name name must be a single non-empty string')
  }
  if(is.null(dest) || is.character(dest)) {
    # special "no destination" case
    return(FALSE)
  }
  if('tbl' %in% class(dest)) {
    # dest was actually another data object, get its source
    dest <- dest$src
    if(is.null(dest)) {
      stop("replyr::replyr_drop_table_name unexpected dest")
    }
  }
  # MySQL doesn't seem to always obey overwrite=TRUE
  # not filing this as MySQL isn't a preferred back end.
  found = FALSE
  tryCatch(
    {
      cn <- dplyr_src_to_db_handle(dest)
      if(!is.null(cn)) {
        if(dplyr::db_has_table(cn, name)) {
          found = TRUE
          dplyr::db_drop_table(cn, name)
        }
      }
    },
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
#' @param temporary logical, if TRUE try to create a temporary table
#' @param overwrite logical, if TRUE try to overwrite
#' @param maxrow max rows to allow in a remote to remote copy.
#' @param forceDelete logical, if TRUE try to delete table.
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
replyr_copy_to <- function(dest,
                           df, name = paste(deparse(substitute(df)), collapse= ' '),
                           ...,
                           rowNumberColumn= NULL,
                           temporary= FALSE,
                           overwrite= TRUE,
                           maxrow= 1000000,
                           forceDelete= FALSE) {
  # try to force any errors early, and try to fail prior to side-effects
  if(length(list(...))>0) {
    stop('replyr::replyr_copy_to unexpected arguments')
  }
  force(dest)
  force(df)
  force(name)
  if(!replyr_is_local_data(df)) {
    warning("replyr::replyr_copy_to called on non-local table")
    df <- replyr_copy_from(df, maxrow = maxrow)
  }
  if(is.null(dest)) {
    # special "no destination" case
    return(df)
  }
  if(is.null(df)) {
    stop("NULL df to replyr::replyr_copy_to")
  }
  if('tbl' %in% class(dest)) {
    # dest was actually another data object, get its source
    dest <- dest$src
    if(is.null(dest)) {
      stop("replyr::replyr_copy_to unexpected dest")
    }
  }
  if((!is.character(name))||(length(name)!=1)||(nchar(name)<1)) {
    stop('replyr::replyr_copy_to name must be a single non-empty string')
  }
  if(forceDelete) {
    replyr_drop_table_name(dest, name)
  }
  if(!is.null(rowNumberColumn)) {
    df[[rowNumberColumn]] <- seq_len(replyr_nrow(df))
  }
  dplyr::copy_to(dest, df, name,
                 temporary=temporary,
                 overwrite=overwrite)
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
replyr_copy_from <- function(d, maxrow= 1000000) {
  if(!is.null(maxrow)) {
    n <- replyr_nrow(d)
    if(n>maxrow) {
      stop("replyr_copy_from maximum rows exceeded")
    }
  }
  dplyr::collect(d)
}
