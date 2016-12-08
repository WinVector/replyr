
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr collect copy_to
NULL



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
#'   fnam <- tempfile(pattern = "replyr_ex1_sqlite", tmpdir = tempdir(), fileext = "sqlite3")
#'   my_db <- dplyr::src_sqlite(fnam, create = TRUE)
#'   d <- replyr_copy_to(my_db,data.frame(x=c(1,2)),'d')
#'   print(d)
#'   rm(list=c('my_db','d'))
#'   gc()
#'   file.remove(fnam)
#' }
#'
#' @export
replyr_copy_to <- function(dest, df, name = deparse(substitute(df)),
                           ...,
                           rowNumberColumn=NULL) {
  # try to force any errors early, and try to fail prior to side-effects
  if(length(list(...))>0) {
    stop('replyr_copy_to unexpected arguments')
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
    stop("NULL df to replyr_copy_to")
  }
  if((!is.character(name))||(length(name)!=1)||(nchar(name)<1)) {
    stop('replyr_copy_to name must be a single non-empty string')
  }
  # MySQL doesn't seem to always obey overwrite=TRUE
  # not filing this as MySQL isn't a preferred back end.
  tryCatch({
    cn <- dest$con
    if(!("NULL" %in% class(cn))) {
      if(name %in% dplyr::db_list_tables(cn)) {
        dplyr::db_drop_table(cn,name)
      }
    }},
    error=function(x) NULL,
    warning=function(x) NULL
  )
  if(!is.null(rowNumberColumn)) {
    df[[rowNumberColumn]] <- seq_len(nrow(df))
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
#'   fnam <- tempfile(pattern = "replyr_ex2_sqlite", tmpdir = tempdir(), fileext = "sqlite3")
#'   my_db <- dplyr::src_sqlite(fnam, create = TRUE)
#'   d <- replyr_copy_to(my_db,data.frame(x=c(1,2)),'d')
#'   d2 <- replyr_copy_from(d)
#'   print(d2)
#'   rm(list=c('my_db','d','d2'))
#'   gc()
#'   file.remove(fnam)
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
