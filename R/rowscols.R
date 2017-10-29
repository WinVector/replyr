
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr select mutate one_of
#' @importFrom wrapr %.>% let mapsyms
#' @importFrom seplyr group_by_se
#' @importFrom cdata moveValuesToRows moveValuesToColumns
NULL



# The use of db handles with dplyr is what is giving us a dplyr >= 0.7.0 dependency.


# confirm control table has uniqueness
checkControlTable <- function(controlTable, strict) {
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
    "column names" = colnames(controlTable),
    "group ids" = controlTable[, 1, drop=TRUE]
  )
  for(ci in names(toCheck)) {
    vals <- toCheck[[ci]]
    if(any(is.na(vals))) {
      return(paste("all control table", ci, "must not be NA"))
    }
    if(length(unique(vals))!=length(vals)) {
      return(paste("all control table", ci, "must be distinct"))
    }
    if(strict) {
      if(length(grep(".", vals, fixed=TRUE))>0) {
        return(paste("all control table", ci ,"must '.'-free"))
      }
      if(!all(vals==make.names(vals))) {
        return(paste("all control table", ci ,"must be valid R variable names"))
      }
    }
  }
  return(NULL) # good
}



#' Build a moveValuesToColumnsQ() control table that specifies a un-pivot.
#'
#' Some discussion and examples can be found here:
#' \url{https://winvector.github.io/replyr/articles/FluidData.html} and
#' here \url{https://github.com/WinVector/cdata}.
#'
#' @param nameForNewKeyColumn character name of column to write new keys in.
#' @param nameForNewValueColumn character name of column to write new values in.
#' @param columnsToTakeFrom character array names of columns to take values from.
#' @param ... not used, force later args to be by name
#' @return control table
#'
#' @seealso \code{\link[cdata]{moveValuesToRows}}, \code{\link{moveValuesToRowsQ}}
#'
#' @examples
#'
#' buildUnPivotControlTable("measurmentType", "measurmentValue", c("c1", "c2"))
#'
#' @export
buildUnPivotControlTable <- function(nameForNewKeyColumn,
                                     nameForNewValueColumn,
                                     columnsToTakeFrom,
                                     ...) {
  if(length(list(...))>0) {
    stop("replyr::buildUnPivotControlTable unexpected arguments.")
  }
  controlTable <- data.frame(x = as.character(columnsToTakeFrom),
                             y = as.character(columnsToTakeFrom),
                             stringsAsFactors = FALSE)
  colnames(controlTable) <- c(nameForNewKeyColumn, nameForNewValueColumn)
  controlTable
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
#' To get behavior similar to tidyr::gather/spread one build the control table
#' by running an appropiate query over the data.
#'
#' Some discussion and examples can be found here:
#' \url{https://winvector.github.io/replyr/articles/FluidData.html} and
#' here \url{https://github.com/WinVector/cdata}.
#'
#' @param controlTable table specifying mapping (local data frame)
#' @param wideTableName name of table containing data to be mapped (db/Spark data)
#' @param my_db db handle
#' @param ... force later arguments to be by name.
#' @param columnsToCopy character list of column names to copy
#' @param tempNameGenerator a tempNameGenerator from replyr::makeTempNameGenerator()
#' @param strict logical, if TRUE check control table contents for uniqueness
#' @param checkNames logical, if TRUE check names
#' @param showQuery if TRUE print query
#' @return long table built by mapping wideTable to one row per group
#'
#' @seealso \code{\link[cdata]{moveValuesToRows}}, \code{\link{buildUnPivotControlTable}}, \code{\link{moveValuesToColumnsQ}}
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
                              strict = TRUE,
                              checkNames = TRUE,
                              showQuery=FALSE) {
  if(length(list(...))>0) {
    stop("replyr::moveValuesToRowsQ unexpected arguments.")
  }
  if(length(columnsToCopy)>0) {
    if(!is.character(columnsToCopy)) {
      stop("moveValuesToRowsQ: columnsToCopy must be character")
    }
  }
  if((!is.character(wideTableName))||(length(wideTableName)!=1)) {
    stop("moveValuesToRowsQ: wideTableName must be character length 1")
  }
  controlTable <- as.data.frame(controlTable)
  cCheck <- checkControlTable(controlTable, strict)
  if(!is.null(cCheck)) {
    stop(paste("replyr::moveValuesToRowsQ", cCheck))
  }
  if(checkNames) {
    interiorCells <- as.vector(as.matrix(controlTable[,2:ncol(controlTable)]))
    interiorCells <- interiorCells[!is.na(interiorCells)]
    wideTableColnames <- colnames(dplyr::tbl(my_db, wideTableName))
    badCells <- setdiff(interiorCells, wideTableColnames)
    if(length(badCells)>0) {
      stop(paste("replyr::moveValuesToRowsQ: control table entries that are not wideTable column names:",
                 paste(badCells, collapse = ', ')))
    }
  }
  ctabName <- tempNameGenerator()
  ctab <- copy_to(my_db, controlTable, ctabName,
                  overwrite = TRUE, temporary=TRUE)
  resName <- tempNameGenerator()
  casestmts <- lapply(2:ncol(controlTable),
                      function(j) {
                        whens <- lapply(seq_len(nrow(controlTable)),
                                        function(i) {
                                          cij <- controlTable[i,j,drop=TRUE]
                                          if(is.null(cij) || is.na(cij)) {
                                            return(NULL)
                                          }
                                          paste0(' WHEN b.',
                                                 DBI::dbQuoteIdentifier(my_db, colnames(controlTable)[1]),
                                                 ' = ',
                                                 DBI::dbQuoteString(my_db, controlTable[i,1,drop=TRUE]),
                                                 ' THEN a.',
                                                 DBI::dbQuoteIdentifier(my_db, cij))
                                        })
                        whens <- as.character(Filter(function(x) { !is.null(x) },
                                                     whens))
                        if(length(whens)<=0) {
                          return(NULL)
                        }
                        casestmt <- paste0('CASE ',
                                           paste(whens, collapse = ' '),
                                           ' ELSE NULL END AS ',
                                           DBI::dbQuoteIdentifier(my_db, colnames(controlTable)[j]))
                      })
  casestmts <- as.character(Filter(function(x) { !is.null(x) },
                                   casestmts))
  copystmts <- NULL
  if(length(columnsToCopy)>0) {
    copystmts <- paste0('a.', DBI::dbQuoteIdentifier(my_db, columnsToCopy))
  }
  groupstmt <- paste0('b.', DBI::dbQuoteIdentifier(my_db, colnames(controlTable)[1]))
  # deliberate cross join
  qs <-  paste0(" SELECT ",
                paste(c(copystmts, groupstmt, casestmts), collapse = ', '),
                ' FROM ',
                DBI::dbQuoteIdentifier(my_db, wideTableName),
                ' a CROSS JOIN ',
                DBI::dbQuoteIdentifier(my_db, ctabName),
                ' b ')
  q <-  paste0("CREATE TABLE ",
               DBI::dbQuoteIdentifier(my_db, resName),
               " AS ",
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

#' Build a moveValuesToColumnsQ() control table that specifies a pivot.
#'
#' Some discussion and examples can be found here: \url{https://winvector.github.io/replyr/articles/FluidData.html}.
#'
#' @param d data to scan for new column names
#' @param columnToTakeKeysFrom character name of column build new column names from.
#' @param columnToTakeValuesFrom character name of column to get values from.
#' @param ... not used, force later args to be by name
#' @param prefix column name prefix (only used when sep is not NULL)
#' @param sep separator to build complex column names.
#' @return control table
#'
#' @seealso \url{https://github.com/WinVector/cdata}, \code{\link[cdata]{moveValuesToRows}}, \code{\link[cdata]{moveValuesToColumns}}, \code{\link{moveValuesToRowsQ}}, \code{\link{moveValuesToColumnsQ}}
#'
#' @examples
#'
#' d <- data.frame(measType = c("wt", "ht"),
#'                 measValue = c(150, 6),
#'                 stringsAsFactors = FALSE)
#' buildPivotControlTable(d, 'measType', 'measValue', sep='_')
#'
#' @export
buildPivotControlTable <- function(d,
                                   columnToTakeKeysFrom,
                                   columnToTakeValuesFrom,
                                   ...,
                                   prefix = columnToTakeKeysFrom,
                                   sep = NULL) {
  if(length(list(...))>0) {
    stop("replyr::buildPivotControlTable unexpected arguments.")
  }
  # don't let n() look like unboudn fn
  n <- function(...) { NULL }
  wrapr::let(wrapr::mapsyms(columnToTakeKeysFrom, columnToTakeValuesFrom),
      {
        controlTable <- d %.>%
          dplyr::group_by(., columnToTakeKeysFrom) %.>%
          dplyr::summarize(., count = n()) %.>%
          dplyr::ungroup(.) %.>%
          dplyr::select(., columnToTakeKeysFrom) %.>%
          dplyr::mutate(., columnToTakeKeysFrom = as.character(columnToTakeKeysFrom)) %.>%
          dplyr::mutate(., columnToTakeValuesFrom = columnToTakeKeysFrom) %.>%
          dplyr::select(., columnToTakeKeysFrom, columnToTakeValuesFrom)  %.>%
          dplyr::collect(.) %.>%
          as.data.frame(.)
        if(!is.null(sep)) {
          controlTable$columnToTakeValuesFrom <- paste(prefix,
                                                       controlTable$columnToTakeValuesFrom,
                                                       sep=sep)
        }
        controlTable
      })
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
#' To get behavior similar to tidyr::gather/spread one build the control table
#' by running an appropiate query over the data.
#'
#' Some discussion and examples can be found here:
#' \url{https://winvector.github.io/replyr/articles/FluidData.html} and
#' here \url{https://github.com/WinVector/cdata}.
#'
#' @param keyColumns character list of column defining row groups
#' @param controlTable table specifying mapping (local data frame)
#' @param tallTableName name of table containing data to be mapped (db/Spark data)
#' @param my_db db handle
#' @param ... force later arguments to be by name.
#' @param columnsToCopy character list of column names to copy
#' @param tempNameGenerator a tempNameGenerator from replyr::makeTempNameGenerator()
#' @param strict logical, if TRUE check control table contents for uniqueness
#' @param checkNames logical, if TRUE check names
#' @param showQuery if TRUE print query
#' @return wide table built by mapping key-grouped tallTable rows to one row per group
#'
#' @seealso \code{\link[cdata]{moveValuesToColumns}}, \code{\link{moveValuesToRowsQ}}, \code{\link{buildPivotControlTable}}
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
                                 strict = TRUE,
                                 checkNames = TRUE,
                                 showQuery = FALSE) {
  if(length(list(...))>0) {
    stop("replyr::moveValuesToColumnsQ unexpected arguments.")
  }
  if(length(keyColumns)>0) {
    if(!is.character(keyColumns)) {
      stop("moveValuesToColumnsQ: keyColumns must be character")
    }
  }
  if(length(columnsToCopy)>0) {
    if(!is.character(columnsToCopy)) {
      stop("moveValuesToColumnsQ: columnsToCopy must be character")
    }
  }
  if((!is.character(tallTableName))||(length(tallTableName)!=1)) {
    stop("moveValuesToColumnsQ: tallTableName must be character length 1")
  }
  controlTable <- as.data.frame(controlTable)
  cCheck <- checkControlTable(controlTable, strict)
  if(!is.null(cCheck)) {
    stop(paste("replyr::moveValuesToColumnsQ", cCheck))
  }
  if(checkNames) {
    tallTableColnames <- colnames(dplyr::tbl(my_db, tallTableName))
    badCells <- setdiff(colnames(controlTable), tallTableColnames)
    if(length(badCells)>0) {
      stop(paste("replyr::moveValuesToColumnsQ: control table column names that are not tallTableName column names:",
                 paste(badCells, collapse = ', ')))
    }
  }
  ctabName <- tempNameGenerator()
  ctab <- copy_to(my_db, controlTable, ctabName,
                  overwrite = TRUE, temporary=TRUE)
  resName <- tempNameGenerator()
  collectstmts <- vector(mode = 'list',
                         length = nrow(controlTable) * (ncol(controlTable)-1))
  collectN <- 1
  for(i in seq_len(nrow(controlTable))) {
    for(j in 2:ncol(controlTable)) {
      cij <- controlTable[i,j,drop=TRUE]
      if((!is.null(cij))&&(!is.na(cij))) {
        collectstmts[[collectN]] <- paste0("MAX( CASE WHEN ", # pseudo aggregator
                                           "a.",
                                           DBI::dbQuoteIdentifier(my_db, colnames(controlTable)[[1]]),
                                           " = ",
                                           DBI::dbQuoteString(my_db, controlTable[i,1,drop=TRUE]),
                                           " THEN a.",
                                           DBI::dbQuoteIdentifier(my_db, colnames(controlTable)[[j]]),
                                           " ELSE NULL END ) ",
                                           DBI::dbQuoteIdentifier(my_db, cij))
      }
      collectN <- collectN + 1
    }
  }
  # turn non-nulls into an array
  collectstmts <- as.character(Filter(function(x) { !is.null(x) },
                                      collectstmts))
  # pseudo-aggregators for columns we are copying
  # paste works on vectors in alligned fashion (not as a cross-product)
  copystmts <- NULL
  if(length(columnsToCopy)>0) {
    copystmts <- paste0('MAX(a.',
                        DBI::dbQuoteIdentifier(my_db, columnsToCopy),
                        ') ',
                        DBI::dbQuoteIdentifier(my_db, columnsToCopy))
  }
  groupterms <- NULL
  groupstmts <- NULL
  if(length(keyColumns)>0) {
    groupterms <- paste0('a.', DBI::dbQuoteIdentifier(my_db, keyColumns))
    groupstmts <- paste0('a.',
                         DBI::dbQuoteIdentifier(my_db, keyColumns),
                         ' ',
                         DBI::dbQuoteIdentifier(my_db, keyColumns))
  }
  # deliberate cross join
  qs <-  paste0(" SELECT ",
                paste(c(groupstmts, copystmts, collectstmts), collapse = ', '),
                ' FROM ',
                DBI::dbQuoteIdentifier(my_db, tallTableName),
                ' a ')
  if(length(groupstmts)>0) {
    qs <- paste0(qs,
                 'GROUP BY ',
                 paste(groupterms, collapse = ', '))
  }
  q <-  paste0("CREATE TABLE ",
               DBI::dbQuoteIdentifier(my_db, resName),
               " AS ",
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






