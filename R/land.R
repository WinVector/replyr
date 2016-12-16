
#' Assign or land a value to variable from a pipeline.
#'
#' land copies a pipeline value to a variable on the RHS, land_ copies a pipeline value to
#' a variable named by its RHS argument.  There is nothing these operators do
#' better than "->" and they are mostly just a proof of concept.
#'
#' @param value value to write
#' @param name variable to write to
#'
#' @examples
#'
#' library("dplyr")
#' 7 %>% sin() %land% z1
#' 7 %>% sin() %land_% 'z2'
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
`%land_%` <- function(value,name) {
  envir <- parent.frame(1)
  assign(name,value,
         pos=envir,
         envir=envir)
}


