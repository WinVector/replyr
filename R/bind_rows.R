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
#' @param cols list of column names to limit to (defaults to intersection), must be non-empty and contained in intersection.
#' @param useLocalMethod logical if TRUE use dplyr for local data.
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return table with all rows of tabA and tabB (union_all).
#'
#' @examples
#'
#' d1 <- data.frame(x = c('a','b'), stringsAsFactors= FALSE)
#' d2 <- data.frame(x = 'c', stringsAsFactors= FALSE)
#' replyr_union_all(d1, d2, useLocalMethod= FALSE)
#'
#' @export
replyr_union_all <- function(tabA, tabB, ...,
                             cols= NULL,
                             useLocalMethod= TRUE,
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
  if((!aHasRows) && (!bHasRows)) {
    return(NULL)
  }
  # work on some corners cases (being a bit more generous than the documentation)
  if(!aHasRows) {
    if(!is.null(cols)) {
      return(tabB %>% select(one_of(cols)))
    }
    return(tabB)
  }
  if(!bHasRows) {
    if(!is.null(cols)) {
      return(tabA %>% select(one_of(cols)))
    }
    return(tabA)
  }
  if(is.null(cols)) {
    cols <- intersect(colnames(tabA), colnames(tabB))
  }
  if(length(cols)<=0) {
    stop("replyr::replyr_union_all empty column list")
  }
  if(useLocalMethod && replyr_is_local_data(tabA)) {
    # local, can use dplyr
    return(dplyr::bind_rows(select(tabA, one_of(cols)) ,
                            select(tabB, one_of(cols))))
  }
  # build a new name disjoint from cols
  mergeColName <- setdiff(
    paste('REPLYRUNIONCOL', seq_len(length(cols)+1),sep= '_'),
    cols)[[1]]
  # build a 2-row table to control the union
  controlTable <- data.frame(REPLYRUNIONCOL= c('a', 'b'),
                             stringsAsFactors = FALSE)
  colnames(controlTable) <- mergeColName
  if(!replyr_is_local_data(tabA)) {
    sc <- replyr_get_src(tabA)
    controlTable <- replyr_copy_to(sc, controlTable,
                                   name=tempNameGenerator(),
                                   temporary=TRUE)
  }
  # decorate left and right tables for the merge
  tabA <- tabA %>%
    select(one_of(cols)) %>%
    addConstantColumn(mergeColName, 'a',
                      tempNameGenerator=tempNameGenerator)
  tabB <- tabB %>%
    select(one_of(cols)) %>%
    addConstantColumn(mergeColName, 'b',
                      tempNameGenerator=tempNameGenerator)
  # do the merges
  joined <- controlTable %>%
    left_join(tabA, by=mergeColName) %>%
    left_join(tabB, by=mergeColName, suffix = c('_a', '_b'))
  # coalesce the values
  REPLYRCOLA <- NULL # mark as not an unbound reference
  REPLYRCOLB <- NULL # mark as not an unbound reference
  REPLYRORIGCOL <- NULL # mark as not an unbound reference
  REPLYRUNIONCOL <- NULL # mark as not an unbound reference
  for(ci in cols) {
    wrapr::let(
      c(REPLYRCOLA= paste0(ci,'_a'),
        REPLYRCOLB= paste0(ci,'_b'),
        REPLYRORIGCOL= ci,
        REPLYRUNIONCOL= mergeColName),
      joined <- joined %>%
        mutate(REPLYRORIGCOL = ifelse(REPLYRUNIONCOL=='a', REPLYRCOLA, REPLYRCOLB))
    )
  }
  joined %>%
    select(one_of(cols)) %>%
    dplyr::compute(name=tempNameGenerator())
}

# list length>=1 no null entries, doesn't return NULL
r_replyr_bind_rows <- function(lst, colnames,
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
  left <- r_replyr_bind_rows(lst[leftSeq], colnames,
                             eagerTempRemoval, FALSE,
                             privateTempNameGenerator, publicTempNameGenerator)
  right <- r_replyr_bind_rows(lst[rightSeq], colnames,
                              eagerTempRemoval, FALSE,
                              privateTempNameGenerator, publicTempNameGenerator)
  namesToNuke <- NULL
  if(eagerTempRemoval) {
    namesToNuke <- privateTempNameGenerator(dumpList=TRUE)
  }
  res <- replyr_union_all(left, right,
                          cols= colnames,
                          useLocalMethod= FALSE,
                          tempNameGenerator= ifelse(atTopLevel ||
                                                      (!eagerTempRemoval),
                                                    publicTempNameGenerator,
                                                    privateTempNameGenerator))
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
#' @param eagerTempRemoval logical if TRUE remove temps early.
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return single data item
#'
#' @examples
#'
#' d <- data.frame(x=1:2)
#' replyr_bind_rows(list(d,d,d,d,d))
#'
#' @export
replyr_bind_rows <- function(lst,
                             ...,
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
  colnames <- Reduce(intersect, lapply(lst, colnames))
  if(length(colnames)<=0) {
    stop("replyr::replyr_bind_rows no common columns")
  }
  r_replyr_bind_rows(lst, colnames, eagerTempRemoval, TRUE,
                     makeTempNameGenerator("bind_rows_priv"),
                     tempNameGenerator)
}
