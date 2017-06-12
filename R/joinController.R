

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
  classes <- vapply(cols,
                    function(si) {
                      paste(class(sample[[si]]),
                                  collapse=', ')
                    }, character(1))
  source <- replyr_get_src(handle)
  if(!is.character(source)) {
    source <- class(source)
  }
  if(length(source)>1) {
    source <- paste(source, collapse = ', ')
  }
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
                    colClass= list(classes),
                    sourceClass= source,
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
inspectAndLimitJoinPlan <- function(columnJoinPlan, checkColClasses) {
  # sanity check
  for(ci in c('tableName', 'sourceColumn', 'sourceClass', 'resultColumn')) {
    if(is.null(columnJoinPlan[[ci]])) {
      return(paste('columnJoinPlan column', ci, 'not present'))
    }
    if(!is.character(columnJoinPlan[[ci]])) {
      return(paste('columnJoinPlan column', ci, 'should be of type character'))
    }
    if(any(nchar(columnJoinPlan[[ci]])<=0) ||
       any(is.na(columnJoinPlan))) {
      return(paste("empty or NA', ci, ' colum in columnJoinPlan"))
    }
  }
  for(ci in c('isKey','want')) {
    if(is.null(columnJoinPlan[[ci]])) {
      return(paste('columnJoinPlan column', ci, 'not present'))
    }
    if(!is.logical(columnJoinPlan[[ci]])) {
      return(paste('columnJoinPlan column', ci, 'should be of type logical'))
    }
    if(any(is.na(columnJoinPlan))) {
      return(paste("NA', ci, ' colum in columnJoinPlan"))
    }
  }
  if(any(columnJoinPlan$isKey & (!columnJoinPlan$want))) {
    return("any row marked isKey must also be marked want")
  }
  valCols <- columnJoinPlan$resultColumn[!columnJoinPlan$isKey]
  if(length(valCols) !=
     length(unique(valCols))) {
    return("columnJoinPlan result columns must be unique")
  }
  tabs <-  uniqueInOrder(columnJoinPlan$tableName)
  for(tabnam in tabs) {
    ci <- columnJoinPlan[columnJoinPlan$tableName==tabnam, , drop=FALSE]
    if(length(ci$sourceColumn) !=
       length(unique(ci$sourceColumn))) {
      return(paste("columnJoinPlan sourceColumns not unique for table",
                   ci))
    }
    if(sum(ci$isKey)<=0) {
      return("no keys for table", tabnam)
    }
  }
  tableIndColNames <- makeTableIndMap(columnJoinPlan$tableName)
  tabNOverlap <- intersect(tableIndColNames,
                           c(columnJoinPlan$resultColumn, columnJoinPlan$sourceColumn))
  if(length(tabNOverlap)>0) {
    return(paste("column source or result names intersect table present columns:",
                 paste(tabNOverlap, collapse = ', ')))

  }
  # limit down to things we are using
  columnJoinPlan <- columnJoinPlan[columnJoinPlan$want, , drop=FALSE]
  # check a few desired invarients of the plan
  prevResColClasses <- list()
  for(tabnam in tabs) {
    ci <- columnJoinPlan[columnJoinPlan$tableName==tabnam, , drop=FALSE]
    cMap <- ci$sourceClass
    names(cMap) <- ci$resultColumn
    keyCols <- ci$resultColumn[ci$isKey]
    resCols <- ci$resultColumn[ci$want]
    if(length(prevResColClasses)>0) {
      missedKeys <- setdiff(keyCols, names(prevResColClasses))
      if(length(missedKeys)>0) {
        return(paste("key col(s) (",
                     paste(missedKeys, collapse = ', '),
                     ") not contained in result cols of previous table(s) for table:", tabnam))
      }
    }
    for(ki in resCols) {
      prevClass <- prevResColClasses[[ki]]
      curClass <- cMap[[ki]]
      if((checkColClasses)&&(!is.null(prevClass))&&
         (curClass!=prevClass)) {
        return(paste("column",ki,"changed from",
                     prevClass,"to",curClass,"at table",
                     tabnam))

      }
      prevResColClasses[[ki]] <- curClass
    }
  }
  columnJoinPlan
}

#' check that a join plan is consistent with table descriptions
#'
#' @param tDesc description of tables, from \code{\link{tableDesription}} (and likely altered by user).
#' @param columnJoinPlan columns to join, from \code{\link{buildJoinPlan}} (and likely altered by user). Note: no column names must intersect with names of the form \code{table_CLEANEDTABNAME_present}.
#' @param ... force later arguments to bind by name.
#' @param checkColClasses logical if true check for exact class name matches
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
#' # confirm the plan
#' inspectDescrAndJoinPlan(tDesc, columnJoinPlan,
#'                         checkColClasses= TRUE)
#' # damage the plan
#' columnJoinPlan$sourceColumn[columnJoinPlan$sourceColumn=='width'] <- 'wd'
#' # find a problem
#' inspectDescrAndJoinPlan(tDesc, columnJoinPlan,
#'                         checkColClasses= TRUE)
#'
#' @export
#'
inspectDescrAndJoinPlan <- function(tDesc, columnJoinPlan,
                                    ...,
                                    checkColClasses= FALSE) {
  columnJoinPlan <- inspectAndLimitJoinPlan(columnJoinPlan,
                                 checkColClasses=checkColClasses)
  if(is.character(columnJoinPlan)) {
    return(columnJoinPlan)
  }
  # sanity check
  if(length(unique(tDesc$tableName)) != length(tDesc$tableName)) {
    return("non-unique table names in tDesc")
  }
  # limit down to things we are using
  tabsC <- unique(columnJoinPlan$tableName)
  if(length(setdiff(tabsC, tDesc$tableName))>0) {
    return("tDesc does not have all the needed tables to join")
  }
  tDesc <- tDesc[tDesc$tableName %in% tabsC, , drop=FALSE]
  if( nrow(tDesc)<=0) {
    return("no tables selected")
  }
  tabsD <- unique(tDesc$tableName)
  columnJoinPlan <- columnJoinPlan[columnJoinPlan$tableName %in% tabsD, ,
                                   drop=FALSE]
  # check a few desired invarients of the plan
  for(i in seq_len(nrow(tDesc))) {
    tnam <- tDesc$tableName[[i]]
    ci <- columnJoinPlan[columnJoinPlan$tableName==tnam, , drop=FALSE]
    # don't check tDesc$keys here, as it isn't used after join plan is constructed.
    if(!all(ci$sourceColumn %in% tDesc$columns[[i]])) {
      probs <- paste(setdiff(ci$sourceColumn, tDesc$columns[[i]]),
                     collapse = ', ')
      return(paste("table description",
                   tnam, "refers to non-column(s):",probs))
    }
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
    classes <- tDesc$colClass[[i]]
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
    isKey <- rep(FALSE, length(cols))
    keyIndexes <- match(keys, cols)
    isKey[keyIndexes] <- TRUE
    resultColumn= cols
    resultColumn[keyIndexes] <- names(keys)
    pi <- dplyr::data_frame(tableName= tnam,
                            sourceColumn= cols,
                            sourceClass= classes,
                            resultColumn= resultColumn,
                            isKey= isKey,
                            want= TRUE)
    plans[[i]] <- pi
  }
  plans <- dplyr::bind_rows(plans)
  # disambiguate non-key result columns
  dups <- plans %>%
    dplyr::filter(!isKey) %>%
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
  nonKeyIndexes <- which(!plans$isKey)
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


charArrayToString <- function(v) {
  vl <- vapply(v,
         function(vi) {
           paste0("'", vi, "'")
         },
         character(1))
  vs <- paste(vl, collapse= ', ')
  paste('c(', vs, ')')
}

strMapToString <- function(m) {
  vl <- vapply(names(m),
               function(ni) {
                 paste0("'", ni, "'='",m[[ni]],"'")
               },
               character(1))
  vs <- paste(vl, collapse= ', ')
  paste('c(', vs, ')')
}


#' Execute an ordered sequence of left joins.
#'
#' @param tDesc description of tables, from \code{\link{tableDesription}} only used to map table names to data.
#' @param columnJoinPlan columns to join, from \code{\link{buildJoinPlan}} (and likely altered by user).  Note: no column names must intersect with names of the form \code{table_CLEANEDTABNAME_present}.
#' @param ... force later arguments to bind by name.
#' @param checkColumns logical if TURE confirm column names before starting joins.
#' @param eagerCompute logical if TRUE materialize intermediate results with \code{dplyr::compute}.
#' @param checkColClasses logical if true check for exact class name matches
#' @param verbose logical if TRUE print more.
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return joined table
#'
#' @examples
#'
#'
#' # example data
#' meas1 <- data.frame(id= c(1,2),
#'                     weight= c(200, 120),
#'                     height= c(60, 14))
#' meas2 <- data.frame(pid= c(2,3),
#'                     weight= c(105, 110),
#'                     width= 1)
#' # get the initial description of table defs
#' tDesc <- rbind(tableDesription('meas1', meas1),
#'                tableDesription('meas2', meas2))
#' # declare keys (and give them consitent names)
#' tDesc$keys[[1]] <- list(PatientID= 'id')
#' tDesc$keys[[2]] <- list(PatientID= 'pid')
#' # build the column join plan
#' columnJoinPlan <- buildJoinPlan(tDesc)
#' # decide we don't want the width column
#' columnJoinPlan$want[columnJoinPlan$resultColumn=='width'] <- FALSE
#' # double check our plan
#' if(!is.null(inspectDescrAndJoinPlan(tDesc, columnJoinPlan,
#'             checkColClasses= TRUE))) {
#'   stop("bad join plan")
#' }
#' # execute the left joins
#' executeLeftJoinPlan(tDesc, columnJoinPlan,
#'                     checkColClasses= TRUE,
#'                     verbose= TRUE)
#'
#' @export
#'
#'
executeLeftJoinPlan <- function(tDesc, columnJoinPlan,
                                ...,
                                checkColumns= FALSE,
                                eagerCompute= TRUE,
                                checkColClasses= FALSE,
                                verbose= FALSE,
                                tempNameGenerator= makeTempNameGenerator("executeLeftJoinPlan")) {
  # sanity check (if there is an obvious config problem fail before doing potentially expensive work)
  columnJoinPlan <- inspectAndLimitJoinPlan(columnJoinPlan,
                                            checkColClasses=checkColClasses)
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
                         (columnJoinPlan$isKey))
      valRows <- which((columnJoinPlan$tableName==tabnam) &
                         (!columnJoinPlan$isKey) &
                         (columnJoinPlan$want))
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
    if(verbose) {
      print(paste('start',tabnam, base::date()))
    }
    handlei <- tDesc$handle[[which(tDesc$tableName==tabnam)]]
    keyRows <- which((columnJoinPlan$tableName==tabnam) &
      (columnJoinPlan$isKey))
    valRows <- which((columnJoinPlan$tableName==tabnam) &
                       (columnJoinPlan$want) &
                       (!columnJoinPlan$isKey))
    tableIndCol <- tableIndColNames[[tabnam]]
    nmap <- c(tableIndCol,
              columnJoinPlan$sourceColumn[keyRows],
              columnJoinPlan$sourceColumn[valRows])
    names(nmap) <- c(tableIndCol,
                     columnJoinPlan$resultColumn[keyRows],
                     columnJoinPlan$resultColumn[valRows])
    # adding an indicator column lets us handle cases where we are taking
    # no values.
    if(verbose) {
      print(paste(" rename/restrict", tabnam))
      #print(paste(" ",strMapToString(nmap)))
      for(ni in names(nmap)) {
        print(paste0("   '",ni,"' = '",nmap[[ni]],"'"))
      }
    }
    ti <- handlei %>%
      addConstantColumn(tableIndCol, 1) %>%
      replyr_mapRestrictCols(nmap, restrict=TRUE)
    if(eagerCompute) {
      ti <-  dplyr::compute(ti, name=tempNameGenerator())
    }
    if(is.null(res)) {
      res <- ti
      if(verbose) {
        print(paste0(" res <- ", tabnam))
      }
    } else {
      rightKeys <- columnJoinPlan$resultColumn[keyRows]
      if(verbose) {
        print(paste0(" res <- left_join(res, ", tabnam, ", by = ",
                    charArrayToString(rightKeys),
                    ")"))
      }
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
    if(verbose) {
      print(paste('done',tabnam, base::date()))
    }
  }
  res
}
