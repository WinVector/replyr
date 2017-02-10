

#' Land a value to variable from a pipeline.
#'
#' \%land\% and \%->\% ("writearrow") copy a pipeline value to a variable on the
#' right hand side.
#' \%land_\% and \%->_\% copy a pipeline value to
#' a variable named by the value referenced by its right hand side argument.
#' These operators use eager evaluation.
#'
#'
#'
#' Technically these operators are
#' not "-> assignment", so they might not be specifically prohibited in an
#' oppugnant reading of some style guides.
#'
#' @param value value to write
#' @param name variable to write to
#' @return value
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
`%land%` <- function(value, name) {
  name <- as.character(substitute(name))
  if((length(name)!=1)||(!is.character(name))||
     (!wrapr:::isValidAndUnreservedName(name))) {
    stop("replyr::`%land%` name argument must be a valid potential variable name")
  }
  force(value)
  envir <- parent.frame(1)
  assign(name, value,
         pos = envir,
         envir = envir)
  invisible(value)
}

#' @export
#' @rdname grapes-land-grapes
`%->%` <- function(value, name) {
  name <- as.character(substitute(name))
  if((length(name)!=1)||(!is.character(name))||
     (!wrapr:::isValidAndUnreservedName(name))) {
    stop("replyr::`%->%` name argument must be a valid potential variable name")
  }
  force(value)
  envir <- parent.frame(1)
  assign(name, value,
         pos = envir,
         envir = envir)
  invisible(value)
}

#' @export
#' @rdname grapes-land-grapes
`%->_%` <- function(value, name) {
  if((length(name)!=1)||(!is.character(name))||
     (!wrapr:::isValidAndUnreservedName(name))) {
    stop("replyr::`%->_%` name argument must be a valid potential variable name")
  }
  force(value)
  envir <- parent.frame(1)
  assign(name, value,
         pos = envir,
         envir = envir)
  invisible(value)
}

#' @export
#' @rdname grapes-land-grapes
`%land_%` <- function(value, name) {
  if((length(name)!=1)||(!is.character(name))||
     (!wrapr:::isValidAndUnreservedName(name))) {
    stop("replyr::`%land_%` name argument must be a valid potential variable name")
  }
  force(value)
  envir <- parent.frame(1)
  assign(name, value,
         pos = envir,
         envir = envir)
  invisible(value)
}
