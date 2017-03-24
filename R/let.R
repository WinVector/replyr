
#' @importFrom wrapr let
NULL

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
#' @param . incoming argument from \code{magrittr} pipeline (do not assign to this)
#' @param alias mapping from free names in expr to target names to use
#' @param expr \code{magrittr} pipeline to prepare for execution
#' @param strict logical if TRUE only allow single name replacements.
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
#' d %>% letp(mapping,
#'            . %>% mutate(RankColumn=RankColumn-1)
#'           )
#'
#' # letp is only for transient pipelines, to save pipes use let:
#'
#' f <- let(mapping,
#'          . %>% mutate(RankColumn=RankColumn-1)
#'         )
#' d %>% f
#'
#' @export
letp <- function(., alias, expr,
                 strict= TRUE) {
  # capture expr
  strexpr <- deparse(substitute(expr))
  force(.)
  body <- c('({ ',strexpr,' })(.)')
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
  `_reply_reserved_name` <- wrapr::letprep(alias, body, strict)
  rm(list=setdiff(ls(all.names=TRUE),list('.','_reply_reserved_name')))
  # eval in new environment
  eenv <- new.env(parent=parent.frame())
  assign('.', ., envir=eenv)
  eval(`_reply_reserved_name`, envir=eenv, enclos=parent.frame())
}
