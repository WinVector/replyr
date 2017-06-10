

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
  sample <- dplyr::collect(head(handle))
  cols <- colnames(sample)
  keys <- cols
  names(keys) <- cols
  dplyr::data_frame(tableName= tableName,
                    handle= list(handle),
                    columns= list(cols),
                    keys= list(keys))
}

#' Build a join plan
#'
#' @param tDesc description of tables from \code{\link{tableDesription}} (and likely altered by user).
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
  ntab <- nrow(tDesc)
  if(length(unique(tDesc$tableName))!=ntab) {
    stop("replyr::buildJoinPlan must have unique table names")
  }
  plans <- vector(ntab, mode='list')
  for(i in seq_len(ntab)) {
    cols <- tDesc$columns[[i]]
    keys <- tDesc$keys[[i]]
    tnam <- tDesc$tableName[[i]]
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
  nonKeyIndexes <- which(nchar(plans$abstractKeyName)<=0)
  saw <- list()
  for(i in nonKeyIndexes) {
    rc <- plans$resultColumn[[i]]
    if(rc %in% names(saw)) {
      ti <- gsub("[^a-zA-Z0-9]+", '_', plans$tableName[[i]])
      rc <- paste(ti, rc, sep= '_')
      plans$resultColumn[[i]] <- rc
    }
    saw[[rc]] <- i
  }
  # catch any remaining duplication
  plans$resultColumn[nonKeyIndexes] <- make.unique( plans$resultColumn[nonKeyIndexes],
                                                    sep= '_')
  plans
}

#' Execute a sequence of left joins.
#'
#' @param tDesc description of tables, from \code{\link{tableDesription}} (and likely altered by user).
#' @param columnJoinPlan columns to join, from \code{\link{buildJoinPlan}} (and likely altered by user).
#' @param ... force later arguments to bind by name.
#' @param eagerCompute logical if TRUE compute eager.
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return joined table
#'
#' @examples
#'
#' d1 <- data.frame(id=1:3, weight= c(200, 140, 98))
#' d2 <- data.frame(id=2:3, weight= c(130, 110))
#' tDesc <- rbind(tableDesription('d1', d1),
#'                tableDesription('d2', d2))
#' tDesc$keys[[1]] <- list(PrimaryKey= 'id')
#' tDesc$keys[[2]] <- list(PrimaryKey= 'id')
#' columnJoinPlan <- buildJoinPlan(tDesc)
#' executeLeftJoinPlan(tDesc, columnJoinPlan)
#'
#' @export
#'
#'
executeLeftJoinPlan <- function(tDesc, columnJoinPlan,
                                ...,
                                eagerCompute= TRUE,
                                tempNameGenerator= makeTempNameGenerator("executeLeftJoinPlan")) {
  tabs <- unique(columnJoinPlan$tableName)
  if(length(setdiff(tabs, tDesc$tableName))>0) {
    stop("replyr::executeJoinPlan tDesc does not have all the needed tables to join")
  }
  tDesc <- tDesc %>%
    dplyr::filter(tableName %in% tabs)
  ntab <- nrow(tDesc)
  if(ntab<=0) {
    stop("replyr::executeJoinPlan no tables selected")
  }
  res <- NULL
  for(i in seq_len(ntab)) {
    tabnam <- tDesc$tableName[[i]]
    keyRows <- which((columnJoinPlan$tableName==tabnam) &
      (nchar(columnJoinPlan$abstractKeyName)>0))
    valRows <- which((columnJoinPlan$tableName==tabnam) &
                       (nchar(columnJoinPlan$abstractKeyName)<=0) &
                       (nchar(columnJoinPlan$resultColumn)>0))
    tableIndCol <- paste('table',
                         gsub("[^a-zA-Z0-9]+", '_', tabnam),
                         'present', sep= '_')
    nmap <- c(tableIndCol,
              columnJoinPlan$sourceColumn[keyRows],
              columnJoinPlan$sourceColumn[valRows])
    names(nmap) <- c(tableIndCol,
                     columnJoinPlan$resultColumn[keyRows],
                     columnJoinPlan$resultColumn[valRows])
    ti <- tDesc$handle[[i]] %>%
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
        res <- dplyr::mutate(res, REPLYR_TABLE_PRESENT_COL = ifelse(is.na(REPLYR_TABLE_PRESENT_COL), 0, 1))
      )
      if(eagerCompute) {
        res <- dplyr::compute(res, name=tempNameGenerator())
      }
    }
  }
  res
}
