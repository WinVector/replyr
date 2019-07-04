
# replacements for a few of the underbar/underscore forms form dplyr 0.5 and earlier


#' Rename a column
#'
#' @param .data data object to work on
#' @param ... force later arguments to bind by name
#' @param newName character new column name
#' @param oldName character old column name
#'
#' @examples
#'
#' d <- data.frame(Sepal_Length= c(5.8,5.7),
#'                 Sepal_Width= c(4.0,4.4),
#'                 Species= 'setosa', rank=c(1,2))
#' replyr_rename(d, newName = 'family', oldName = 'Species')
#'
#' @export
#'
replyr_rename <- function(.data,
                          ...,
                          newName, oldName) {
  if(length(list(...))>0) {
    stop("replyr::replyr_rename unexpected arguments")
  }
  newName <- as.character(newName)
  oldName <- as.character(oldName)
  if((length(newName)!=1)||(length(oldName)!=1)) {
    stop("replyr::replyr_rename newName and oldName must be length 1 character vectors")
  }
  if(newName!=oldName) {
    REPLYR_PRIVATE_NEWNAME <- NULL # declare not an unbound name
    REPLYR_PRIVATE_OLDNAME <- NULL # declare not an unbound name
    wrapr::let(
      c(REPLYR_PRIVATE_NEWNAME=newName,
        REPLYR_PRIVATE_OLDNAME=oldName),
      strict = FALSE,
      .data <- dplyr::rename(.data,
                             REPLYR_PRIVATE_NEWNAME = REPLYR_PRIVATE_OLDNAME)
    )
  }
  .data
}



#' arrange by a single column
#'
#' @param .data data object to work on
#' @param colname character column name
#' @param descending logical if true sort descending (else sort ascending)
#'
#' @examples
#'
#' d <- data.frame(Sepal_Length= c(5.8,5.7),
#'                 Sepal_Width= c(4.0,4.4))
#' replyr_arrange(d, 'Sepal_Length', descending= TRUE)
#'
#' @export
#'
replyr_arrange <- function(.data, colname, descending = FALSE) {
  colname <- as.character(colname) # remove any names
  REPLYR_PRIVATE_NEWNAME <- NULL # declare not an unbound name
  desc <- dplyr::desc # declare not an unbound name
  if(descending) {
    wrapr::let(
      c(REPLYR_PRIVATE_NEWNAME=colname),
      .data <- dplyr::arrange(.data,
                              desc(REPLYR_PRIVATE_NEWNAME))
    )
  } else {
    wrapr::let(
      c(REPLYR_PRIVATE_NEWNAME=colname),
      .data <- dplyr::arrange(.data,
                              REPLYR_PRIVATE_NEWNAME)
    )
  }
  .data
}

#' @importFrom rlang syms
NULL

#' group_by columns
#'
#' See also: \url{https://gist.github.com/skranz/9681509}
#'
#' @param .data data.frame
#' @param colnames character vector of column names to group by.
#' @return .data grouped by columns named in colnames
#'
#' @examples
#'
#' d <- data.frame(Sepal_Length= c(5.8,5.7),
#'                 Sepal_Width= c(4.0,4.4),
#'                 Species= 'setosa')
#' replyr_group_by(d, 'Species')
#'
#' @seealso \code{\link[dplyr]{group_by}}, \code{\link[dplyr]{group_by_at}}
#'
#' @export
#'
replyr_group_by <- function(.data, colnames) {
  if(!(is.data.frame(.data) || dplyr::is.tbl(.data))) {
    stop("replyr::replyr_group_by first argument must be a data.frame or tbl")
  }
  # convert char vector into spliceable vector
  groupingSyms <- rlang::syms(as.character(colnames))
  dplyr::group_by(dplyr::ungroup(.data), !!!groupingSyms)
}



#' select columns
#'
#' @param .data data object to work on
#' @param colnames character column names
#'
#' @examples
#'
#' d <- data.frame(Sepal_Length= c(5.8,5.7),
#'                 Sepal_Width= c(4.0,4.4),
#'                 Species= 'setosa', rank=c(1,2))
#' replyr_select(d, c('Sepal_Length', 'Species'))
#'
#' @export
#'
replyr_select <- function(.data, colnames) {
  dplyr::select(.data, dplyr::one_of(colnames))
}
