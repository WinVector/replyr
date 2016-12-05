
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' Prepare expr for execution with name substitions specified in alias.
#'
#' Code adapted from gtools::strmacro by Gregory R. Warnes (License: GPL-2, this portion also available GPL-2 to respect gtools license).
#'
#' @param alias mapping from free names in expr to target names to use.
#' @param expr block to prepare for execution
#' @return item ready to evaluate, need to apply with "()" to get the evaluation in own environemnt.
#'
#' @examples
#'
#' library('dplyr')
#' d <- data.frame(Sepal_Length=c(5.8,5.7),
#'                 Sepal_Width=c(4.0,4.4),
#'                 Species='setosa',
#'                 rank=c(1,2))
#' mapping = list(RankColumn='rank')
#' let(alias=mapping,
#'     expr={
#'        d %>% mutate(RankColumn=RankColumn-1) -> dres
#'     })()
#' print(dres)
#'
#' @export
let <- function(alias, expr) {
  strexpr <- deparse(substitute(expr))
  alias <- as.list(alias)
  ff <- function(...) {
    reptab <- alias
    reptab$... <- NULL
    args <- match.call(expand.dots = TRUE)[-1]
    for (item in names(args)) reptab[[item]] <- args[[item]]
    body <- strexpr
    for (i in 1:length(reptab)) {
      pattern <- paste("\\b", names(reptab)[i], "\\b",
                       sep = "")
      value <- reptab[[i]]
      if (missing(value))
        value <- ""
      body <- gsub(pattern, value, body)
    }
    fun <- parse(text = body)
    eval(fun, parent.frame())
  }
  formals(ff) <- alias
  mm <- match.call()
  mm$expr <- NULL
  mm[[1]] <- as.name("let")
  attr(ff, "source") <- c(deparse(mm), strexpr)
  ff
}

