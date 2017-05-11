
#' Produce a temp name generator with a given prefix.
#'
#' Returns a function f where f() or f(dumpList=FALSE) return
#' a new temporary name  f(TRUE) or f(dumpList=TRUE) returns
#' the list of names generated and clears the list.
#'
#' @param prefix character, string to prefix temp names with.
#' @return name generator function.
#'
#' @examples
#'
#' f <- makeTempNameGenerator('EX')
#' print(f())
#' print(f())
#' print(f(dumpList=TRUE))
#' print(f(dumpList=TRUE))
#'
#' @export
makeTempNameGenerator <- function(prefix) {
  force(prefix)
  if((length(prefix)!=1)||(!is.character(prefix))) {
    stop("repyr::makeTempNameGenerator prefix must be a string")
  }
  count <- 0
  nameList <- c()
  function(dumpList=FALSE) {
    if(dumpList) {
      v <- nameList
      nameList <<- c()
      return(v)
    }
    nm <- paste(prefix, 'TMPHDL', sprintf('%05d',count), sep='_')
    nameList <<- c(nameList, nm)
    count <<- count + 1
    nm
  }
}