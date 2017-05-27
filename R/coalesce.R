
#' Augment a data frame by adding additional rows.
#'
#' Note: do not count on order of resulting data.  Also only added rows
#' are altered by the fill instructions.
#'
#' @param data data.frame data to augment
#' @param support data.frame rows of unique key-values into data
#' @param ... not used, force later arguments to bind by name
#' @param fills list default values to fill in columns
#' @param newRowColumn character if not null name to use for new row indicator
#' @param copy logical if TRUE copy support to data's source
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return augmented data
#'
#' @examples
#'
#'
#' # single column key example
#' data <- data.frame(year = c(2005,2007,2010),
#'                    count = c(6,1,NA),
#'                    name = c('a','b','c'),
#'                    stringsAsFactors = FALSE)
#' support <- data.frame(year=2005:2010)
#' filled <- replyr_coalesce(data, support,
#'                           fills=list(count=0))
#' filled <- filled[order(filled$year), ]
#' filled
#'
#' # complex key example
#' data <- data.frame(year = c(2005,2007,2010),
#'                    count = c(6,1,NA),
#'                    name = c('a','b','c'),
#'                    stringsAsFactors = FALSE)
#' support <- expand.grid(year=2005:2010,
#'                    name= c('a','b','c','d'),
#'                    stringsAsFactors = FALSE)
#' filled <- replyr_coalesce(data, support,
#'                           fills=list(count=0))
#' filled <- filled[order(filled$year, filled$name), ]
#' filled
#'
#' @export
#'
replyr_coalesce <- function(data, support,
                            ...,
                            fills= NULL,
                            newRowColumn= NULL,
                            copy= TRUE,
                            tempNameGenerator= makeTempNameGenerator("replyr_coalesce")) {
  if(length(list(...))>0) {
    stop("replyr::replyr_coalesce unexpected arugments")
  }
  data <- dplyr::ungroup(data)
  dataCols <- colnames(data)
  joinCols <- colnames(support)
  if(length(joinCols)<=0) {
    stop("replyr::replyr_coalesce support must have columns")
  }
  if(length(setdiff(joinCols, dataCols))>0) {
    stop("replyr::replyr_coalesce data cols must be a superset of support columns")
  }
  if(length(setdiff(names(fills), dataCols))>0) {
    stop("replyr::replyr_coalesce fill columns must be a subset of data columns")
  }
  if(length(intersect(names(fills), joinCols))>0) {
    stop("replyr::replyr_coalesce fill columns must not overlap key columns")
  }
  if(copy && (!replyr_is_local_data(data)) && (replyr_is_local_data(support))) {
    cn <- replyr_get_src(data)
    support <- replyr_copy_to(cn, support, tempNameGenerator(),
                              temporary = TRUE)
  }
  replyr_private_name_additions <- dplyr::anti_join(support, data,
                                                    by=joinCols)
  if( (replyr_nrow(data)+replyr_nrow(replyr_private_name_additions)) != replyr_nrow(support)) {
    stop("replyr::replyr_coalesce support is not a unique set of keys for data")
  }
  if(!is.null(newRowColumn)) {
    let(list(NEWROWCOL=newRowColumn),
        data <- dplyr::mutate(data, NEWROWCOL= FALSE)
    )
  }
  if(replyr_nrow(replyr_private_name_additions)<=0) {
    return(data)
  }
  for(ci in dataCols) {
    if(!(ci %in% joinCols)) {
      if(ci %in% names(fills)) {
        replyr_private_name_additions <-
          addConstantColumn(replyr_private_name_additions,
                            ci, fills[[ci]],
                            tempNameGenerator=tempNameGenerator)
      } else {
        replyr_private_name_additions <-
          addConstantColumn(replyr_private_name_additions,
                            ci, NA,
                            tempNameGenerator=tempNameGenerator)
      }
      # force calculation as chaning of replyr_private_name_vi was chaning previously assigned columns!
      # needed to work around this: https://github.com/WinVector/replyr/blob/master/issues/TrailingRefIssue.md
      replyr_private_name_additions <- dplyr::compute(replyr_private_name_additions,
                                                      name= tempNameGenerator())
    }
  }
  if(!is.null(newRowColumn)) {
    let(list(NEWROWCOL=newRowColumn),
        replyr_private_name_additions <- dplyr::mutate(replyr_private_name_additions, NEWROWCOL= TRUE)
    )
  }
  # Can't use dplyr::bind_rows see https://github.com/WinVector/replyr/blob/master/issues/BindIssue.md
  res <- replyr::replyr_bind_rows(list(data, replyr_private_name_additions),
                                  tempNameGenerator=tempNameGenerator)
  res
}
