#' replyr: an R package for fluid use of dplyr
#'
#' replyr supplies methods to get a grip on working with remote tbl sources (SQL databases,
#' Spark) through dplyr.  The idea is to add convenience functions to make such task more like
#' working with an in-memory data.frame.  Results do depend on which dplyr service you use.
#'
#' replyr has the following:
#'
#' \itemize{
#' \item Make "parametric treatment of variable names" easier through the \code{\link{let}} command.
#' \item Package common data manipulation tasks into operators  such as the \code{\link{gapply}} function.
#' \item Provide "remote data" (SQL, Spark) replacements for functions commonly used on in-memory data frames.
#' \item Provide bug-fixes and work-arounds for various data services.
#' \item Collect and document clever dplyr tricks.
#' }
#'
#' To learn more about replyr, please start with the vignette:
#' \code{vignette('replyr','replyr')}
#'
#' @docType package
#' @name replyr
NULL
