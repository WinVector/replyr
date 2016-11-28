
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' Collect values found in gatherColumns as tuples
#'
#' Collect values found in gatherColumns as tuples naming which column the value came from (placed in measurementNameColumn)
#' and value found (placed in measurementValueColumn).  This is essentially a tidyr::gather, dplyr::melt, or anti-pivot.
#'
#' @param df data item
#' @param gatherColumns set of columns to collect measurements from
#' @param measurementNameColumn new column to write measurement names to (original gatherColumns)
#' @param measurementValueColumn new column to write measurment values to
#' @param useTidyr if TRUE use tidyr instead of calculating on own (only works on local data types)
#' @return data item
#'
#' @examples
#'
#' d <- data.frame(
#'   index = c(1, 2, 3),
#'   info = c('a', 'b', 'c'),
#'   meas1 = c('m1_1', 'm1_2', 'm1_3'),
#'   meas2 = c('m2_1', 'm2_2', 'm2_3'),
#'   stringsAsFactors = FALSE)
#' replyr_gather(d,c('meas1','meas2'),'meastype','meas')
#' replyr_gather(d,c('meas1','meas2'),'meastype','meas',useTidyr=TRUE)
#'
#' @export
replyr_gather <- function(df,gatherColumns,measurementNameColumn,measurementValueColumn,
                          useTidyr=FALSE) {
  if((!is.character(gatherColumns))||(length(gatherColumns)<1)) {
    stop('replyr_gather gatherColumns must a character vector')
  }
  if((!is.character(measurementNameColumn))||(length(measurementNameColumn)!=1)||
     (nchar(measurementNameColumn)<1)) {
    stop('replyr_gather measurementNameColumn must be a single non-empty string')
  }
  if((!is.character(measurementValueColumn))||(length(measurementValueColumn)!=1)||
     (nchar(measurementValueColumn)<1)) {
    stop('replyr_gather measurementValueColumn must be a single non-empty string')
  }
  if(measurementNameColumn==measurementValueColumn) {
    stop('replyr_gather measurementValueColumn must not equal measurementNameColumn')
  }
  cnames <- colnames(df)
  if(!all(gatherColumns %in% cnames)) {
    stop('replyr_gather gatherColumns must all be df column names')
  }
  if(any(measurementNameColumn %in% cnames)) {
    stop('replyr_gather measurementNameColumn must not be a df column name')
  }
  if(any(measurementValueColumn %in% cnames)) {
    stop('replyr_gather measurementValueColumn must not be a df column name')
  }
  if(useTidyr) {
    res <- tidyr::gather_(df,
                          key_col=measurementNameColumn,
                          value_col=measurementValueColumn,
                          gather_cols=gatherColumns)
    return(res)
  }
  dcols <- setdiff(cnames,gatherColumns)
  rlist <- lapply(gatherColumns, function(di) {
    targetsA <- c(dcols,di)
    targetsB <- c(dcols,measurementNameColumn,measurementValueColumn)
    df %>% dplyr::select(dplyr::one_of(targetsA)) %>%
      dplyr::mutate_(.dots=stats::setNames(paste0('"',di,'"'), measurementNameColumn)) %>%
      dplyr::mutate_(.dots=stats::setNames(di, measurementValueColumn)) %>%
      dplyr::select(dplyr::one_of(targetsB))
  })
  replyr_bind_rows(rlist)
}