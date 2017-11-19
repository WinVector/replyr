

#' partition expressions
#'
#' Find longest ordered not created and used in same block chains.
#'
#' @param de frame of expressions
#' @return ordered list of mutate_se assignment blocks
#'
#' @noRd
#'
partition_mutate_d <- function(de) {
  n <- nrow(de)
  de$origOrder = 1:n
  de$group <- 0L
  group <- 1L
  while(any(de$group<=0)) {
    # sweep forward in order greedily taking anything
    # that has not been formed
    # in this group.
    formed <- NULL
    for(i in 1:n) {
      if( (de$group[[i]]<=0) &&
         (length(intersect(de$syms[[i]], formed))<=0) ) {
        formed <- c(formed, de$lhs[[i]])
        de$group[[i]] <- group
      }
    }
    group <- group + 1L
  }
  de <- de %.>%
    arrange_se(., c("group", "origOrder"))
  # break out into mutate_se blocks
  res <- rep(list(character(0)), max(de$group))
  for(i in 1:n) {
    gi <- de$group[[i]]
    res[[gi]] <- c(res[[gi]], de$lhs[[i]] := de$rhs[[i]])
  }
  res
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



#' Partition a sequence of mutate commands into longest ordered no create/use blocks.
#'
#' @param exprs source of mutate expressions as an assignment list
#' @return
#'
#' @examples
#'
#' partition_mutate_se(c("a1" := "1", "b1" := "a1", "a2" := "2", "b2" := "a1 + a2"))
#'
#' @export
#'
partition_mutate_se <- function(exprs) {
  res <- data.frame(lhs = names(exprs),
                    rhs = as.character(exprs),
                    stringsAsFactors = FALSE)
  res$syms <- lapply(res$rhs,
                     function(ei) {
                       find_symbols(parse(text = ei))
                     })
  partition_mutate_d(res)
}


#' Partition a sequence of mutate commands into longest ordered no create/use blocks.
#'
#' @param ... mutate expressions
#' @return
#'
#' @examples
#'
#' plan <- partition_mutate_nse(a1 := 1, b1 := a1, a2 := 2, b2 := a1 + a2)
#' print(plan)
#' d <- data.frame(x = 1)
#' for(si in plan) {
#'    print(si)
#'    d <- mutate_se(d, si)
#' }
#' print(d)
#'
#'
#' @export
#'
partition_mutate_nse <- function(...) {
  mutateTerms <- substitute(list(...))
  len <- length(mutateTerms) # first slot is "list"
  if(len>1) {
    lhs <- character(len-1)
    rhs <- character(len-1)
    syms <- vector(mode = 'list', length=len-1)
    for(i in (2:len)) {
      ei <- mutateTerms[[i]]
      if((length(ei)!=3)||(as.character(ei[[1]])!=':=')) {
        stop("partition_mutate_nse terms must be of the form: sym := expr")
      }
      lhs[[i-1]] <- as.character(ei[[2]])[[1]]
      syms[[i-1]] <- find_symbols(ei[[3]])
      rhs[[i-1]] <- paste(deparse(ei[[3]]), collapse = "\n")
    }
  }
  res <- data.frame(lhs = lhs,
                    rhs = rhs,
                    stringsAsFactors = FALSE)
  res$syms <- syms
  partition_mutate_d(res)
}

