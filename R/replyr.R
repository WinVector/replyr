#' replyr: an R package for fluid use of dplyr
#'
#' replyr supplies methods to get a grip on working with remote tbl sources (SQL databases,
#' Spark) through dplyr.  The idea is to add convenience functions to make such task more like
#' working with an in-memory data.frame.  Results do depend on which dplyr service you use.
#'
#' \code{replyr} helps with the following:
#'
#' \itemize{
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


# re-export so old code and demos work (from when functions were here)

#' @importFrom wrapr let
#' @export
wrapr::let

#' @importFrom wrapr restrictToNameAssignments
#' @export
wrapr::restrictToNameAssignments


#' @importFrom wrapr DebugFn
#' @export
wrapr::DebugFn

#' @importFrom wrapr DebugFnE
#' @export
wrapr::DebugFnE

#' @importFrom wrapr DebugFnW
#' @export
wrapr::DebugFnW

#' @importFrom wrapr DebugFnWE
#' @export
wrapr::DebugFnWE

#' @importFrom wrapr DebugPrintFn
#' @export
wrapr::DebugPrintFn

#' @importFrom wrapr DebugPrintFnE
#' @export
wrapr::DebugPrintFnE
