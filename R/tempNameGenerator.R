
#' Produce a temp name generator with a given prefix.
#'
#' Returns a function f where f() or f(dumpList=FALSE) return
#' a new temporary name  f(TRUE) or f(dumpList=TRUE) returns
#' the list of names generated and clears the list.
#'
#' @param prefix character, string to prefix temp names with.
#' @param suffix character, optional additional disambiguating breaking string.
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
makeTempNameGenerator <- function(prefix,
                                  suffix= NULL) {
  force(prefix)
  if((length(prefix)!=1)||(!is.character(prefix))) {
    stop("repyr::makeTempNameGenerator prefix must be a string")
  }
  if(is.null(suffix)) {
    alphabet <- c(letters, toupper(letters), as.character(0:9))
    suffix <- paste(base::sample(alphabet, size=20, replace= TRUE),
                    collapse = '')
  }
  count <- 0
  nameList <- c()
  function(dumpList=FALSE) {
    if(dumpList) {
      v <- nameList
      nameList <<- c()
      return(v)
    }
    nm <- paste(prefix, suffix, sprintf('%05d',count), sep='_')
    nameList <<- c(nameList, nm)
    count <<- count + 1
    nm
  }
}