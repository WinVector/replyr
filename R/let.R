
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.
# Code adapted from gtools::strmacro by Gregory R. Warnes (License: GPL-2, this portion also available GPL-2 to respect gtools license).


# checking for valid unreserved names
# from: http://stackoverflow.com/questions/8396577/check-if-character-value-is-a-valid-r-object-name
isValidAndUnreservedName <- function(string) {
  make.names(string,unique = FALSE, allow_ = TRUE) == string
}


#' Execute expr with name substitutions specified in alias.
#'
#' \code{let} implements a mapping from desired names (names used directly in the expr code) to names used in the data.
#' Mnemonic: "expr code symbols are on the left, external data and function argument names are on the right."
#'
#'
#'
#' Code adapted from \code{gtools::strmacro} by Gregory R. Warnes (License: GPL-2, this portion also available GPL-2 to respect gtools license).
#' Please see the \code{replyr} \code{vignette} for some discussion of let and crossing function call boundaries: \code{vignette('replyr','replyr')}.
#' Transformation is performed by substitution on the expression parse tree, so be wary of name collisions or aliasing.
#'
#' Something like \code{let} is only useful to get control of a function that is parameterized
#' (in the sense it take column names) but non-standard (in that it takes column names from
#' non-standard evaluation argument name capture, and not as simple variables or parameters).  So  \code{replyr:let} is not
#' useful for non-parameterized functions (functions that work only over values such as \code{base::sum}),
#' and not useful for functions take parameters in straightforward way (such as \code{base::merge}'s "\code{by}" argument).
#' \code{dplyr::mutate} is an example where
#' we can use a \code{let} helper.   \code{dplyr::mutate} is
#' parameterized (in the sense it can work over user supplied columns and expressions), but column names are captured through non-standard evaluation
#' (and it rapidly becomes unwieldy to use complex formulas with the standard evaluation equivalent \code{dplyr::mutate_}).
#' \code{alias} can not include the symbol "\code{.}".
#'
#'
#' @seealso \code{\link{replyr_mapRestrictCols}} \code{\link{letp}}
#'
#' @param alias mapping from free names in expr to target names to use.
#' @param expr block to prepare for execution
#' @return result of expr executed in calling environment
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
#'
#'        # restart ranks at zero.
#'        d %>% mutate(RankColumn=RankColumn-1) -> dres
#'
#'        # confirm set of groups.
#'        unique(d$GroupColumn) -> groups
#'     })
#' print(groups)
#' print(length(groups))
#' print(dres)
#'
#' # It is also possible to pipe into let-blocks, but it takes some extra notation
#' # (notice the extra ". %>%" at the beginning and the extra "()" at the end,
#' # to signal %>% to treat the let-block as a function to evaluate).
#'
#' d %>% let(alias=mapping,
#'          expr={
#'            . %>% mutate(RankColumn=RankColumn-1)
#'          })()
#'
#' # Or:
#'
#' d %>% letp(alias=mapping,
#'          expr={
#'            . %>% mutate(RankColumn=RankColumn-1)
#'          })
#'
#' # Or:
#'
#' f <- let(mapping,
#'          . %>% mutate(RankColumn=RankColumn-1)
#'          )
#' d %>% f
#'
#' # Be wary of using any assignment to attempt side-effects in these "delayed pipelines",
#' # as the assignment tends to happen during the let dereference and not (as one would hope)
#' # during the later pipeline application.  Example:
#'
#' g <- let(alias=mapping,
#'          expr={
#'            . %>% mutate(RankColumn=RankColumn-1) -> ZZZ
#'          })
#' print(ZZZ)
#' # Notice ZZZ has captured a copy of the sub-pipeline and not waited for application of g.
#' # Applying g performs a calculation, but does not overwrite ZZZ.
#'
#' g(d)
#' print(ZZZ)
#' # Notice ZZZ is not a copy of g(d), but instead still the pipeline fragment.
#'
#'
#' # let works by string substitution aligning on word boundaries,
#' # so it does (unfortunately) also re-write strings.
#' let(list(x='y'),'x')
#'
#' @export
let <- function(alias, expr) {
  # Code adapted from gtools::strmacro by Gregory R. Warnes (License: GPL-2,
  # this portion also available GPL-2 to respect gtools license).
  # capture expr
  strexpr <- deparse(substitute(expr))
  # make sure alias is a list (not a named vector)
  alias <- as.list(alias)
  # confirm alias is mapping strings to strings
  if (length(unique(names(alias))) != length(names(alias))) {
    stop('replyr::let alias keys must be unique')
  }
  if ('.' %in% c(names(alias),as.character(alias))) {
    stop("replyr::let can not map to/from '.'")
  }
  for (ni in names(alias)) {
    if (is.null(ni)) {
      stop('replyr:let alias keys must not be null')
    }
    if (!is.character(ni)) {
      stop('replyr:let alias keys must all be strings')
    }
    if (length(ni) != 1) {
      stop('replyr:let alias keys must all be strings')
    }
    if (nchar(ni) <= 0) {
      stop('replyr:let alias keys must be empty string')
    }
    if (!isValidAndUnreservedName(ni)) {
      stop(paste('replyr:let alias key not a valid name: "', ni, '"'))
    }
    vi <- alias[[ni]]
    if (is.null(vi)) {
      stop('replyr:let alias values must not be null')
    }
    if (!is.character(vi)) {
      stop('replyr:let alias values must all be strings')
    }
    if (length(vi) != 1) {
      stop('replyr:let alias values must all be strings')
    }
    if (nchar(vi) <= 0) {
      stop('replyr:let alias values must be empty string')
    }
    if (!isValidAndUnreservedName(vi)) {
      stop(paste('replyr:let alias value not a valid name: "', vi, '"'))
    }
  }
  # re-write the parse tree and prepare for execution
  body <- strexpr
  for (ni in names(alias)) {
    pattern <- paste0("\\b", ni, "\\b")
    value <- alias[[ni]]
    body <- gsub(pattern, value, body)
  }
  `_reply_reserved_name` <- parse(text = body)
  rm(list=setdiff(ls(all.names=TRUE),list('_reply_reserved_name')))
  # try to execute expression in parent environment
  eval(`_reply_reserved_name`, envir=parent.frame(), enclos=parent.frame())
}


#' Wrap expr for \code{magrittr} pipeline execution with name substitutions specified in alias.
#'
#' \code{letp} implements a mapping from desired names (names used directly in the expr code) to names used in the data.
#' \code{letp} is a specialization of \code{let} for use in \code{magrittr} pipelines, please see \code{\link{let}}
#' for details.
#'
#'
#' \code{letp} is a variation of \code{let} needed only for inline code placed immediately after \code{\%>\%}, as in the
#' example below.
#' \code{expr} must start with "\code{ . \%>\% }" and should not attempt assignments
#' or other environment sensitive side-effects.
#'
#' @seealso \code{\link{replyr_mapRestrictCols}} \code{\link{let}}
#'
#' @param alias mapping from free names in expr to target names to use
#' @param expr \code{magrittr} pipeline to prepare for execution
#' @param . argument from \code{magrittr} pipeline (do not assign to this)
#' @return result of expr executed in calling environment
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
#' d %>% letp(alias=mapping,
#'          expr={
#'            . %>% mutate(RankColumn=RankColumn-1)
#'          })
#'
#' # letp is only for transient pipelines, to save pipes use let:
#'
#' f <- let(mapping,
#'          . %>% mutate(RankColumn=RankColumn-1)
#' )
#' d %>% f
#'
#' @export
letp <- function(alias, expr, .) {
  # Code adapted from gtools::strmacro by Gregory R. Warnes (License: GPL-2,
  # this portion also available GPL-2 to respect gtools license).
  # capture expr
  strexpr <- deparse(substitute(expr))
  # make sure alias is a list (not a named vector)
  alias <- as.list(alias)
  force(.)
  # confirm alias is mapping strings to strings
  if (length(unique(names(alias))) != length(names(alias))) {
    stop('replyr::letp alias keys must be unique')
  }
  if ('.' %in% c(names(alias),as.character(alias))) {
    stop("replyr::letp can not map to/from '.'")
  }
  for (ni in names(alias)) {
    if (is.null(ni)) {
      stop('replyr:letp alias keys must not be null')
    }
    if (!is.character(ni)) {
      stop('replyr:letp alias keys must all be strings')
    }
    if (length(ni) != 1) {
      stop('replyr:letp alias keys must all be strings')
    }
    if (nchar(ni) <= 0) {
      stop('replyr:letp alias keys must be empty string')
    }
    if (!isValidAndUnreservedName(ni)) {
      stop(paste('replyr:letp alias key not a valid name: "', ni, '"'))
    }
    vi <- alias[[ni]]
    if (is.null(vi)) {
      stop('replyr:letp alias values must not be null')
    }
    if (!is.character(vi)) {
      stop('replyr:letp alias values must all be strings')
    }
    if (length(vi) != 1) {
      stop('replyr:letp alias values must all be strings')
    }
    if (nchar(vi) <= 0) {
      stop('replyr:letp alias values must be empty string')
    }
    if (!isValidAndUnreservedName(vi)) {
      stop(paste('replyr:letp alias value not a valid name: "', vi, '"'))
    }
  }
  # re-write the parse tree and prepare for execution
  # with extra (.) to sacrifice to margrittr pipeline
  body <- c('({ ',strexpr,' })(.)')
  for (ni in names(alias)) {
    pattern <- paste0("\\b", ni, "\\b")
    value <- alias[[ni]]
    body <- gsub(pattern, value, body)
  }
  # The above form is assuming that strexpr starts with ". %>% ".
  # While implies it is itself a delay in evaluation.
  # The subtlties include that the following two statements are
  # not equivilant in current dplyr:
  #  (function(.) { z <-. ; z %>% mutate(rank=rank-1) })(data.frame(rank=1:2))
  #  (function(.) { z <-. ; . %>% mutate(rank=rank-1) })(data.frame(rank=1:2))
  # This is due to the special meaning of ". %>%" even though "." could be a value.
  # (. %>% mutate(rank=rank-1)) roughly always behaves like a function,
  #  even if "." already has a value (so "." in this context is always treated
  #  as a free variable.)
  `_reply_reserved_name` <- parse(text = body)
  rm(list=setdiff(ls(all.names=TRUE),list('.','_reply_reserved_name')))
  # eval in new environment
  eenv <- new.env(parent=parent.frame())
  assign('.', ., envir=eenv)
  eval(`_reply_reserved_name`, envir=eenv, enclos=parent.frame())
}
