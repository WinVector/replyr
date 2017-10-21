
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr select mutate one_of
#' @importFrom wrapr %.>%
#' @importFrom seplyr group_by_se
#' @importFrom cdata moveValuesToRows moveValuesToColumns
NULL

# dplyr::one_of is what is causing us to depend on dplyr (>= 0.5.0)

#' Collect values found in columnsToTakeFrom as tuples (experimental, only suitable for a moderate number of columns, not fully tested on multiple data suppliers).
#'
#' May be deprecated soon, please use \code{\link[cdata]{moveValuesToRows}} or \code{\link{moveValuesToRowsQ}}.
#'
#' Collect values found in columnsToTakeFrom as tuples naming which column the value came from (placed in nameForNewKeyColumn)
#' and value found (placed in nameForNewValueColumn).  This is essentially a \code{tidyr::gather}, \code{dplyr::melt}, or anti-pivot.
#' Similar interface as in the \code{cdata} package (though does not perform pre/post condition checks).
#'
#' @param data data.frame to work with.
#' @param nameForNewKeyColumn character name of column to write new keys in.
#' @param nameForNewValueColumn character name of column to write new values in.
#' @param columnsToTakeFrom character array names of columns to take values from.
#' @param ... force later columns to bind by name.
#' @param na.rm logical if TRUE remove rows with NA in nameForNewValueColumn.
#' @param nameForNewClassColumn optional name to land original cell classes to.
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return data item
#'
#' @seealso \url{https://github.com/WinVector/cdata}, \code{\link[cdata]{moveValuesToRows}}, \code{\link[cdata]{moveValuesToColumns}}, \code{\link{moveValuesToRowsQ}}, \code{\link{moveValuesToColumnsQ}}, \code{\link{replyr_moveValuesToRows}}, \code{\link{replyr_moveValuesToColumns}}
#'
#' @examples
#'
#' d <- data.frame(
#'   index = c(1, 2, 3),
#'   info = c('a', 'b', 'c'),
#'   meas1 = c('m1_1', 'm1_2', 'm1_3'),
#'   meas2 = c(2.1, 2.2, 2.3),
#'   stringsAsFactors = FALSE)
#' replyr_moveValuesToRows(d,
#'               nameForNewKeyColumn= 'meastype',
#'               nameForNewValueColumn= 'meas',
#'               columnsToTakeFrom= c('meas1','meas2'),
#'               nameForNewClassColumn= 'origMeasurementClass')
#' # cdata::moveValuesToRows(d,
#' #                         nameForNewKeyColumn= 'meastype',
#' #                         nameForNewValueColumn= 'meas',
#' #                         columnsToTakeFrom= c('meas1','meas2'),
#' #                         nameForNewClassColumn= 'origMeasurementClass')
#'
#' @export
replyr_moveValuesToRows <- function(data,
                                    nameForNewKeyColumn,
                                    nameForNewValueColumn,
                                    columnsToTakeFrom,
                                    ...,
                                    na.rm= FALSE,
                                    nameForNewClassColumn= NULL,
                                    tempNameGenerator= makeTempNameGenerator("replyr_moveValuesToRows")) {
  # .Deprecated(old = "replyr_moveValuesToRows", new = "moveValuesToRowsQ")
  if(length(list(...))>0) {
    stop("replyr::replyr_moveValuesToRows unexpected arguments")
  }
  if((!is.character(columnsToTakeFrom))||(length(columnsToTakeFrom)<1)) {
    stop('replyr_moveValuesToRows columnsToTakeFrom must be a non-NA non-empty character vector')
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
  if(length(nameForNewClassColumn)!=0) {
    if((length(nameForNewClassColumn)!=1) || (!is.character(nameForNewClassColumn))) {
      stop("replyr::replyr_moveValuesToRows nameForNewClassColumn must be length 1 character")
    }
  }
  data <- dplyr::ungroup(data)
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
  isMySQL <- replyr_is_MySQL_data(data)
  if(isMySQL) {
    useAsChar <- FALSE
  }
  localSample <- data %.>%
    head(.) %.>%
    collect(.) %.>%
    as.data.frame(.)
  classMap <- data.frame(colName= colnames(localSample),
                         className = vapply(localSample, class, character(1)),
                         stringsAsFactors = FALSE)
  heterogeniousValues <- length(unique(classMap$className[classMap$colName %in% columnsToTakeFrom]))>1
  colnames(classMap) <- c(nameForNewKeyColumn, nameForNewClassColumn)
  dcols <- setdiff(cnames,columnsToTakeFrom)
  rlist <- lapply(columnsToTakeFrom,
                  function(di) {
                    targetsA <- c(dcols, di)
                    targetsB <- c(dcols, nameForNewKeyColumn, nameForNewValueColumn)
                    # PostgreSQL needs to know types on character types with the lazyeval form.
                    # MySQL does not like such annotation.
                    data %.>% dplyr::select(., dplyr::one_of(targetsA)) -> dtmp
                    NEWCOL <- NULL  # declare not unbound
                    OLDCOL <- NULL  # declare not unbound
                    if(useAsChar) {
                      wrapr::let(
                        c(NEWCOL=nameForNewKeyColumn),
                        dtmp %.>% dplyr::mutate(., NEWCOL= as.character(di)) -> dtmp
                      )
                    } else {
                      wrapr::let(
                        c(NEWCOL=nameForNewKeyColumn),
                        dtmp %.>% dplyr::mutate(., NEWCOL= di) -> dtmp
                      )
                    }
                    wrapr::let(
                      c(NEWCOL=nameForNewValueColumn, OLDCOL=di),
                      dtmp %.>%
                        dplyr::mutate(., NEWCOL= OLDCOL) %.>%
                        dplyr::select(., dplyr::one_of(targetsB)) -> dtmp
                    )
                    if(heterogeniousValues) {
                      wrapr::let(
                        c(NEWCOL=nameForNewValueColumn),
                        dtmp %.>% mutate(., NEWCOL = as.character(NEWCOL)) -> dtmp
                      )
                    }
                    # worry about drifting ref issue
                    # See issues/TrailingRefIssue.Rmd
                    dtmp %.>% dplyr::compute(., name= tempNameGenerator()) -> dtmp
                    dtmp
                  })
  res <- replyr_bind_rows(rlist,
                          tempNameGenerator=tempNameGenerator)
  if(na.rm) {
    NEWCOL <- NULL  # declare not unbound
    let(
      c(NEWCOL=nameForNewValueColumn),
      res <- dplyr::filter(res, !is.na(NEWCOL))
    )
  }
  if(!is.null(nameForNewClassColumn)) {
    if(!replyr_is_local_data(data)) {
      classMap <- replyr_copy_to(replyr_get_src(data),
                                 classMap, tempNameGenerator(),
                                 temporary = TRUE)
    }
    res <- dplyr::left_join(res, classMap, by=nameForNewKeyColumn)
  }
  res
}




#' Spread values found in rowKeyColumns row groups as new columns (experimental, only suitable for a moderate number of columns, not fully tested on multiple data suppliers).
#'
#' May be deprecated soon, please use \code{\link[cdata]{moveValuesToColumns}} or \code{\link{moveValuesToColumnsQ}}.
#'
#' Spread values found in \code{columnToTakeValuesFrom} row groups as new columns labeled by \code{columnToTakeKeysFrom}.
#' from nameForNewValueColumn.
#' This is denormalizing operation, or essentially a \code{tidyr::spread}, \code{dplyr::dcast}, or pivot.
#' Similar interface as in the \code{cdata} package (though does not perform pre/post condition checks).
#'
#' @param data data.frame to work with.
#' @param columnToTakeKeysFrom character name of column build new column names from.
#' @param columnToTakeValuesFrom character name of column to get values from.
#' @param rowKeyColumns character array names columns that should be table keys.
#' @param ... force later arguments to bind by name
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @param fill value to fill in missing values from original (both those that are originally explicitly NA, and those not present as rows).
#' @param sep character, if not null build composite column names as COLsepVALUE, use new columns names are just VALUE.
#' @param maxcols maximum number of values to expand to columns
#' @param dosummarize logical, if TRUE finish the moveValuesToColumns by summarizing rows.
#' @return data item
#'
#' @seealso \url{https://github.com/WinVector/cdata}, \code{\link[cdata]{moveValuesToRows}}, \code{\link[cdata]{moveValuesToColumns}}, \code{\link{moveValuesToRowsQ}}, \code{\link{moveValuesToColumnsQ}}, \code{\link{replyr_moveValuesToRows}}, \code{\link{replyr_moveValuesToColumns}}
#'
#' @examples
#'
#' d <- data.frame(
#'   index = c(1, 2, 3, 1, 2, 3),
#'   meastype = c('meas1','meas1','meas1','meas2','meas2','meas2'),
#'   meas = c('m1_1', 'm1_2', 'm1_3', 'm2_1', 'm2_2', 'm2_3'),
#'   stringsAsFactors = FALSE)
#' replyr_moveValuesToColumns(d,
#'                            columnToTakeKeysFrom= 'meastype',
#'                            columnToTakeValuesFrom= 'meas',
#'                            rowKeyColumns= 'index',
#'                            sep= '_')
#' # cdata::moveValuesToColumns(d,
#' #                            columnToTakeKeysFrom= 'meastype',
#' #                            columnToTakeValuesFrom= 'meas',
#' #                            rowKeyColumns= 'index',
#' #                            sep= '_')
#'
#'
#' @export
replyr_moveValuesToColumns <- function(data,
                                       columnToTakeKeysFrom,
                                       columnToTakeValuesFrom,
                                       rowKeyColumns,
                                       ...,
                                       fill= NA,
                                       sep= NULL,
                                       maxcols= 100,
                                       dosummarize= TRUE,
                                       tempNameGenerator= makeTempNameGenerator("replyr_moveValuesToColumns")) {
  # .Deprecated(old = "replyr_moveValuesToColumns", new = "moveValuesToColumnsQ")
  if(length(list(...))>0) {
    stop("replyr::replyr_moveValuesToColumns unexpected arguments.")
  }
  if(length(rowKeyColumns)>0) {
    if((!is.character(rowKeyColumns))||(length(rowKeyColumns)!=1)||
     (nchar(rowKeyColumns)<1)) {
     stop('replyr_moveValuesToColumns rowKeyColumns must be a single non-empty string')
    }
  }
  if((!is.character(columnToTakeKeysFrom))||(length(columnToTakeKeysFrom)!=1)||
     (nchar(columnToTakeKeysFrom)<1)) {
    stop('replyr_moveValuesToColumns columnToTakeKeysFrom must be a single non-empty string')
  }
  if((!is.character(columnToTakeValuesFrom))||(length(columnToTakeValuesFrom)!=1)||
     (nchar(columnToTakeValuesFrom)<1)) {
    stop('replyr_moveValuesToColumns columnToTakeValuesFrom must be a single non-empty string')
  }
  if(columnToTakeKeysFrom==columnToTakeValuesFrom) {
    stop('replyr_moveValuesToColumns rowKeyColumns,columnToTakeKeysFrom,columnToTakeValuesFrom must all be distinct')
  }
  data <- dplyr::ungroup(data)
  cnames <- colnames(data)
  if(!(columnToTakeKeysFrom %in% cnames)) {
    stop('replyr_moveValuesToColumns columnToTakeKeysFrom must be a data column name')
  }
  if(!(columnToTakeValuesFrom %in% cnames)) {
    stop('replyr_moveValuesToColumns columnToTakeValuesFrom must be a data column name')
  }
  useAsChar <- TRUE
  isMySQL <- replyr_is_MySQL_data(data)
  if(isMySQL) {
    useAsChar <- FALSE
  }
  data %.>%
    replyr_uniqueValues(., columnToTakeKeysFrom) %.>%
    replyr_copy_from(., maxrow=maxcols) -> colStats
  valSupport <- sort(colStats[[columnToTakeKeysFrom]])
  newCols <- valSupport
  if(!is.null(sep)) {
    newCols <- paste(columnToTakeKeysFrom, newCols, sep=sep)
  }
  names(newCols) <- valSupport
  if(any(newCols %in% cnames)) {
    stop('replyr_moveValuesToColumns columnToTakeKeysFrom values must not include any data column names')
  }
  if(length(newCols)>maxcols) {
    stop("replyr_moveValuesToColumns too many new columns")
  }
  VCOL <- NULL # declare not unbound
  let(
    c(VCOL= columnToTakeValuesFrom),
    {
      data %.>%
        dplyr::filter(., !is.na(VCOL)) -> data # use absence instead of NA
      (data %.>%
         dplyr::summarize(., x=min(VCOL)) %.>%
         dplyr::collect(.))$x -> minV
    }
  )
  sentinelV <- NA
  if(is.numeric(minV)) {
    sentinelV <- minV - 0.1*minV - 1
  } else if(is.character(minV)) {
    # can fix this by padding strings on the left with a "V"
    if(minV=='') {
      stop("replyr_moveValuesToColumns can't currently handle blanks")
    }
    sentinelV <- ''
  } else {
    stop("replyr_moveValuesToColumns can only currently handle numeric or character data")
  }
  if(sentinelV>=minV) {
    stop("replyr_moveValuesToColumns failed to pick sentinel value")
  }
  mcols <- c(columnToTakeKeysFrom,columnToTakeValuesFrom)
  KCOL <- NULL # declare not unbound
  NEWCOL <- NULL # declare not unbound
  for(vi in names(newCols)) {
    ci <- newCols[[vi]]
    wrapr::let(
      c(NEWCOL=ci,
        KCOL=columnToTakeKeysFrom,
        VCOL=columnToTakeValuesFrom),
      data %.>%
        dplyr::mutate(., NEWCOL = ifelse(KCOL==vi, VCOL, sentinelV)) -> data
    )
    # Must call compute here or ci value changing changes mutate.
    # See issues/TrailingRefIssue.Rmd
    data <- compute(data, name= tempNameGenerator())
  }
  copyCols <- c(setdiff(cnames, mcols), newCols)
  data %.>%
    dplyr::select(., dplyr::one_of(copyCols)) -> data
  if(dosummarize) {
    if(length(rowKeyColumns)<=0) {
      data %.>%
        dplyr::summarize_all(., "max") -> data
    } else {
      # Right now this only works with single key column
      KEYCOLS <- NULL # declare not unbound
      wrapr::let(
        c(KEYCOLS= rowKeyColumns),
        data %.>%
          dplyr::group_by(., KEYCOLS) %.>%
          dplyr::summarize_all(., "max") -> data
      )
    }
  }
  # replace sentinel with NA
  for(ci in newCols) {
    wrapr::let(
      c(NEWCOL=ci),
      data %.>%
        dplyr::mutate(., NEWCOL = ifelse(NEWCOL==sentinelV, fill, NEWCOL)) -> data
    )
    # Must call compute here or ci value changing changes mutate.
    # See issues/TrailingRefIssue.Rmd
    data <- compute(data, name= tempNameGenerator())
  }
  data
}



# The use of db handles with dplyr is what is giving us a dplyr >= 0.7.0 dependency.


checkControlTable <- function(controlTable) {
  if(!is.data.frame(controlTable)) {
    return("control table must be a data.frame")
  }
  if(nrow(controlTable)<1) {
    return("control table must have at least 1 row")
  }
  if(ncol(controlTable)<1) {
    return("control table must have at least 1 column")
  }
  classes <- vapply(controlTable, class, character(1))
  if(!all(classes=='character')) {
    return("all control table columns must be character")
  }
  toCheck <- list(
    "value entries" = as.vector(as.matrix(controlTable[,2:ncol(controlTable)])),
    "column names" = colnames(controlTable),
    "group ids" = controlTable[, 1, drop=TRUE]
  )
  for(ci in names(toCheck)) {
    vals <- toCheck[[ci]]
    if(length(unique(vals))!=length(vals)) {
      return(paste("all control table", ci, "must be distinct"))
    }
    if(!all(vals==make.names(vals))) {
      return(paste("all control table", ci ,"must be valid R variable names"))
    }
  }
  return(NULL) # good
}

#' Map a set of columns to rows (query based).
#'
#' Transform data facts from columns into additional rows using SQL
#' and controlTable.
#'
#' This is using the theory of "fluid data"n
#' (\url{https://github.com/WinVector/cdata}), which includes the
#' principle that each data cell has coordinates independent of the
#' storage details and storage detail dependent coordinates (usually
#' row-id, column-id, and group-id) can be re-derived at will (the
#' other principle is that there may not be "one true preferred data
#' shape" and many re-shapings of data may be needed to match data to
#' different algorithms and methods).
#'
#' The controlTable defines the names of each data element in the two notations:
#' the notation of the tall table (which is row oriented)
#' and the notation of the wide table (which is column oriented).
#' controlTable[ , 1] (the group label) cross colnames(controlTable)
#' (the column labels) are names of data cells in the long form.
#' controlTable[ , 2:ncol(controlTable)] (column labels)
#' are names of data cells in the wide form.
#'
#' @param controlTable table specifying mapping (local data frame)
#' @param wideTableName name of table containing data to be mapped (db/Spark data)
#' @param my_db db handle
#' @param ... force later arguments to be by name.
#' @param columnsToCopy character list of column names to copy
#' @param tempNameGenerator a tempNameGenerator from replyr::makeTempNameGenerator()
#' @param showQuery if TRUE print query
#' @return long table built by mapping wideTable to one row per group
#'
#' @seealso \url{https://github.com/WinVector/cdata}, \code{\link[cdata]{moveValuesToRows}}, \code{\link[cdata]{moveValuesToColumns}}, \code{\link{moveValuesToRowsQ}}, \code{\link{moveValuesToColumnsQ}}
#'
#' @examples
#'
#' my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' wideTableName <- 'dat'
#' d <- dplyr::copy_to(my_db,
#'       dplyr::tribble(
#'         ~ID,          ~c1,          ~c2,          ~c3,          ~c4,
#'       'id1', 'val_id1_c1', 'val_id1_c2', 'val_id1_c3', 'val_id1_c4',
#'       'id2', 'val_id2_c1', 'val_id2_c2', 'val_id2_c3', 'val_id2_c4',
#'       'id3', 'val_id3_c1', 'val_id3_c2', 'val_id3_c3', 'val_id3_c4' ),
#'              wideTableName, overwrite = TRUE, temporary=TRUE)
#' controlTable <- dplyr::tribble(~group, ~col1, ~col2,
#'                                  'aa',  'c1',  'c2',
#'                                  'bb',  'c3',  'c4')
#' columnsToCopy <- 'ID'
#' moveValuesToRowsQ(controlTable,
#'                   wideTableName,
#'                   my_db,
#'                   columnsToCopy = columnsToCopy)
#' # # Source:   table<mvtrq_tnl6kueh5givlkobcl54_0000000001> [?? x 4]
#' # # Database: sqlite 3.19.3 [:memory:]
#' #      ID group       col1       col2
#' #   <chr> <chr>      <chr>      <chr>
#' # 1   id1    aa val_id1_c1 val_id1_c2
#' # 2   id1    bb val_id1_c3 val_id1_c4
#' # 3   id2    aa val_id2_c1 val_id2_c2
#' # 4   id2    bb val_id2_c3 val_id2_c4
#' # 5   id3    aa val_id3_c1 val_id3_c2
#' # 6   id3    bb val_id3_c3 val_id3_c4
#'
#' @export
#'
moveValuesToRowsQ <- function(controlTable,
                              wideTableName,
                              my_db,
                              ...,
                              columnsToCopy = NULL,
                              tempNameGenerator = replyr::makeTempNameGenerator('mvtrq'),
                              showQuery=FALSE) {
  if(length(list(...))>0) {
    stop("replyr::moveValuesToRowsQ unexpected arguments.")
  }
  controlTable <- as.data.frame(controlTable)
  cCheck <- checkControlTable(controlTable)
  if(!is.null(cCheck)) {
    stop(paste("replyr::moveValuesToRowsQ", cCheck))
  }
  ctabName <- tempNameGenerator()
  ctab <- copy_to(my_db, controlTable, ctabName,
                  overwrite = TRUE, temporary=TRUE)
  resName <- tempNameGenerator()
  casestmts <- vapply(2:ncol(controlTable),
                      function(j) {
                        whens <- vapply(seq_len(nrow(controlTable)),
                                        function(i) {
                                          paste0(' WHEN `b`.`',
                                                 colnames(controlTable)[1],
                                                 '` = "',
                                                 controlTable[i,1,drop=TRUE],
                                                 '" THEN `a`.`',
                                                 controlTable[i,j,drop=TRUE],
                                                 '`' )
                                        },
                                        character(1))
                        casestmt <- paste0('CASE ',
                                           paste(whens, collapse = ' '),
                                           ' ELSE NULL END AS `',
                                           colnames(controlTable)[j],
                                           '`')
                      },
                      character(1))
  copystmts <- NULL
  if(length(columnsToCopy)>0) {
    copystmts <- paste0('`a`.`', columnsToCopy, '`')
  }
  groupstmt <- paste0('`b`.`', colnames(controlTable)[1], '`')
  # deliberate cross join
  qs <-  paste0(" SELECT ",
                paste(c(copystmts, groupstmt, casestmts), collapse = ', '),
                ' FROM ',
                wideTableName,
                ' `a` CROSS JOIN `',
                ctabName,
                '` `b` ')
  q <-  paste0("CREATE TABLE `",
               resName,
               "` AS ",
               qs)
  if(showQuery) {
    print(q)
  }
  tryCatch(
    DBI::dbGetQuery(my_db, q),
    warning = function(w) { NULL })
  res <- tbl(my_db, resName)
  res
}



#' Map sets rows to columns (query based).
#'
#' Transform data facts from rows into additional columns using SQL
#' and controlTable.
#'
#' This is using the theory of "fluid data"n
#' (\url{https://github.com/WinVector/cdata}), which includes the
#' principle that each data cell has coordinates independent of the
#' storage details and storage detail dependent coordinates (usually
#' row-id, column-id, and group-id) can be re-derived at will (the
#' other principle is that there may not be "one true preferred data
#' shape" and many re-shapings of data may be needed to match data to
#' different algorithms and methods).
#'
#' The controlTable defines the names of each data element in the two notations:
#' the notation of the tall table (which is row oriented)
#' and the notation of the wide table (which is column oriented).
#' controlTable[ , 1] (the group label) cross colnames(controlTable)
#' (the column labels) are names of data cells in the long form.
#' controlTable[ , 2:ncol(controlTable)] (column labels)
#' are names of data cells in the wide form.
#'
#' @param keyColumns character list of column defining row groups
#' @param controlTable table specifying mapping (local data frame)
#' @param tallTableName name of table containing data to be mapped (db/Spark data)
#' @param my_db db handle
#' @param ... force later arguments to be by name.
#' @param columnsToCopy character list of column names to copy
#' @param tempNameGenerator a tempNameGenerator from replyr::makeTempNameGenerator()
#' @param showQuery if TRUE print query
#' @return wide table built by mapping key-grouped tallTable rows to one row per group
#'
#' @seealso \url{https://github.com/WinVector/cdata}, \code{\link[cdata]{moveValuesToRows}}, \code{\link[cdata]{moveValuesToColumns}}, \code{\link{moveValuesToRowsQ}}, \code{\link{moveValuesToColumnsQ}}
#'
#' @examples
#'
#' my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' tallTableName <- 'dat'
#' d <- dplyr::copy_to(my_db,
#'   dplyr::tribble(
#'    ~ID,   ~group, ~col1,              ~col2,
#'    "id1", "aa",   "val_id1_gaa_col1", "val_id1_gaa_col2",
#'    "id1", "bb",   "val_id1_gbb_col1", "val_id1_gbb_col2",
#'    "id2", "aa",   "val_id2_gaa_col1", "val_id2_gaa_col2",
#'    "id2", "bb",   "val_id2_gbb_col1", "val_id2_gbb_col2",
#'    "id3", "aa",   "val_id3_gaa_col1", "val_id3_gaa_col2",
#'    "id3", "bb",   "val_id3_gbb_col1", "val_id3_gbb_col2" ),
#'          tallTableName,
#'          overwrite = TRUE, temporary=TRUE)
#' controlTable <- dplyr::tribble(~group, ~col1, ~col2,
#'                                  'aa',  'c1',  'c2',
#'                                  'bb',  'c3',  'c4')
#' keyColumns <- 'ID'
#' moveValuesToColumnsQ(keyColumns,
#'                      controlTable,
#'                      tallTableName,
#'                      my_db)
#' # # Source:   table<mvtcq_y579atnjk3zevjqvkeok_0000000001> [?? x 5]
#' # # Database: sqlite 3.19.3 [:memory:]
#' #      ID               c1               c2               c3               c4
#' #   <chr>            <chr>            <chr>            <chr>            <chr>
#' # 1   id1 val_id1_gaa_col1 val_id1_gaa_col2 val_id1_gbb_col1 val_id1_gbb_col2
#' # 2   id2 val_id2_gaa_col1 val_id2_gaa_col2 val_id2_gbb_col1 val_id2_gbb_col2
#' # 3   id3 val_id3_gaa_col1 val_id3_gaa_col2 val_id3_gbb_col1 val_id3_gbb_col2
#'
#' @export
#'
moveValuesToColumnsQ <- function(keyColumns,
                                 controlTable,
                                 tallTableName,
                                 my_db,
                                 ...,
                                 columnsToCopy = NULL,
                                 tempNameGenerator = replyr::makeTempNameGenerator('mvtcq'),
                                 showQuery = FALSE) {
  if(length(list(...))>0) {
    stop("replyr::moveValuesToColumnsQ unexpected arguments.")
  }
  controlTable <- as.data.frame(controlTable)
  cCheck <- checkControlTable(controlTable)
  if(!is.null(cCheck)) {
    stop(paste("replyr::moveValuesToColumnsQ", cCheck))
  }
  ctabName <- tempNameGenerator()
  ctab <- copy_to(my_db, controlTable, ctabName,
                  overwrite = TRUE, temporary=TRUE)
  resName <- tempNameGenerator()
  collectstmts <- character(nrow(controlTable) * (ncol(controlTable)-1))
  collectN <- 1
  for(i in seq_len(nrow(controlTable))) {
    for(j in 2:ncol(controlTable)) {
      collectstmts[[collectN]] <- paste0("MAX( CASE WHEN ", # pseudo aggregator
                                         "`a`.`",
                                         colnames(controlTable)[[1]],
                                         "` = \"",
                                         controlTable[i,1,drop=TRUE],
                                         "\" THEN `a`.`",
                                         colnames(controlTable)[[j]],
                                         "`  ELSE NULL END ) `",
                                         controlTable[i,j,drop=TRUE],
                                         "`")
      collectN <- collectN + 1
    }
  }
  # pseudo-aggregators for columns we are copying
  # paste works on vectors in alligned fashion (not as a cross-product)
  copystmts <- NULL
  if(length(columnsToCopy)>0) {
    copystmts <- paste0('MAX(`a`.`', columnsToCopy, '`) `', columnsToCopy, '`')
  }
  groupterms <- paste0('`a`.`', keyColumns, '`')
  groupstmts  <- paste0('`a`.`', keyColumns, '` `', keyColumns, '`')
  # deliberate cross join
  qs <-  paste0(" SELECT ",
                paste(c(groupstmts, copystmts, collectstmts), collapse = ', '),
                ' FROM ',
                tallTableName,
                ' `a` GROUP BY ',
                paste(groupterms, collapse = ', '))
  q <-  paste0("CREATE TABLE `",
               resName,
               "` AS ",
               qs)
  if(showQuery) {
    print(q)
  }
  tryCatch(
    DBI::dbGetQuery(my_db, q),
    warning = function(w) { NULL })
  res <- tbl(my_db, resName)
  res
}






