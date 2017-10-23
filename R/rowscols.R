
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr select mutate one_of
#' @importFrom wrapr %.>%
#' @importFrom seplyr group_by_se
#' @importFrom cdata moveValuesToRows moveValuesToColumns
NULL



# The use of db handles with dplyr is what is giving us a dplyr >= 0.7.0 dependency.


# confirm control table has uniqueness
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
#' To get behavior similar to tidyr::gather/spread one build the control table
#' by running an appropiate query over the data.
#'
#' @param controlTable table specifying mapping (local data frame)
#' @param wideTableName name of table containing data to be mapped (db/Spark data)
#' @param my_db db handle
#' @param ... force later arguments to be by name.
#' @param columnsToCopy character list of column names to copy
#' @param tempNameGenerator a tempNameGenerator from replyr::makeTempNameGenerator()
#' @param strict logical, if TRUE check control table contents for uniqueness
#' @param showQuery if TRUE print query
#' @param literalQuote character, quote for string literals
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
                              strict = FALSE,
                              showQuery=FALSE,
                              literalQuote = "'") {
  if(length(list(...))>0) {
    stop("replyr::moveValuesToRowsQ unexpected arguments.")
  }
  controlTable <- as.data.frame(controlTable)
  if(strict) {
    cCheck <- checkControlTable(controlTable)
    if(!is.null(cCheck)) {
      stop(paste("replyr::moveValuesToRowsQ", cCheck))
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
                                          paste0(' WHEN `b`.`',
                                                 colnames(controlTable)[1],
                                                 '` = ',
                                                 literalQuote, controlTable[i,1,drop=TRUE], literalQuote,
                                                 ' THEN `a`.`',
                                                 cij,
                                                 '`' )
                                        })
                        whens <- as.character(Filter(function(x) { !is.null(x) },
                                                     whens))
                        if(length(whens)<=0) {
                          return(NULL)
                        }
                        casestmt <- paste0('CASE ',
                                           paste(whens, collapse = ' '),
                                           ' ELSE NULL END AS `',
                                           colnames(controlTable)[j],
                                           '`')
                      })
  casestmts <- as.character(Filter(function(x) { !is.null(x) },
                                   casestmts))
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
#' To get behavior similar to tidyr::gather/spread one build the control table
#' by running an appropiate query over the data.
#'
#' @param keyColumns character list of column defining row groups
#' @param controlTable table specifying mapping (local data frame)
#' @param tallTableName name of table containing data to be mapped (db/Spark data)
#' @param my_db db handle
#' @param ... force later arguments to be by name.
#' @param columnsToCopy character list of column names to copy
#' @param tempNameGenerator a tempNameGenerator from replyr::makeTempNameGenerator()
#' @param strict logical, if TRUE check control table contents for uniqueness
#' @param showQuery if TRUE print query
#' @param literalQuote character, quote for string literals
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
                                 strict = FALSE,
                                 showQuery = FALSE,
                                 literalQuote = "'") {
  if(length(list(...))>0) {
    stop("replyr::moveValuesToColumnsQ unexpected arguments.")
  }
  controlTable <- as.data.frame(controlTable)
  if(strict) {
    cCheck <- checkControlTable(controlTable)
    if(!is.null(cCheck)) {
      stop(paste("replyr::moveValuesToColumnsQ", cCheck))
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
                                           "`a`.`",
                                           colnames(controlTable)[[1]],
                                           "` = ",
                                           literalQuote, controlTable[i,1,drop=TRUE], literalQuote,
                                           " THEN `a`.`",
                                           colnames(controlTable)[[j]],
                                           "`  ELSE NULL END ) `",
                                           cij,
                                           "`")
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
    copystmts <- paste0('MAX(`a`.`', columnsToCopy, '`) `', columnsToCopy, '`')
  }
  groupterms <- NULL
  groupstmts <- NULL
  if(length(keyColumns)>0) {
    groupterms <- paste0('`a`.`', keyColumns, '`')
    groupstmts <- paste0('`a`.`', keyColumns, '` `', keyColumns, '`')
  }
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






