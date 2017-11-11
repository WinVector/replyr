

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
#' Similar to \code{tidyr::unnest} but lands rowids and value ids, and can work on remote data sources. Fairly expensive per-row operation, not suitable for big data.
#'
#' @param data data.frame to work with.
#' @param colName character name of column to expand.
#' @param ... force later arguments to be bound by name
#' @param rowidSource optional character name of column to take row indices from (rowidDest must be NULL to use this).
#' @param rowidDest optional character name of column to write row indices to (must not be an existing column name, rowidSource must be NULL to use this).
#' @param idxDest optional character name of column to write value indices to (must not be an existing column name).
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
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
expandColumn <- function(data, colName,
                         ...,
                         rowidSource= NULL,
                         rowidDest= NULL,
                         idxDest= NULL,
                         tempNameGenerator= makeTempNameGenerator("replyr_expandColumn")) {
  if(length(list(...))>0) {
    stop("replyr::expandColumn unexpected arguments")
  }
  if((length(colName)!=1)||(!is.character(colName))) {
    stop("replyr::expandColumn colName must be a string")
  }
  if( (length(rowidSource)!=0) &&
      ((length(rowidSource)!=1)||(!is.character(rowidSource)))) {
    stop("replyr::expandColumn rowidSource must be a string")
  }
  if( (length(rowidDest)!=0) &&
      ((length(rowidDest)!=1)||(!is.character(rowidDest)))) {
    stop("replyr::expandColumn rowidDest must be a string")
  }
  if( (length(idxDest)!=0) &&
      ((length(idxDest)!=1)||(!is.character(idxDest)))) {
    stop("replyr::expandColumn idxDest must be a string")
  }
  if( (length(rowidSource)>0) && (length(rowidDest)>0) ) {
    stop("replyr::expandColumn you can specify at most of one of rowidSource and rowidDest")
  }
  data <- dplyr::ungroup(data)
  ndrow <- replyr::replyr_nrow(data)
  if(ndrow<=0) {
    return(data)
  }
  dnames <- colnames(data)
  if(!(colName %in% dnames)) {
    stop("replyr::expandColumn colName must be the name of a column")
  }
  if( (length(rowidSource)!=0) &&
      (!(rowidSource %in% dnames)) ) {
    stop("replyr::expandColumn rowidSource must be the name of a column")
  }
  if( (length(rowidDest)!=0) &&
      (rowidDest %in% dnames) ) {
    stop("replyr::expandColumn rowidDest must not match an existing column")
  }
  if( (length(idxDest)!=0) &&
      (idxDest %in% dnames) ) {
    stop("replyr::expandColumn idxDest must not match an existing column")
  }
  needToDropProducedRowID <- FALSE
  if(is.null(rowidSource)) {
    if(is.null(rowidDest)) {
      rowidSource <- "CDATAROWIDCOL"
      needToDropProducedRowID <- TRUE
    } else {
      rowidSource <- rowidDest
    }
    data <- replyr_add_ids(data, rowidSource)
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
                         di <- dplyr::select(di, dplyr::one_of(copyCols))
                         if((!replyr_is_local_data(di)) && (replyr_is_local_data(vx))) {
                           cn <- replyr_get_src(di)
                           vx <- replyr_copy_to(cn, vx, tempNameGenerator(),
                                                temporary = TRUE)
                         }
                         dplyr::inner_join(di, vx,
                                           by= rowidSource)
                       }
                     )
                   }
  )
  dres <- replyr::replyr_bind_rows(merged,
                                   tempNameGenerator=tempNameGenerator)
  if(needToDropProducedRowID) {
    keepCols <- setdiff(colnames(dres), rowidSource)
    dres <- dplyr::select(dres, dplyr::one_of(keepCols))
  }
  dres
}

