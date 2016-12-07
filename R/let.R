
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.
# Code adapted from gtools::strmacro by Gregory R. Warnes (License: GPL-2, this portion also available GPL-2 to respect gtools license).


# checking for valid unreserved names
# from: http://stackoverflow.com/questions/8396577/check-if-character-value-is-a-valid-r-object-name
isValidAndUnreservedName <- function(string) {
  make.names(string,unique = FALSE, allow_ = TRUE) == string
}


#' Prepare expr for execution with name substitutions specified in alias.
#'
#' Code adapted from \code{gtools::strmacro} by Gregory R. Warnes (License: GPL-2, this portion also available GPL-2 to respect gtools license).
#' Please see the \code{replyr} \code{vignette} for some discussion of let and crossing function call boundaries: \code{vignette('replyr','replyr')}.
#' Transformation is performed by substitution on the expression parse tree, so be wary of name collisions or aliasing.
#'
#' This statement implements a mapping from desired names (names used directly in the expr code) to names used in the data, as a consequence each desired name can only be mapped once.
#' Because of this directionality of mapping think in terms of "expr code symbols are on the left" and "external data and function argument names are on the right."
#'
#' Something like \code{replyr::let} is only useful to get control of a function that is parameterized
#' (in the sense it take column names) but non-standard (in that it takes column names from
#' non-standard evaluation argument name capture, and not as simple variables or parameters).  So  \code{replyr:let} is not
#' useful for non-parameterized functions (functions that work only over values such as \code{base::sum}),
#' and not useful for functions take parameters in straightforward way (such as \code{base::merge}'s "\code{by}" argument).
#' \code{dplyr::mutate} is an example where
#' we need a \code{replyr::let} helper; as it is
#' parameterized (in the sense it can work over user supplied columns), but column names are captured through non-standard evaluation.
#'
#' @seealso \code{\link{replyr_mapRestrictCols}}
#'
#' @param alias mapping from free names in expr to target names to use.
#' @param expr block to prepare for execution
#' @return item ready to evaluate, need to apply with "()" to perform the evaluation in own environment.
#'
#' @examples
#'
#' library('dplyr')
#' d <- data.frame(Sepal_Length=c(5.8,5.7),
#'                 Sepal_Width=c(4.0,4.4),
#'                 Species='setosa',
#'                 rank=c(1,2))
#'
#' mapping = list(RankColumn='rank',GroupColumn='Species')
#' let(alias=mapping,
#'     expr={
#'        # Notice code here can be written in terms of known or concrete
#'        # names "RankColumn" and "GroupColumn", but executes as if we
#'        # had written mapping specified columns "rank" and "Species".
#'        # restart ranks at zero.
#'        d %>% mutate(RankColumn=RankColumn-1) -> dres
#'        # confirm set of groups.
#'        unique(d$GroupColumn) -> groups
#'     })()
#' print(groups)
#' print(length(groups))
#' print(dres)
#'
#' # It is also possible to pipe into let-blocks, but it takes some extra notation
#' # (notice the extra ". %>%" at the beginning and the extra "()" at the end).
#'
#'d %>% let(alias=mapping,
#'          expr={
#'            . %>% mutate(RankColumn=RankColumn-1)
#'          })()()
#'
#' # Or:
#'
#' f <- let(alias=mapping,
#'          expr={
#'            . %>% mutate(RankColumn=RankColumn-1)
#'          })()
#' d %>% f
#'
#' # Be wary of using any assignment to attempt side-effects in these "delayed pipelines",
#' # as the assignment tends to happen during the let dereference and not (as one would hope)
#' # during the later pipeline application.  Example:
#'
#' g <- let(alias=mapping,
#'          expr={
#'            . %>% mutate(RankColumn=RankColumn-1) -> ZZZ
#'          })()
#' print(ZZZ)
#' # Notice ZZZ has captured a copy of the sub-pipeline and not waited for application of g.
#' # Applying g performs a calculation, but does not overwrite ZZZ.
#'
#' g(d)
#' print(ZZZ)
#' # Notice ZZZ is not a copy of g(d), but instead still the pipeline fragment.
#'
#'
#' @export
let <- function(alias, expr) {
  # Code adapted from gtools::strmacro by Gregory R. Warnes (License: GPL-2, this portion also available GPL-2 to respect gtools license).
  # capture expr
  strexpr <- deparse(substitute(expr))
  # make sure alias is a list (not a named vector)
  alias <- as.list(alias)
  # confirm alias is mapping strings to strings
  if(length(unique(names(alias)))!=length(names(alias))) {
    stop('replyr::let alias keys must be unique')
  }
  for(ni in names(alias)) {
    if(is.null(ni)) {
      stop('replyr:let alias keys must not be null')
    }
    if(!is.character(ni)) {
      stop('replyr:let alias keys must all be strings')
    }
    if(length(ni)!=1) {
      stop('replyr:let alias keys must all be strings')
    }
    if(nchar(ni)<=0) {
      stop('replyr:let alias keys must be empty string')
    }
    if(!isValidAndUnreservedName(ni)) {
      stop(paste('replyr:let alias key not a valid name: "',ni,'"'))
    }
    vi <- alias[[ni]]
    if(is.null(vi)) {
      stop('replyr:let alias values must not be null')
    }
    if(!is.character(vi)) {
      stop('replyr:let alias values must all be strings')
    }
    if(length(vi)!=1) {
      stop('replyr:let alias values must all be strings')
    }
    if(nchar(vi)<=0) {
      stop('replyr:let alias values must be empty string')
    }
    if(!isValidAndUnreservedName(vi)) {
      stop(paste('replyr:let alias value not a valid name: "',vi,'"'))
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
  ff <- function(...) {
    eval(fun, parent.frame())
  }
  # add annotations
  mm <- match.call()
  mm$expr <- NULL
  mm[[1]] <- as.name("let")
  attr(ff, "source") <- c(deparse(mm), strexpr)
  # return function for user to execute
  ff
}

