
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' Prepare expr for execution with name substitions specified in alias.
#'
#' Code adapted from \code{gtools::strmacro} by Gregory R. Warnes (License: GPL-2, this portion also available GPL-2 to respect gtools license).
#' Pleaes see the \code{replyr} \code{vignette} for some discussion of let and crossing function call boundaries: \code{vignette('replyr','replyr')}.
#' Transformation is performed by substition on the function parse tree, so be wary of name collisions or aliasing.
#' This statement implements a mapping from desired names (names used as columns in the data) to names used in the expr code block, as a consequence each desired name can only be mapped once.
#' @seealso \code{\link{replyr_renameRestrictCols}}
#'
#' @param alias mapping from free names in expr to target names to use.
#' @param expr block to prepare for execution
#' @return item ready to evaluate, need to apply with "()" to perform the evaluation in own environemnt.
#'
#' @examples
#'
#' library('dplyr')
#' d <- data.frame(Sepal_Length=c(5.8,5.7),
#'                 Sepal_Width=c(4.0,4.4),
#'                 Species='setosa',
#'                 rank=c(1,2))
#' printMyArgumentName <- function(x,...) {
#'   print(paste("I think my arguments were: x=",x,
#'      ", (",names(list(...)),")=(",list(...),")"))
#' }
#'
#' mapping = list(RankColumn='rank',GroupColumn='Species',
#'                Sepal_Length='x',Sepal_Width='y')
#' let(alias=mapping,
#'     expr={
#'        # Notice code here can be written in terms of known or concrete
#'        # names "RankColumn" and "GroupColumn", but executes as if we
#'        # had written mapping specified columns "rank" and "Species".
#'        # restart ranks at zero.
#'        d %>% mutate(RankColumn=RankColumn-1) -> dres
#'        # confirm set of groups.
#'        unique(d$GroupColumn) -> groups
#'        # look directly at names.
#'        printMyArgumentName(Sepal_Length=7,Sepal_Width=5)
#'     })()
#' print(groups)
#' print(length(groups))
#' print(dres)
#'
#' @export
let <- function(alias, expr) {
  # capture expr
  strexpr <- deparse(substitute(expr))
  # make sure alias is a list (not a named vector)
  alias <- as.list(alias)
  # confirm alias is mapping strings to strings
  if(length(unique(names(alias)))!=length(names(alias))) {
    stop('replyr::let alias keys must be unique')
  }
  for(ni in names(alias)) {
    if(!is.character(ni)) {
      stop('replyr:let alias keys must all be strings')
    }
    if(length(ni)!=1) {
      stop('replyr:let alias keys must all be strings')
    }
    vi <- alias[[ni]]
    if(!is.character(vi)) {
      stop('replyr:let alias values must all be strings')
    }
    if(length(vi)!=1) {
      stop('replyr:let alias values must all be strings')
    }
  }
  # re-write the parse tree and prepare for execution
  body <- strexpr
  for (ni in names(alias)) {
    pattern <- paste0("\\b", ni, "\\b")
    value <- alias[[ni]]
    body <- gsub(pattern, value, body)
  }
  fun <- parse(text = body)
  # wrap re-mapped expr for execution
  ff <- function() {
    eval(fun, parent.frame())
  }
  # add annotations
  formals(ff) <- alias
  mm <- match.call()
  mm$expr <- NULL
  mm[[1]] <- as.name("let")
  attr(ff, "source") <- c(deparse(mm), strexpr)
  # return zero-argument function for user to execute
  ff
}

