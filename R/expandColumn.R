

expandItem <- function(vi, rowidDest, rowId, valDest, idxDest) {
  # TODO: special code for matrices/ named lists?
  vi <- unlist(vi)
  idxs <- seq_len(length(vi))
  CDATAVALDEST <- NULL # declare not an unbound ref
  CDATAORIGROWID <- NULL # declare not an unbound ref
  CDATATAIDXDEST <- NULL # declare not an unbound ref
  if(is.null(idxDest)) {
    wrapr::let(c(CDATAORIGROWID = rowidDest,
                 CDATAVALDEST= valDest),
               {
                 ei <- dplyr::data_frame(CDATAVALDEST= vi)
                 ei <- dplyr::mutate(ei,
                                     CDATAORIGROWID= rowId)
               })
  } else {
    wrapr::let(c(CDATAORIGROWID = rowidDest,
                 CDATAVALDEST= valDest,
                 CDATATAIDXDEST = idxDest),
               {
                 ei <- dplyr::data_frame(CDATATAIDXDEST= idxs,
                                         CDATAVALDEST= vi)
                 ei <- dplyr::mutate(ei,
                                     CDATAORIGROWID= rowId)
               })
  }
  ei
}

#' Expand a column of vectors into one row per value of each vector.
#'
#' Similar to \code{tidyr::unnest} but explicit allows ragged input, lands rowids and value ids, and can work on remote data sources. Fairly expensive per-row operation, not suitable for big data.
#'
#' @param data data.frame to work with.
#' @param colName character name of column to expand.
#' @param ... force later arguments to be bound by name
#' @param rowidSource optional character name of column to take row indices from.
#' @param rowidDest optional character name of column to write row indices to.
#' @param idxDest optional character name of column to write value indices to.
#' @return expanded data frame where each value of colName column is in a new row.
#'
#' @examples
#'
#'
#' d <- data.frame(name= c('a','b'))
#' d$value <- list(c('x','y'),'z')
#' expandColumn(d, 'value',
#'              rowidDest= 'origRowId',
#'              idxDest= 'valueIndex')
#'
#'
#' @export
#'
expandColumn <- function(data, colName, ...,
                         rowidSource= NULL,
                         rowidDest= NULL,
                         idxDest= NULL) {
  if(length(list(...))>0) {
    stop("replyr::expandColumn unexpected arguments")
  }
  needToDropProducedRowID <- FALSE
  if(is.null(rowidSource)) {
    if(is.null(rowidDest)) {
      rowidSource <- "CDATAROWIDCOL"
      needToDropProducedRowID <- TRUE
    } else {
      rowidSource <- rowidDest
    }
    CDATAROWIDCOL <- NULL # declare not an unbound ref
    wrapr::let(
      c(CDATAROWIDCOL = rowidSource),
      data <- dplyr::mutate(data, CDATAROWIDCOL = seq_len(nrow(data)))
    )
  }
  CDATAKEYCOLUMN <- NULL # declare not an unbound ref
  wrapr::let(
    c(CDATAKEYCOLUMN= rowidSource),
    keys <- dplyr::collect(dplyr::select(data, CDATAKEYCOLUMN))[[rowidSource]]
  )
  copyCols <- setdiff(colnames(data), colName)
  merged <- lapply(keys,
                   function(ki) {
                     CDATAKEYCOLUMN <- NULL # declare not an unbound ref
                     CDATAVALUECOLUMN <- NULL # declare not an unbound ref
                     wrapr::let(
                       c(CDATAKEYCOLUMN= rowidSource,
                         CDATAVALUECOLUMN= colName),
                       {
                         di <- dplyr::filter(data, CDATAKEYCOLUMN == ki)
                         vi <- dplyr::collect(dplyr::select(di, CDATAVALUECOLUMN))[[colName]][[1]]
                         vx <- expandItem(vi,
                                          rowidDest= rowidSource,
                                          rowId= ki,
                                          valDest= colName,
                                          idxDest= idxDest)
                         di <- dplyr::select(di, one_of(copyCols))
                         dplyr::inner_join(di, vx, by= rowidSource)
                       }
                     )
                   }
  )
  dres <- replyr::replyr_bind_rows(merged)
  if(needToDropProducedRowID) {
    keepCols <- setdiff(colnames(dres), rowidSource)
    dres <- dplyr::select(dres, one_of(keepCols))
  }
  dres
}

