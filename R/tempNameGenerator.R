
#' Produce a temp name generator with a given prefix.
#'
#' Returns a function f where: f() returns a new temporary name,
#' f(remove=vector) removes names in vector and returns what was removed,
#' f(dumpList=TRUE) returns the list of names generated and clears the list,
#' f(peek=TRUE) returns the list without altering anything.
#'
#' @param prefix character, string to prefix temp names with.
#' @param suffix character, optional additional disambiguating breaking string.
#' @return name generator function.
#'
#' @examples
#'
#' f <- makeTempNameGenerator('EX')
#' print(f())
#' nm2 <- f()
#' print(nm2)
#' f(remove=nm2)
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
  nameList <- list()
  function(..., peek=FALSE, dumpList=FALSE, remove=NULL) {
    if(length(list(...))>0) {
      stop("replyr::makeTempNameGenerator tempname generate unexpected argument")
    }
    if(peek) {
      return(names(nameList))
    }
    if(dumpList) {
      v <- names(nameList)
      nameList <<- list()
      return(v)
    }
    if(!is.null(remove)) {
      victims <- intersect(remove, names(nameList))
      # this removes from lists
      nameList[victims] <<- NULL
      return(victims)
    }
    nm <- paste(prefix, suffix, sprintf('%010d',count), sep='_')
    nameList[[nm]] <<- 1
    count <<- count + 1
    nm
  }
}