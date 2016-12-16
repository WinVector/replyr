
#' Land a value to variable from a pipeline.
#'
#' \%land\% and \%->\% copy a pipeline value to a variable on the RHS,
#' \%land_\% and \%->_\% copy a pipeline value to
#' a variable named by its RHS argument.  There is nothing these operators do
#' better than "->" and they are mostly just a proof of concept (though technically they
#' are not "-> assignment" so they may not be specifically prohibited in some style guides).
#'
#' @param value value to write
#' @param name variable to write to
#'
#' @examples
#'
#' library("dplyr")
#' 7 %>% sin() %->% z1
#' 7 %>% sin() %->_% 'z2'
#' varname <- 'z3'
#' 7 %>% sin() %->_% varname
#'
#' @export
`%land%` <- function(value,name) {
  name <- as.character(substitute(name))
  envir <- parent.frame(1)
  assign(name,value,
         pos=envir,
         envir=envir)
}

#' @export
#' @rdname grapes-land-grapes
`%->%` <- function(value,name) {
  name <- as.character(substitute(name))
  envir <- parent.frame(1)
  assign(name,value,
         pos=envir,
         envir=envir)
}

#' @export
#' @rdname grapes-land-grapes
`%->_%` <- function(value,name) {
  envir <- parent.frame(1)
  assign(name,value,
         pos=envir,
         envir=envir)
}

#' @export
#' @rdname grapes-land-grapes
`%land_%` <- function(value,name) {
  envir <- parent.frame(1)
  assign(name,value,
         pos=envir,
         envir=envir)
}



