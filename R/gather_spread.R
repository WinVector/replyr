
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr select mutate_ one_of
NULL

# dplyr::one_of is what is causing us to depend on dplyr (>= 0.5.0)

#' Collect values found in gatherColumns as tuples
#'
#' Collect values found in gatherColumns as tuples naming which column the value came from (placed in measurementNameColumn)
#' and value found (placed in measurementValueColumn).  This is essentially a tidyr::gather, dplyr::melt, or anti-pivot.
#'
#' @param df data item
#' @param gatherColumns set of columns to collect measurements from
#' @param measurementNameColumn new column to write measurement names to (original gatherColumns)
#' @param measurementValueColumn new column to write measurement values to
#' @param useTidyr if TRUE use tidyr instead of calculating on own (only works on local data types)
#' @param eagerCompute if TRUE call compute on intermediate results
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
                          useTidyr=FALSE,eagerCompute=FALSE) {
  if((!is.character(gatherColumns))||(length(gatherColumns)<1)) {
    stop('replyr_gather gatherColumns must be a character vector')
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
  if(measurementNameColumn %in% cnames) {
    stop('replyr_gather measurementNameColumn must not be a df column name')
  }
  if(measurementValueColumn %in% cnames) {
    stop('replyr_gather measurementValueColumn must not be a df column name')
  }
  if(useTidyr) {
    res <- tidyr::gather_(df,
                          key_col=measurementNameColumn,
                          value_col=measurementValueColumn,
                          gather_cols=gatherColumns)
    return(res)
  }
  useAsChar <- TRUE
  if(length(intersect(c("src_mysql"),replyr_dataServiceName(df)))>0) {
    useAsChar <- FALSE
  }
  dcols <- setdiff(cnames,gatherColumns)
  rlist <- lapply(gatherColumns, function(di) {
    targetsA <- c(dcols,di)
    targetsB <- c(dcols,measurementNameColumn,measurementValueColumn)
    # PostgreSQL needs to know types on character types with the lazyeval form.
    # MySQL does not like such annotation.
    df %>% dplyr::select(dplyr::one_of(targetsA)) -> dtmp
    if(useAsChar) {
      dtmp %>%
        dplyr::mutate_(.dots=stats::setNames(paste0('as.character("',di,'")'), measurementNameColumn)) -> dtmp
    } else {
      dtmp %>%
        dplyr::mutate_(.dots=stats::setNames(paste0('"',di,'"'), measurementNameColumn)) -> dtmp
    }
    dtmp %>%
      dplyr::mutate_(.dots=stats::setNames(di, measurementValueColumn)) %>%
      dplyr::select(dplyr::one_of(targetsB)) -> dtmp
    if(eagerCompute) {
      dtmp %>% dplyr::compute() -> dtmp
    }
    dtmp
  })
  replyr_bind_rows(rlist)
}




#' Spread values found in rowControlColumn row groups as new columns. A concept demonstration, not a usable function.
#'
#' Spread values found in rowControlColumn row groups as new columns.
#' Values types (new column names) are identified in measurementNameColumn and values are taken
#' from measurementValueColumn.
#' This is denormalizing operation, or essentially a tidyr::spread, dplyr::dcast, or pivot.
#' This implementation moves
#' so much data it is essentially working locally and also very inefficient.
#'
#' @param df data item
#' @param rowControlColumn column to determine which sets of rows are considered a group.
#' @param measurementNameColumn column to take measurement names from (values become new columns)
#' @param measurementValueColumn column to take measurement values from
#' @param maxcols maximum number of values to expand to columns
#' @param useTidyr if TRUE use tidyr instead of calculating on own (only works on local data types)
#' @param eagerCompute if TRUE call compute on intermediate results
#' @return data item
#'
#' @examples
#'
#' d <- data.frame(
#'   index = c(1, 2, 3, 1, 2, 3),
#'   meastype = c('meas1','meas1','meas1','meas2','meas2','meas2'),
#'   meas = c('m1_1', 'm1_2', 'm1_3', 'm2_1', 'm2_2', 'm2_3'),
#'   stringsAsFactors = FALSE)
#' replyr_spread(d,'index','meastype','meas')
#' replyr_spread(d,'index','meastype','meas',useTidyr=TRUE)
#'
#' @export
replyr_spread <- function(df,rowControlColumn,measurementNameColumn,measurementValueColumn,
                          maxcols=100,
                          useTidyr=FALSE,
                          eagerCompute=FALSE) {
  if((!is.character(rowControlColumn))||(length(rowControlColumn)!=1)||
     (nchar(rowControlColumn)<1)) {
    stop('replyr_spread rowControlColumn must be a single non-empty string')
  }
  if((!is.character(measurementNameColumn))||(length(measurementNameColumn)!=1)||
     (nchar(measurementNameColumn)<1)) {
    stop('replyr_spread measurementNameColumn must be a single non-empty string')
  }
  if((!is.character(measurementValueColumn))||(length(measurementValueColumn)!=1)||
     (nchar(measurementValueColumn)<1)) {
    stop('replyr_spread measurementValueColumn must be a single non-empty string')
  }
  ucols <- c(rowControlColumn,measurementNameColumn,measurementValueColumn)
  if(length(unique(ucols))!=3) {
    stop('replyr_spread measurementValueColumn must be a single non-empty string')
  }
  if(measurementNameColumn==measurementValueColumn) {
    stop('replyr_spread rowControlColumn,measurementNameColumn,measurementValueColumn must all be distinct')
  }
  cnames <- colnames(df)
  if(!(rowControlColumn %in% cnames)) {
    stop('replyr_spread rowControlColumn must be a df column name')
  }
  if(!(measurementNameColumn %in% cnames)) {
    stop('replyr_spread measurementNameColumn must be a df column name')
  }
  if(!(measurementValueColumn %in% cnames)) {
    stop('replyr_spread measurementValueColumn must be a df column name')
  }
  if(useTidyr) {
    res <- tidyr::spread_(df,
                          key_col=measurementNameColumn,
                          value_col=measurementValueColumn)
    return(res)
  }
  useAsChar <- TRUE
  if(length(intersect(c("src_mysql"),replyr_dataServiceName(df)))>0) {
    useAsChar <- FALSE
  }
  df %>% replyr_uniqueValues(measurementNameColumn) %>%
    replyr_copy_from(maxrow=maxcols) -> colStats
  newCols <- colStats[[measurementNameColumn]]
  if(any(newCols %in% cnames)) {
    stop('replyr_spread measurementNameColumn values must not include any df column names')
  }
  mcols <- c(measurementNameColumn,measurementValueColumn)
  copyCols <- setdiff(cnames,mcols)
  f <- function(di) {
    di %>% head(n=1) %>% dplyr::select(dplyr::one_of(copyCols)) -> d1
    di %>% dplyr::select(dplyr::one_of(ucols)) -> di
    for(ni in newCols) {
      di %>% replyr_filter(measurementNameColumn,ni,verbose=FALSE) -> din
      vi <- NA
      if(replyr_nrow(din)>0) {
        suppressWarnings({
          # MySQL:  In .local(conn, statement, ...) : Decimal MySQL column 1 imported as numeric
          din %>% head(n=1) %>% replyr::replyr_copy_from() %>%
            as.data.frame() -> din1
          vi <- din1[1,measurementValueColumn,drop=TRUE]
        })
      }
      # see http://stackoverflow.com/questions/26003574/r-dplyr-mutate-use-dynamic-variable-names
      # PostgreSQL needs to know types on character types with the lazyeval form.
      # MySQL does not like such annotation.
      if(useAsChar && is.character(vi)) {
        varval <- lazyeval::interp(~as.character(vi),vi=vi)
      } else {
        varval <- lazyeval::interp(~vi,vi=vi)
      }
      d1 %>% dplyr::mutate_(.dots=stats::setNames(list(varval), ni)) -> d1
    }
    if(eagerCompute) {
      dplyr::compute(d1) -> d1
    }
    d1
  }
  gapply(df,rowControlColumn,f,maxgroups=NULL)
}

