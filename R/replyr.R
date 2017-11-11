#' replyr: Diligent Use of Big Data for R
#'
#' Methods to reliably use 'dplyr' remote data sources in R ('SQL' databases,
#' 'Spark' 2.0.0 and above) in a generic fashion. REmote PLYing of big data for R.
#' Adds convenience functions to make big data tasks more like
#' working with an in-memory R 'data.frame'.
#' Results do depend on which 'dplyr' data service provider used.
#'
#' \code{replyr} helps with the following:
#'
#' \itemize{
#' \item Summarizing remote data (via \code{replyr_summarize}).
#' \item Facilitating writing "source generic" code that works similarly on multiple 'dplyr' data sources.
#' \item Providing big data versions of functions for splitting data, binding rows, pivoting, adding row-ids, ranking, and completing experimental designs.
#' \item Packaging common data manipulation tasks into operators  such as the \code{\link{gapply}} function.
#' \item Providing support code for common \code{SparklyR} tasks, such as tracking temporary handle IDs.
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
#' @importFrom seplyr novelName
#' @importFrom cdata grepdf
#' @export
wrapr::let

#' @importFrom wrapr restrictToNameAssignments
#' @export
wrapr::restrictToNameAssignments

#' @importFrom wrapr %.>%
#' @export
wrapr::`%.>%`

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

# so it does not look like an unbound reference in pipes
. <- NULL

