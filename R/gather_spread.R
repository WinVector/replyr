
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

# @importFrom dplyr select mutate one_of
NULL

# dplyr::one_of is what is causing us to depend on dplyr (>= 0.5.0)

# Collect values found in columnsToTakeFrom as tuples (experimental, not fully tested on multiple data suppliers)
#
# Collect values found in columnsToTakeFrom as tuples naming which column the value came from (placed in nameForNewKeyColumn)
# and value found (placed in nameForNewValueColumn).  This is essentially a tidyr::gather, dplyr::melt, or anti-pivot.
#
# @param data data.frame to work with.
# @param nameForNewKeyColumn character name of column to write new keys in.
# @param nameForNewValueColumn character name of column to write new values in.
# @param columnsToTakeFrom character array names of columns to take values from.
# @param eagerCompute if TRUE call compute on intermediate results
# @return data item
#
# @examples
#
# d <- data.frame(
#   index = c(1, 2, 3),
#   info = c('a', 'b', 'c'),
#   meas1 = c('m1_1', 'm1_2', 'm1_3'),
#   meas2 = c('m2_1', 'm2_2', 'm2_3'),
#   stringsAsFactors = FALSE)
# replyr_moveValuesToRows(d,
#               nameForNewKeyColumn= 'meastype',
#               nameForNewValueColumn= 'meas',
#               columnsToTakeFrom= c('meas1','meas2'))
# # cdata::moveValuesToRows(d,
# #               nameForNewKeyColumn= 'meastype',
# #               nameForNewValueColumn= 'meas',
# #               columnsToTakeFrom= c('meas1','meas2'))
#
# @export
replyr_moveValuesToRows <- function(data,
                                    nameForNewKeyColumn,
                                    nameForNewValueColumn,
                                    columnsToTakeFrom,
                                    eagerCompute=FALSE) {
  if((!is.character(columnsToTakeFrom))||(length(columnsToTakeFrom)<1)) {
    stop('replyr_moveValuesToRows columnsToTakeFrom must be a character vector')
  }
  if((!is.character(nameForNewKeyColumn))||(length(nameForNewKeyColumn)!=1)||
     (nchar(nameForNewKeyColumn)<1)) {
    stop('replyr_moveValuesToRows nameForNewKeyColumn must be a single non-empty string')
  }
  if((!is.character(nameForNewValueColumn))||(length(nameForNewValueColumn)!=1)||
     (nchar(nameForNewValueColumn)<1)) {
    stop('replyr_moveValuesToRows nameForNewValueColumn must be a single non-empty string')
  }
  if(nameForNewKeyColumn==nameForNewValueColumn) {
    stop('replyr_moveValuesToRows nameForNewValueColumn must not equal nameForNewKeyColumn')
  }
  cnames <- colnames(data)
  if(!all(columnsToTakeFrom %in% cnames)) {
    stop('replyr_moveValuesToRows columnsToTakeFrom must all be data column names')
  }
  if(nameForNewKeyColumn %in% cnames) {
    stop('replyr_moveValuesToRows nameForNewKeyColumn must not be a data column name')
  }
  if(nameForNewValueColumn %in% cnames) {
    stop('replyr_moveValuesToRows nameForNewValueColumn must not be a data column name')
  }
  useAsChar <- TRUE
  if(length(intersect(c("src_mysql"),replyr_dataServiceName(data)))>0) {
    useAsChar <- FALSE
  }
  dcols <- setdiff(cnames,columnsToTakeFrom)
  rlist <- lapply(columnsToTakeFrom, function(di) {
    targetsA <- c(dcols,di)
    targetsB <- c(dcols,nameForNewKeyColumn,nameForNewValueColumn)
    # PostgreSQL needs to know types on character types with the lazyeval form.
    # MySQL does not like such annotation.
    data %>% dplyr::select(dplyr::one_of(targetsA)) -> dtmp
    NEWCOL <- NULL  # declare not unbound
    OLDCOL <- NULL  # declare not unbound
    if(useAsChar) {
      wrapr::let(
        c(NEWCOL=nameForNewKeyColumn, OLDCOL=di),
        dtmp %>% dplyr::mutate(NEWCOL=as.character('OLDCOL')) -> dtmp
      )
    } else {
      wrapr::let(
        c(NEWCOL=nameForNewKeyColumn, OLDCOL=di),
        dtmp %>% dplyr::mutate(NEWCOL='OLDCOL') -> dtmp
      )
    }
    print('.')
    wrapr::let(
      c(NEWCOL=nameForNewValueColumn, OLDCOL=di),
      dtmp %>%
        dplyr::mutate(NEWCOL= OLDCOL) %>%
        dplyr::select(dplyr::one_of(targetsB)) -> dtmp
    )
    if(eagerCompute) {
      dtmp %>% dplyr::compute() -> dtmp
    }
    dtmp
  })
  replyr_bind_rows(rlist)
}




# Spread values found in rowKeyColumns row groups as new columns (experimental, not fully tested on multiple data suppliers)
#
# Spread values found in rowKeyColumns row groups as new columns.
# Values types (new column names) are identified in nameForNewKeyColumn and values are taken
# from nameForNewValueColumn.
# This is denormalizing operation, or essentially a tidyr::spread, dplyr::dcast, or pivot.
# This implementation moves
# so much data it is essentially working locally and also very inefficient.
#
# @param data data.frame to work with.
# @param columnToTakeKeysFrom character name of column build new column names from.
# @param columnToTakeValuesFrom character name of column to get values from.
# @param rowKeyColumns character array names columns that should be table keys.
# @param maxcols maximum number of values to expand to columns
# @param eagerCompute if TRUE call compute on intermediate results
# @return data item
#
# @examples
#
# d <- data.frame(
#   index = c(1, 2, 3, 1, 2, 3),
#   meastype = c('meas1','meas1','meas1','meas2','meas2','meas2'),
#   meas = c('m1_1', 'm1_2', 'm1_3', 'm2_1', 'm2_2', 'm2_3'),
#   stringsAsFactors = FALSE)
# replyr_moveValuesToColumns(d,
#                            columnToTakeKeysFrom= 'meastype',
#                            columnToTakeValuesFrom= 'meas',
#                            rowKeyColumns= 'index')
# # cdata::moveValuesToColumns(d,
# #                            columnToTakeKeysFrom= 'meastype',
# #                            columnToTakeValuesFrom= 'meas',
# #                            rowKeyColumns= 'index')
#
#
# @export
replyr_moveValuesToColumns <- function(data,
                                       columnToTakeKeysFrom,
                                       columnToTakeValuesFrom,
                                       rowKeyColumns,
                                       maxcols=100,
                                       eagerCompute=FALSE) {
  if((!is.character(rowKeyColumns))||(length(rowKeyColumns)!=1)||
     (nchar(rowKeyColumns)<1)) {
    stop('replyr_moveValuesToColumns rowKeyColumns must be a single non-empty string')
  }
  if((!is.character(columnToTakeKeysFrom))||(length(columnToTakeKeysFrom)!=1)||
     (nchar(columnToTakeKeysFrom)<1)) {
    stop('replyr_moveValuesToColumns columnToTakeKeysFrom must be a single non-empty string')
  }
  if((!is.character(columnToTakeValuesFrom))||(length(columnToTakeValuesFrom)!=1)||
     (nchar(columnToTakeValuesFrom)<1)) {
    stop('replyr_moveValuesToColumns columnToTakeValuesFrom must be a single non-empty string')
  }
  ucols <- c(rowKeyColumns,columnToTakeKeysFrom,columnToTakeValuesFrom)
  if(length(unique(ucols))!=3) {
    stop('replyr_moveValuesToColumns columnToTakeValuesFrom must be a single non-empty string')
  }
  if(columnToTakeKeysFrom==columnToTakeValuesFrom) {
    stop('replyr_moveValuesToColumns rowKeyColumns,columnToTakeKeysFrom,columnToTakeValuesFrom must all be distinct')
  }
  cnames <- colnames(data)
  if(!(rowKeyColumns %in% cnames)) {
    stop('replyr_moveValuesToColumns rowKeyColumns must be a data column name')
  }
  if(!(columnToTakeKeysFrom %in% cnames)) {
    stop('replyr_moveValuesToColumns columnToTakeKeysFrom must be a data column name')
  }
  if(!(columnToTakeValuesFrom %in% cnames)) {
    stop('replyr_moveValuesToColumns columnToTakeValuesFrom must be a data column name')
  }
  useAsChar <- TRUE
  if(length(intersect(c("src_mysql"),replyr_dataServiceName(data)))>0) {
    useAsChar <- FALSE
  }
  data %>% replyr_uniqueValues(columnToTakeKeysFrom) %>%
    replyr_copy_from(maxrow=maxcols) -> colStats
  newCols <- colStats[[columnToTakeKeysFrom]]
  if(any(newCols %in% cnames)) {
    stop('replyr_moveValuesToColumns columnToTakeKeysFrom values must not include any data column names')
  }
  mcols <- c(columnToTakeKeysFrom,columnToTakeValuesFrom)
  copyCols <- setdiff(cnames,mcols)
  f <- function(di) {
    di %>% head(n=1) %>% dplyr::select(dplyr::one_of(copyCols)) -> d1
    di %>% dplyr::select(dplyr::one_of(ucols)) -> di
    for(ni in newCols) {
      di %>% replyr_filter(columnToTakeKeysFrom,ni,verbose=FALSE) -> din
      vi <- NA
      if(replyr_nrow(din)>0) {
        suppressWarnings({
          # MySQL:  In .local(conn, statement, ...) : Decimal MySQL column 1 imported as numeric
          din %>% head(n=1) %>% replyr::replyr_copy_from() %>%
            as.data.frame() -> din1
          vi <- din1[1,columnToTakeValuesFrom,drop=TRUE]
        })
      }
      # see http://stackoverflow.com/questions/26003574/r-dplyr-mutate-use-dynamic-variable-names
      # PostgreSQL needs to know types on character types with the lazyeval form.
      # MySQL does not like such annotation.
      NEWCOLNAME <- NULL  # declare not unbound
      if(useAsChar && is.character(vi)) {
        wrapr::let(c(NEWCOLNAME= ni),
          d1 %>% dplyr::mutate(NEWCOLNAME = as.character(vi)) -> d1
        )
      } else {
        wrapr::let(c(NEWCOLNAME= ni),
          d1 %>% dplyr::mutate(NEWCOLNAME = vi) -> d1
        )
      }
    }
    if(eagerCompute) {
      dplyr::compute(d1) -> d1
    }
    d1
  }
  gapply(data,rowKeyColumns,f,maxgroups=NULL,partitionMethod='extract')
}

