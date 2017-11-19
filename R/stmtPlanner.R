

#' sort expressions
#'
#' @param de frame of expressions
#' @return list of data frames of expressions (dependency sorted)
#'
#' @noRd
#'
sort_mutate_d <- function(de) {
  n <- nrow(de)
  g <- igraph::make_empty_graph()
  v <- paste0('v', 1:n)
  for(i in 1:n) {
    g <- g + igraph::vertex(v[[i]])
  }
  for(i in 1:n) {
    for(j in 1:n) {
      if(i!=j) {
        if(de$lhs[[i]] %in% de$rhs[[j]]) {
          g <- g + igraph::edge(v[[i]], v[[j]])
        }
      }
    }
  }
  steporder <- as.numeric(igraph::topo_sort(g))
  # TODO: also split up
}


#' Scan for symbols.
#'
#' @param lexpr language item
#' @return R language element with substitutions
#'
#' @noRd
#'
find_symbols <- function(nexpr) {
  n <- length(nexpr)
  # just in case (establishes an invarient of n>=1)
  if(n<=0) {
    return(NULL)
  }
  # basic recurse, establish invariant n==1
  if(n>1) {
    # TODO: skip calls
    res <- lapply(nexpr, find_symbols)
    res <- Filter(function(ri) {!is.null(ri)}, res)
    return(as.character(res))
  }
  if(is.expression(nexpr)) {
    return(find_symbols(nexpr[[1]]))
  }
  # this is the main re-mapper
  if(is.symbol(nexpr)) { # same as is.name()
    return(as.character(nexpr))
  }
  # fall-back
  return(NULL)
}




#'
#' @param exprs source of mutate expressions as an assignment list
#' @return
#'
#' @examples
#'
#' sort_mutate_se(c("a1" := "1", "b1" := "a1", "a2" := "2", "b2" := "a1 + a2"))
#'
#' @export
#'
sort_mutate_se <- function(exprs) {
  res <- data.frame(lhs = names(exprs),
                    rhs = as.character(exprs),
                    stringsAsFactors = FALSE)
  res$syms <- lapply(res$rhs,
                     function(ei) {
                       find_symbols(parse(text = ei))
                     })
  sort_mutate_d(res)
}


#'
#' @param ... mutate expressions
#' @return
#'
#' @examples
#'
#' sort_mutate_nse(a1 := 1, b1 := a1, a2 := 2, b2 := a1 + a2)
#'
#' @export
#'
sort_mutate_nse <- function(...) {
  mutateTerms <- substitute(list(...))
  len <- length(mutateTerms) # first slot is "list"
  if(len>1) {
    lhs <- character(len-1)
    rhs <- character(len-1)
    syms <- vector(mode = 'list', length=len-1)
    for(i in (2:len)) {
      ei <- mutateTerms[[i]]
      if((length(ei)!=3)||(as.character(ei[[1]])!=':=')) {
        stop("sort_mutate_nse terms must be of the form: sym := expr")
      }
      lhs[[i-1]] <- as.character(ei[[2]])[[1]]
      syms[[i-1]] <- find_symbols(ei[[3]])
      rhs[[i-1]] <- deparse(ei[[3]])[[1]]
    }
  }
  res <- data.frame(lhs = lhs,
                    rhs = rhs,
                    stringsAsFactors = FALSE)
  res$syms <- syms
  sort_mutate_d(res)
}

