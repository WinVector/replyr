
# replacements for a few of the underbar/underscore forms form dplyr 0.5 and earlier


#' Rename a column
#'
#' @param .data data object to work on
#' @param newName character new column name
#' @param oldName character old column name
#'
#' @examples
#'
#' d <- data.frame(Sepal_Length= c(5.8,5.7),
#'                 Sepal_Width= c(4.0,4.4),
#'                 Species= 'setosa', rank=c(1,2))
#' replyr_rename(d, 'family', 'Species')
#'
#' @export
#'
replyr_rename <- function(.data, newName, oldName) {
  REPLYR_PRIVATE_NEWNAME <- NULL # declare not an unbound name
  REPLYR_PRIVATE_OLDNAME <- NULL # declare not an unbound name
  if(newName!=oldName) {
    wrapr::let(
      c(REPLYR_PRIVATE_NEWNAME=newName,
        REPLYR_PRIVATE_OLDNAME=oldName),
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
  REPLYR_PRIVATE_NEWNAME <- NULL # declare not an unbound name
  desc <- function(.) {.} # declare not an unbound name
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


#' group_by by a single column
#'
#' @param .data data object to work on
#' @param colname character column name
#'
#' @examples
#'
#' d <- data.frame(Sepal_Length= c(5.8,5.7),
#'                 Sepal_Width= c(4.0,4.4),
#'                 Species= 'setosa')
#' replyr_group_by(d, 'Species')
#'
#' @export
#'
replyr_group_by <- function(.data, colname) {
  REPLYR_PRIVATE_NEWNAME <- NULL # declare not an unbound name
  wrapr::let(
    c(REPLYR_PRIVATE_NEWNAME=colname),
    .data <- dplyr::group_by(.data,
                             REPLYR_PRIVATE_NEWNAME)
  )
  .data
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
  dname <- deparse(substitute(.data))
  expr <- paste0('dplyr::select( ', dname, ', ',
                 paste(colnames, collapse = ', '),
                 ' )')
  eval(parse(text=expr),
       envir=parent.frame(),
       enclos=parent.frame())
}
