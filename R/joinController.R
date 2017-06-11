

uniqueInOrder <- function(names) {
  name <- NULL # declare not unbound reference
  rowid <- NULL # declare not unbound reference
  dn <- data.frame(name= names,
                   rowid= seq_len(length(names)),
                   stringsAsFactors = FALSE)
  dn <- dn %>%
    dplyr::group_by(name) %>%
    dplyr::summarize(rowid=min(rowid)) %>%
    dplyr::arrange(rowid)
  dn$name
}



makeTableIndMap <- function(tableNameSeq) {
  tableNameSeq <- uniqueInOrder(tableNameSeq)
  tableIndColNames <- paste('table',
                            gsub("[^a-zA-Z0-9]+", '_', tableNameSeq),
                            'present', sep= '_')
  names(tableIndColNames) <- tableNameSeq
  tableIndColNames
}


#' Build a nice description of a table.
#'
#' Please see \url{http://www.win-vector.com/blog/2017/05/managing-spark-data-handles-in-r/} for details.
#' Note: one usually needs to alter the keys column which is just populated with all columns.
#'
#'
#' @param tableName name of table to add to join plan.
#' @param handle table or table handle to add to join plan (can already be in the plan).
#' @return table describing the data.
#'
#' @examples
#'
#' d <- data.frame(x=1:3, y=NA)
#' tableDesription('d', d)
#'
#'
#' @export
#'
tableDesription <- function(tableName,
                            handle) {
  if(length(nchar(tableName))<=0) {
    stop("replyr::tableDesription empty name")
  }
  sample <- dplyr::collect(head(handle))
  cols <- colnames(sample)
  keys <- cols
  names(keys) <- cols
  tableIndColNames <- makeTableIndMap(tableName)
  if(length(intersect(tableIndColNames, cols))>0) {
    warning("replyr::tableDesription table_CLEANEDTABNAME_present column may cause problems (please consider renaming before these steps)")
  }
  dplyr::data_frame(tableName= tableName,
                    handle= list(handle),
                    columns= list(cols),
                    keys= list(keys),
                    isEmpty= nrow(sample)<=0)
}


#' Check uniqueness of rows with respect to keys.
#'
#' Can be an expensive operation.
#'
#' @param tDesc description of tables, from \code{\link{tableDesription}} (and likely altered by user).
#' @return logical TRUE if keys are unique
#'
#' @examples
#'
#' d <- data.frame(x=c(1,1,2,2,3,3), y=c(1,2,1,2,1,2))
#' tDesc1 <- tableDesription('d1', d)
#' tDesc2 <- tableDesription('d2', d)
#' tDesc <- rbind(tDesc1, tDesc2)
#' tDesc$keys[[2]] <- c(x='x')
#' keysAreUnique(tDesc)
#'
#' @export
#'
keysAreUnique <- function(tDesc) {
  n <- function(...) {} # declare not  unbound
  isunique <- vapply(seq_len(nrow(tDesc)),
                     function(i) {
                       gi <- tDesc$handle[[i]]
                       nrow <- replyr::replyr_nrow(gi)
                       if(nrow<=0) {
                         return(TRUE)
                       }
                       keys <- tDesc$keys[[i]]
                       nunique <- gi %>%
                         replyr_group_by(keys) %>%
                         dplyr::summarize(count = n()) %>%
                         replyr::replyr_nrow()
                       return(nunique==nrow)
                     },
                     logical(1))
  names(isunique) <- tDesc$tableName
  isunique
}

# type unstable: return data.frame if okay, character if problem
inspectAndLimitJoinPlan <- function(columnJoinPlan) {
  resultColumn <- NULL # declare not an unbound ref
  abstractKeyName <- NULL # declare not an unbound ref
  tableName <- NULL # declare not an unbound ref
  # sanity check
  if(any(nchar(columnJoinPlan$tableName)<=0)) {
    return("empty table name(s) in columnJoinPlan")
  }
  keyIdxs <- which(nchar(columnJoinPlan$abstractKeyName)>0)
  if(!all(columnJoinPlan$resultColumn[keyIdxs]==columnJoinPlan$abstractKeyName[keyIdxs])) {
    return("non-empty columnJoinPlan abstract keys must equal resultColumn")
  }
  tableIndColNames <- makeTableIndMap(columnJoinPlan$tableName)
  if(length(intersect(tableIndColNames,
                      c(columnJoinPlan$resultColumn, columnJoinPlan$sourceColumn)))>0) {
    return("executeLeftJoinPlan: column mappings intersect intended table label columns")
  }
  # limit down to things we are using
  columnJoinPlan <- columnJoinPlan %>%
    dplyr::filter((nchar(resultColumn)>0) | (nchar(abstractKeyName)>0))
  if(any(nchar(columnJoinPlan$sourceColumn)<=0)) {
    return("empty source column names")
  }
  tabsC <- unique(columnJoinPlan$tableName)
  # check a few desired invarients of the plan
  valCols <- columnJoinPlan$resultColumn[nchar(columnJoinPlan$abstractKeyName)<=0]
  if(length(unique(valCols))!=length(valCols)) {
    return("non-unique value columns")
  }
  keyCols <- unique(columnJoinPlan$abstractKeyName[nchar(columnJoinPlan$abstractKeyName)>0])
  if(length(intersect(keyCols, valCols))>0) {
    return("key columns and value columns intersect non-trivially")
  }
  tabs <- uniqueInOrder(columnJoinPlan$tableName)
  prevCI <- NULL
  for(tabnam in tabs) {
    ci <- columnJoinPlan[columnJoinPlan$tableName==tabnam, , drop=FALSE]
    if(!any(nchar(ci$abstractKeyName)>0)) {
      return(paste("no keys for table:", tabnam))
    }
    keyCols <- ci$abstractKeyName[nchar(ci$abstractKeyName)>0]
    resCols <- ci$resultColumn[nchar(ci$resultColumn)>0]
    if(length(setdiff(keyCols,resCols))>0) {
      return(paste("key cols not contained in result cols for table:", tabnam))
    }
    if(!is.null(prevCI)) {
      prevRes <- prevCI$resultColumn[nchar(prevCI$resultColumn)>0]
      if(length(setdiff(keyCols,prevRes))>0) {
        return(paste("key cols not contained in result cols of previous table for table:", tabnam))
      }
    }
    prevCI <- ci
  }
  columnJoinPlan
}

#' check that a join plan is consistent with table descriptions
#'
#' @param tDesc description of tables, from \code{\link{tableDesription}} (and likely altered by user).
#' @param columnJoinPlan columns to join, from \code{\link{buildJoinPlan}} (and likely altered by user). Note: no column names must intersect with names of the form \code{table_CLEANEDTABNAME_present}.
#' @return NULL if okay, else a string
#'
#' @examples
#'
#' # example data
#' d1 <- data.frame(id= 1:3,
#'                  weight= c(200, 140, 98),
#'                  height= c(60, 24, 12))
#' d2 <- data.frame(pid= 2:3,
#'                  weight= c(130, 110),
#'                  width= 1)
#' # get the initial description of table defs
#' tDesc <- rbind(tableDesription('d1', d1),
#'                tableDesription('d2', d2))
#' # declare keys (and give them consitent names)
#' tDesc$keys[[1]] <- list(PrimaryKey= 'id')
#' tDesc$keys[[2]] <- list(PrimaryKey= 'pid')
#' # build the join plan
#' columnJoinPlan <- buildJoinPlan(tDesc)
#' # damage the plan
#' columnJoinPlan$sourceColumn[columnJoinPlan$sourceColumn=='width'] <- 'wd'
#' # find a problem
#' inspectDescrAndJoinPlan(tDesc, columnJoinPlan)
#'
#' @export
#'
inspectDescrAndJoinPlan <- function(tDesc, columnJoinPlan) {
  resultColumn <- NULL # declare not an unbound ref
  abstractKeyName <- NULL # declare not an unbound ref
  tableName <- NULL # declare not an unbound ref
  # sanity check
  if(any(nchar(tDesc$tableName)<=0)) {
    return("empty table name(s) in tDesc")
  }
  if(any(nchar(columnJoinPlan$tableName)<=0)) {
    return("empty table name(s) in columnJoinPlan")
  }
  if(length(unique(tDesc$tableName)) != length(tDesc$tableName)) {
    return("non-unique table names in tDesc")
  }
  keyIdxs <- which(nchar(columnJoinPlan$abstractKeyName)>0)
  if(!all(columnJoinPlan$resultColumn[keyIdxs]==columnJoinPlan$abstractKeyName[keyIdxs])) {
    return("non-empty columnJoinPlan abstract keys must equal resultColumn")
  }
  tableIndColNames <- makeTableIndMap(columnJoinPlan$tableName)
  if(length(intersect(tableIndColNames,
                      c(columnJoinPlan$resultColumn, columnJoinPlan$sourceColumn)))>0) {
    return("columnJoinPlan mappings intersect intended table label columns")
  }
  # limit down to things we are using
  columnJoinPlan <- columnJoinPlan %>%
    dplyr::filter((nchar(resultColumn)>0) | (nchar(abstractKeyName)>0))
  if(any(nchar(columnJoinPlan$sourceColumn)<=0)) {
    return("empty source column names")
  }
  tabsC <- unique(columnJoinPlan$tableName)
  if(length(setdiff(tabsC, tDesc$tableName))>0) {
    return("tDesc does not have all the needed tables to join")
  }
  tDesc <- tDesc %>%
    dplyr::filter(tableName %in% tabsC)
  if( nrow(tDesc)<=0) {
    return("no tables selected")
  }
  tabsD <- unique(tDesc$tableName)
  columnJoinPlan <- columnJoinPlan %>%
    dplyr::filter(tableName %in% tabsD)
  # check a few desired invarients of the plan
  valCols <- columnJoinPlan$resultColumn[nchar(columnJoinPlan$abstractKeyName)<=0]
  if(length(unique(valCols))!=length(valCols)) {
    return("non-unique value columns")
  }
  keyCols <- unique(columnJoinPlan$abstractKeyName[nchar(columnJoinPlan$abstractKeyName)>0])
  if(length(intersect(keyCols, valCols))>0) {
    return("key columns and value columns intersect non-trivially")
  }
  for(i in seq_len(nrow(tDesc))) {
    tnam <- tDesc$tableName[[i]]
    ci <- columnJoinPlan %>%
      dplyr::filter(tableName==tnam)
    # don't check tDesc$keys here, as it isn't used after join plan is constructed.
    if(!all(ci$sourceColumn %in% tDesc$columns[[i]])) {
      return(paste("table",
                   tnam, "uses a source that is not a column"))
    }
  }
  res <- inspectAndLimitJoinPlan(columnJoinPlan)
  if(is.character(res)) {
    return(res)
  }
  return(NULL) # okay!
}



#' Build a join plan
#'
#' @param tDesc description of tables from \code{\link{tableDesription}} (and likely altered by user). Note: no column names must intersect with names of the form \code{table_CLEANEDTABNAME_present}.
#' @return detailed column join plan (appropriate for editing)
#'
#' @examples
#'
#' d <- data.frame(id=1:3, weight= c(200, 140, 98))
#' tDesc <- rbind(tableDesription('d1', d),
#'                tableDesription('d2', d))
#' tDesc$keys[[1]] <- list(PrimaryKey= 'id')
#' tDesc$keys[[2]] <- list(PrimaryKey= 'id')
#' buildJoinPlan(tDesc)
#'
#' @export
#'
buildJoinPlan <- function(tDesc) {
  n <- function(...) {} # declare not an unbound ref
  count <- NULL # declare not an unbound ref
  ntab <- nrow(tDesc)
  if(length(unique(tDesc$tableName))!=ntab) {
    stop("replyr::buildJoinPlan must have unique table name(s)")
  }
  if(any(nchar(tDesc$tableName)<=0)) {
    stop("replyr::buildJoinPlan empty table name(s)")
  }
  plans <- vector(ntab, mode='list')
  for(i in seq_len(ntab)) {
    cols <- tDesc$columns[[i]]
    keys <- tDesc$keys[[i]]
    tnam <- tDesc$tableName[[i]]
    if(length(cols)<=0) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "no columns"))
    }
    if(length(keys)<=0) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "no keys"))
    }
    if(any(nchar(keys)<=0)) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "empty key columns"))
    }
    if(length(unique(keys))!=length(keys)) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "declares duplicate key columns"))
    }
    if(any(nchar(names(keys))<=0)) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "empty key mappings"))
    }
    if(length(unique(names(keys)))!=length(names(keys))) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "declares duplicate key mappings"))
    }
    if(!all(keys %in% cols)) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "declares a key that is not a column"))
    }
    abstractKeyName <- rep("", length(cols))
    keyIndexes <- match(keys, cols)
    abstractKeyName[keyIndexes] <- names(keys)
    resultColumn= cols
    resultColumn[keyIndexes] <- names(keys)
    pi <- dplyr::data_frame(tableName= tnam,
                            sourceColumn= cols,
                            resultColumn= resultColumn,
                            abstractKeyName= abstractKeyName)
    plans[[i]] <- pi
  }
  plans <- dplyr::bind_rows(plans)
  # disambiguate non-key result columns
  dups <- plans %>%
    dplyr::filter(nchar(plans$abstractKeyName)<=0) %>%
    dplyr::select(resultColumn) %>%
    dplyr::group_by(resultColumn) %>%
    dplyr::summarize(count=n()) %>%
    dplyr::filter(count>1)
  if(nrow(dups)>0) {
    for(ci in dups$resultColumn) {
      indices <- which(plans$resultColumn==ci)
      for(i in indices) {
        ti <- gsub("[^a-zA-Z0-9]+", '_', plans$tableName[[i]])
        rc <- paste(ti, ci, sep= '_')
        plans$resultColumn[[i]] <- rc
      }
    }
  }
  # catch any remaining duplication
  nonKeyIndexes <- which(nchar(plans$abstractKeyName)<=0)
  plans$resultColumn[nonKeyIndexes] <- make.unique( plans$resultColumn[nonKeyIndexes],
                                                    sep= '_')
  # just in case
  problem <- inspectDescrAndJoinPlan(tDesc, plans)
  if(!is.null(problem)) {
    stop(paste("replyr::buildJoinPlan produced plan issue:",
               problem))
  }
  plans
}




#' Execute an ordered sequence of left joins.
#'
#' @param tDesc description of tables, from \code{\link{tableDesription}} only used to map table names to data.
#' @param columnJoinPlan columns to join, from \code{\link{buildJoinPlan}} (and likely altered by user).  Note: no column names must intersect with names of the form \code{table_CLEANEDTABNAME_present}.
#' @param ... force later arguments to bind by name.
#' @param checkColumns logical if TURE confirm column names before starting joins.
#' @param eagerCompute logical if TRUE materialize intermediate results with \code{dplyr::compute}.
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return joined table
#'
#' @examples
#'
#'
#' # example data
#' d1 <- data.frame(id= 1:3,
#'                  weight= c(200, 140, 98),
#'                  height= c(60, 24, 12))
#' d2 <- data.frame(pid= 2:3,
#'                  weight= c(130, 110),
#'                  width= 1)
#' # get the initial description of table defs
#' tDesc <- rbind(tableDesription('d1', d1),
#'                tableDesription('d2', d2))
#' # declare keys (and give them consitent names)
#' tDesc$keys[[1]] <- list(PrimaryKey= 'id')
#' tDesc$keys[[2]] <- list(PrimaryKey= 'pid')
#' # build the column join plan
#' columnJoinPlan <- buildJoinPlan(tDesc)
#' # decide we don't want the width column
#' columnJoinPlan$resultColumn[columnJoinPlan$resultColumn=='width'] <- ''
#' # double check our plan
#' if(!is.null(inspectDescrAndJoinPlan(tDesc, columnJoinPlan))) {
#'   stop("bad join plan")
#' }
#' # execute the left joins
#' executeLeftJoinPlan(tDesc, columnJoinPlan)
#'
#' @export
#'
#'
executeLeftJoinPlan <- function(tDesc, columnJoinPlan,
                                ...,
                                checkColumns= TRUE,
                                eagerCompute= TRUE,
                                tempNameGenerator= makeTempNameGenerator("executeLeftJoinPlan")) {
  # sanity check (if there is an obvious config problem fail before doing potentially expensive work)
  columnJoinPlan <- inspectAndLimitJoinPlan(columnJoinPlan)
  if(is.character(columnJoinPlan)) {
    stop(paste("replyr::executeLeftJoinPlan", columnJoinPlan))
  }
  if(length(unique(tDesc$tableName))!=length(tDesc$tableName)) {
    stop("replyr::executeLeftJoinPlan duplicate table names in tDesc")
  }
  if(!all(columnJoinPlan$tableName %in% tDesc$tableName)) {
    stop("replyr::executeLeftJoinPlan some needed columnJoinPlan table(s) not in tDesc")
  }
  # get the names of tables in columnJoinPlan order
  tableNameSeq <- uniqueInOrder(columnJoinPlan$tableName)
  tableIndColNames <- makeTableIndMap(tableNameSeq)
  if(length(intersect(tableIndColNames,
                      c(columnJoinPlan$resultColumn, columnJoinPlan$sourceColumn)))>0) {
    stop("executeLeftJoinPlan: column mappings intersect intended table label columns")
  }
  if(checkColumns) {
    for(tabnam in tableNameSeq) {
      handlei <- tDesc$handle[[which(tDesc$tableName==tabnam)]]
      newdesc <- tableDesription(tabnam, handlei)
      if(newdesc$isEmpty[[1]]) {
        warning(paste("replyr::executeLeftJoinPlan table is empty:",
                      tabnam))
      }
      tabcols <- newdesc$columns[[1]]
      tableIndCol <- tableIndColNames[[tabnam]]
      if(tableIndCol %in% tabcols) {
        stop(paste("replyr::executeLeftJoinPlan column",
                   tableIndCol, "already in table",
                   tabnam))
      }
      keyRows <- which((columnJoinPlan$tableName==tabnam) &
                         (nchar(columnJoinPlan$abstractKeyName)>0))
      valRows <- which((columnJoinPlan$tableName==tabnam) &
                         (nchar(columnJoinPlan$abstractKeyName)<=0) &
                         (nchar(columnJoinPlan$resultColumn)>0))
      needs <- c(columnJoinPlan$sourceColumn[keyRows],
                columnJoinPlan$sourceColumn[valRows])
      missing <- setdiff(needs, tabcols)
      if(length(missing)>0) {
        stop(paste("replyr::executeLeftJoinPlan table",
                   tabnam, "misisng needed columns",
                   paste(missing, collapse = ', ')))
      }
    }
  }
  # start joining
  res <- NULL
  for(tabnam in tableNameSeq) {
    handlei <- tDesc$handle[[which(tDesc$tableName==tabnam)]]
    keyRows <- which((columnJoinPlan$tableName==tabnam) &
      (nchar(columnJoinPlan$abstractKeyName)>0))
    valRows <- which((columnJoinPlan$tableName==tabnam) &
                       (nchar(columnJoinPlan$abstractKeyName)<=0) &
                       (nchar(columnJoinPlan$resultColumn)>0))
    tableIndCol <- tableIndColNames[[tabnam]]
    nmap <- c(tableIndCol,
              columnJoinPlan$sourceColumn[keyRows],
              columnJoinPlan$sourceColumn[valRows])
    names(nmap) <- c(tableIndCol,
                     columnJoinPlan$resultColumn[keyRows],
                     columnJoinPlan$resultColumn[valRows])
    # adding an indicator column lets us handle cases where we are taking
    # no values.
    ti <- handlei %>%
      addConstantColumn(tableIndCol, 1) %>%
      replyr_mapRestrictCols(nmap, restrict=TRUE)
    if(is.null(res)) {
      res <- ti
    } else {
      rightKeys <- columnJoinPlan$resultColumn[keyRows]
      res <- dplyr::left_join(res, ti, by= rightKeys)
      REPLYR_TABLE_PRESENT_COL <- NULL # signal not an unbound variable
      wrapr::let(
        c(REPLYR_TABLE_PRESENT_COL= tableIndCol),
        res <- dplyr::mutate(res, REPLYR_TABLE_PRESENT_COL =
                               ifelse(is.na(REPLYR_TABLE_PRESENT_COL), 0, 1))
      )
      if(eagerCompute) {
        res <- dplyr::compute(res, name=tempNameGenerator())
      }
    }
  }
  res
}
