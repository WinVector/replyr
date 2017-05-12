# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.



#' Union two tables.
#'
#' Spark 2* union_all has issues ( https://github.com/WinVector/replyr/blob/master/issues/UnionIssue.md ),
#' and exponsed union_all semantics differ from data-source backend to backend.
#' This is an attempt to provide a join-based replacement.
#' NOT YET TESTED.
#'
#' @param tabA table with at least 1 row.
#' @param tabB table with at least on same data source as tabA and commmon columns.
#' @param ... force later arguments to be bound by name.
#' @param cols list of column names to limit to (defaults to intersection), must be non-empty and contained in intersection.
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return table with all rows of tabA and tabB (union_all).
#'
#' @examples
#'
#' d1 <- data.frame(x=c('a','b'))
#' d2 <- data.frame(x='c')
#' replyr_union_all(d1, d2)
#'
#' @export
replyr_union_all <- function(tabA, tabB, ...,
                             cols= NULL,
                             tempNameGenerator= makeTempNameGenerator("replyr_union_all")) {
  if(length(list(...))>0) {
    stop("replyr::replyr_union_all unexpected arguments.")
  }
  if(replyr_nrow(tabA)<1) {
    return(tabB)
  }
  if(replyr_nrow(tabB)<1) {
    return(tabA)
  }
  if(is.null(cols)) {
    cols <- intersect(colnames(tabA), colnames(tabB))
  }
  if(length(cols)<=0) {
    stop("replyr::replyr_union_all empty column list")
  }
  sc <- replyr_get_src(tabA)
  if((is.null(sc))||(is.character(sc))) {
    # local, can use dplyr
    return(dplyr::bind_rows(select(tabA, one_of(cols)) ,
                            select(tabB, one_of(cols))))
  }
  mergeColName <- 'replyrunioncol'
  if(mergeColName %in% cols) {
    stop(paste0("replyr::replyr_union_all sorry can't work with ",
                mergeColName,
                ' in table column names.'))
  }
  # build a 2-row table to control the union
  controlTable <- data.frame(replyrunioncol= c('a', 'b'),
                             stringsAsFactors = FALSE)
  controlTable <- dplyr::copy_to(sc, controlTable, name=tempNameGenerator())
  # decorate left and right tables for the merge
  tabA <- tabA %>%
    select(one_of(cols)) %>%
    mutate(replyrunioncol= 'a')
  tabB <- tabB %>%
    select(one_of(cols)) %>%
    mutate(replyrunioncol= 'b')
  # do the merges
  joined <- controlTable %>%
    left_join(tabA, by=mergeColName) %>%
    left_join(tabB, by=mergeColName, suffix = c('_a', '_b'))
  # coalesce the values
  REPLYRCOLA <- NULL # mark as not an unbound reference
  REPLYRCOLB <- NULL # mark as not an unbound reference
  REPLYRORIGCOL <- NULL # mark as not an unbound reference
  replyrunioncol <- NULL # mark as not an unbound reference
  for(ci in cols) {
    wrapr::let(
      c(REPLYRCOLA= paste0(ci,'_a'),
        REPLYRCOLB= paste0(ci,'_b'),
        REPLYRORIGCOL = ci),
      joined <- joined %>%
        mutate(REPLYRORIGCOL = ifelse(replyrunioncol=='a', REPLYRCOLA, REPLYRCOLB))
    )
  }
  joined %>%
    select(one_of(cols)) %>%
    dplyr::compute(name=tempNameGenerator())
}

# list length>=1 no null entries
r_replyr_bind_rows <- function(lst, colnames, tempNameGenerator) {
  n <- length(lst)
  if(n<=1) {
    res <- lst[[1]]
    res <- dplyr::compute(res,
                          name= tempNameGenerator())
    return(res)
  }
  mid <- floor(n/2)
  leftSeq <- 1:mid      # n>=2 so mid>=1
  rightSeq <- (mid+1):n # n>=2 so mid+1<=n
  left <- r_replyr_bind_rows(lst[leftSeq], colnames, tempNameGenerator)
  right <- r_replyr_bind_rows(lst[rightSeq], colnames, tempNameGenerator)
  replyr_union_all(left, right,
                   cols= colnames,
                   tempNameGenerator= tempNameGenerator)
}


#' bind a list of items by rows (can't use dplyr::bind_rows or dplyr::combine on remote sources)
#'
#' @param lst list of items to combine, must be all in same dplyr data service
#' @param ... force other arguments to be used by name
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return single data item
#'
#' @examples
#'
#' d <- data.frame(x=1:2)
#' replyr_bind_rows(list(d,d,d))
#'
#' @export
replyr_bind_rows <- function(lst,
                             ...,
                             tempNameGenerator= makeTempNameGenerator("replyr_bind_rows")) {
  if(length(list(...))>0) {
    stop("replyr::replyr_bind_rows unexpected arguments")
  }
  if(("NULL" %in% class(lst))||(length(lst)<=0)) {
    return(NULL)
  }
  # remove any nulls or trivial data items.
  lst <- Filter(function(ri) { replyr_nrow(ri)>0 }, lst)
  if(length(lst)<=0) {
    return(NULL)
  }
  names(lst) <- NULL
  colnames <- Reduce(intersect, lapply(lst, colnames))
  if(length(colnames)<=0) {
    return(NULL)
  }
  r_replyr_bind_rows(lst, colnames, tempNameGenerator)
}
