# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.


#' Union two tables.
#'
#' Spark 2* union_all has issues ( https://github.com/WinVector/replyr/blob/master/issues/UnionIssue.md ),
#' and exponsed union_all semantics differ from data-source backend to backend.
#' This is an attempt to provide a join-based replacement.
#'
#'
#' @param tabA not-NULL table with at least 1 row.
#' @param tabB not-NULL table with at least 1 row on same data source as tabA and commmon columns.
#' @param ... force later arguments to be bound by name.
#' @param useDplyrLocal logical if TRUE use dplyr::bind_rows for local data.
#' @param useSparkRbind logical if TRUE try to use rbind on Sparklyr data
#' @param tempNameGenerator temp name generator produced by cdata::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return table with all rows of tabA and tabB (union_all).
#'
#' @examples
#'
#' d1 <- data.frame(x = c('a','b'), y = 1, stringsAsFactors= FALSE)
#' d2 <- data.frame(x = 'c', z = 1, stringsAsFactors= FALSE)
#' replyr_union_all(d1, d2, useDplyrLocal= FALSE)
#'
#' @export
replyr_union_all <- function(tabA, tabB,
                             ...,
                             useDplyrLocal= TRUE,
                             useSparkRbind= TRUE,
                             tempNameGenerator= makeTempNameGenerator("replyr_union_all")) {
  if(length(list(...))>0) {
    stop("replyr::replyr_union_all unexpected arguments.")
  }
  aHasRows <- replyr_hasrows(tabA)
  bHasRows <- replyr_hasrows(tabB)
  if(aHasRows) {
    tabA <- dplyr::ungroup(tabA)
  }
  if(bHasRows) {
    tabB <- dplyr::ungroup(tabB)
  }
  # work on some corners cases (being a bit more generous than the documentation)
  if((!aHasRows) && (!bHasRows)) {
    return(NULL)
  }
  if(!aHasRows) {
    return(tabB)
  }
  if(!bHasRows) {
    return(tabA)
  }
  # see if we can delegate
  if(useDplyrLocal && replyr_is_local_data(tabA)) {
    # local, can use dplyr
    return(dplyr::bind_rows(tabA, tabB))
  }
  if(useSparkRbind && replyr_is_Spark_data(tabA)) {
    # sparklyr (post '0.5.6', at least '0.5.6.9008')
    # has a new sdf_bind_rows function we could try to use on Spark sources
    # (limit columns first).
    # using existince of sparklyr::sdf_bind_rows as evidence that rbind
    # is correctly overloaded for sparklyr.
    if(requireNamespace('sparklyr', quietly = TRUE) &&
       exists('sdf_bind_rows', where=asNamespace('sparklyr'), mode='function')) {
      return(rbind(tabA, tabB))
    }
  }
  # build a new name disjoint from cols
  colsA <- colnames(tabA)
  colsB <- colnames(tabB)
  cols <- union(colsA, colsB)
  mapA <- colsA
  if(length(mapA)>0) {
    names(mapA) <- paste(colsA, 'a', sep='_')
  }
  mapB <- colsB
  if(length(mapB)) {
    names(mapB) <- paste(colsB, 'b', sep='_')
  }
  # build a 2-row table to control the union
  side_x <- NULL # declare not an unbound reference
  controlTable <- data.frame(side_x = c('a', 'b'),
                             stringsAsFactors = FALSE)
  if(!replyr_is_local_data(tabA)) {
    sc <- replyr_get_src(tabA)
    controlTable <- replyr_copy_to(sc, controlTable,
                                   name=tempNameGenerator(),
                                   temporary=TRUE)
  }
  # decorate left and right tables for the merge
  tabA <- tabA %.>%
    replyr_mapRestrictCols(., mapA) %.>%
    addConstantColumn(., 'side_x', 'a',
                      tempNameGenerator=tempNameGenerator)
  tabB <- tabB %.>%
    replyr_mapRestrictCols(., mapB) %.>%
    addConstantColumn(., 'side_x', 'b',
                      tempNameGenerator=tempNameGenerator)
  # do the merges
  joined <- controlTable %.>%
    left_join(., tabA, by='side_x') %.>%
    left_join(., tabB, by='side_x')
  # coalesce the values
  REPLYRCOLA <- NULL # mark as not an unbound reference
  REPLYRCOLB <- NULL # mark as not an unbound reference
  REPLYRORIGCOL <- NULL # mark as not an unbound reference
  REPLYRUNIONCOL <- NULL # mark as not an unbound reference
  for(ci in intersect(colsA, colsB)) {
    wrapr::let(
      c(REPLYRCOLA= paste0(ci,'_a'),
        REPLYRCOLB= paste0(ci,'_b'),
        REPLYRORIGCOL= ci),
      joined <- joined %.>%
        dplyr::mutate(., REPLYRORIGCOL =
                 ifelse(side_x=='a', REPLYRCOLA, REPLYRCOLB)) %.>%
        dplyr::select(., -REPLYRCOLA, -REPLYRCOLB)
    )
  }
  joined <- dplyr::select(joined, -side_x)
  # map remaining columns back
  uniqueToA <- setdiff(colsA, colsB)
  if(length(uniqueToA)>0) {
    names(uniqueToA) <- paste(uniqueToA, 'a', sep='_')
  }
  uniqueToB <- setdiff(colsB, colsA)
  if(length(uniqueToB)>0) {
    names(uniqueToB) <- paste(uniqueToB, 'b', sep='_')
  }
  mapBack <- c(uniqueToA, uniqueToB)
  if(length(mapBack)>0) {
    joined <- replyr_mapRestrictCols(joined,
                                     replyr_reverseMap(mapBack))
  }
  joined
}

# list length>=1 no null entries, doesn't return NULL
r_replyr_bind_rows <- function(lst,
                               eagerTempRemoval, atTopLevel,
                               privateTempNameGenerator,
                               publicTempNameGenerator) {
  n <- length(lst)
  if(n<=1) {
    if(n<=0) {
      stop("replyr:::r_replyr_bind_rows called with empty list")
    }
    res <- lst[[1]]
    return(res)
  }
  mid <- floor(n/2)
  leftSeq <- 1:mid      # n>=2 so mid>=1
  rightSeq <- (mid+1):n # n>=2 so mid+1<=n
  left <- r_replyr_bind_rows(lst[leftSeq],
                             eagerTempRemoval, FALSE,
                             privateTempNameGenerator, publicTempNameGenerator)
  right <- r_replyr_bind_rows(lst[rightSeq],
                              eagerTempRemoval, FALSE,
                              privateTempNameGenerator, publicTempNameGenerator)
  namesToNuke <- NULL
  if(eagerTempRemoval) {
    namesToNuke <- privateTempNameGenerator(dumpList=TRUE)
  }
  res <- replyr_union_all(left, right,
                          useDplyrLocal= FALSE,
                          useSparkRbind= FALSE,
                          tempNameGenerator= ifelse(atTopLevel ||
                                                      (!eagerTempRemoval),
                                                    publicTempNameGenerator,
                                                    privateTempNameGenerator))
  res <- dplyr::compute(res)
  if(length(namesToNuke)>0) {
    src <- replyr_get_src(left)
    for(ni in namesToNuke) {
      replyr_drop_table_name(src, ni)
    }
  }
  res
}


#' Bind a list of items by rows (can't use dplyr::bind_rows or dplyr::combine on remote sources).  Columns are intersected.
#'
#' Can't set \code{eagerTempRemoval=TRUE} on platforms that don't correctly implement \code{dplyr::compute}
#' (for instance \code{Sparklyr} prior to full resolution of \url{https://github.com/rstudio/sparklyr/issues/721}).
#'
#' @param lst list of items to combine, must be all in same dplyr data service
#' @param ... force other arguments to be used by name
#' @param useDplyrLocal logical if TRUE use dplyr for local data.
#' @param useSparkRbind logical if TRUE try to use rbind on Sparklyr data
#' @param useUnionALL logical if TRUE try to use union all binding
#' @param eagerTempRemoval logical if TRUE remove temps early.
#' @param tempNameGenerator temp name generator produced by cdata::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return single data item
#'
#' @examples
#'
#'
#' my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' # my_db <- sparklyr::spark_connect(master = "local")
#' d <- replyr_copy_to(my_db, data.frame(x = 1:2), 'd',
#'                     temporary = TRUE)
#' # dplyr::bind_rows(list(d, d))
#' # # Argument 1 must be a data frame or a named atomic vector, not a tbl_dbi/tbl_sql/tbl_lazy/tbl
#' replyr_bind_rows(list(d, d))
#'
#' @export
replyr_bind_rows <- function(lst,
                             ...,
                             useDplyrLocal= TRUE,
                             useSparkRbind= TRUE,
                             useUnionALL= TRUE,
                             eagerTempRemoval= FALSE,
                             tempNameGenerator= makeTempNameGenerator("replyr_bind_rows")) {
  if(length(list(...))>0) {
    stop("replyr::replyr_bind_rows unexpected arguments")
  }
  if(length(lst)<=1) {
    if(length(lst)<=0) {
      return(NULL)
    }
    return(lst[[1]])
  }
  # remove any nulls or trivial data items.
  lst <- Filter(function(ri) { replyr_hasrows(ri) }, lst)
  if(length(lst)<=1) {
    if(length(lst)<=0) {
      return(NULL)
    }
    return(lst[[1]])
  }
  names(lst) <- NULL
  if(useDplyrLocal && replyr_is_local_data(lst[[1]])) {
    # local, can use dplyr
    return(dplyr::bind_rows(lst))
  }
  if(useSparkRbind && replyr_is_Spark_data(lst[[1]])) {
    # sparklyr (post '0.5.6', at least '0.5.6.9008')
    # has a new sdf_bind_rows function we could try to use on Spark sources
    # (limit columns first).
    # using existince of sparklyr::sdf_bind_rows as evidence that rbind
    # is correctly overloaded for sparklyr.
    if(requireNamespace('sparklyr', quietly = TRUE) &&
       exists('sdf_bind_rows', where=asNamespace('sparklyr'), mode='function')) {
      return(do.call(rbind, lst))
    }
  }
  if(useUnionALL) {
    # assuming all tables on same source
    res <- lst[[1]]
    if(length(lst)>1) {
      for(i in 2:length(lst)) {
        res <- dplyr::union_all(res, lst[[i]])
      }
    }
    return(res)
  }
  # nasty recursive fall-back
  r_replyr_bind_rows(lst, eagerTempRemoval, TRUE,
                     makeTempNameGenerator("bind_rows_priv"),
                     tempNameGenerator)
}
