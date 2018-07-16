#' replyr: Patches to Use dplyr on Remote Data Sources
#'
#' Methods to reliably use \code{dplyr} on remote data sources in \code{R} (\code{SQL} databases,
#' \code{Spark} \code{2.0.0} and above) in a generic fashion.
#'
#' \code{replyr} is going into maintenance mode.  It has been hard to track
#' shifting \code{dplyr}/\code{dbplyr}/\code{rlang} APIs and data structures post \code{dplyr} \code{0.5}.
#' Most of what it does is now done better in one of the newer non-monolithic packages:
#'
#' \itemize{
#' \item Programming and meta-programming tools: \code{wrapr} \url{https://CRAN.R-project.org/package=wrapr}.
#' \item Adapting \code{dplyr} to standard evaluation interfaces: \code{seplyr} \url{https://CRAN.R-project.org/package=seplyr}.
#' \item Big data data manipulation: \code{rquery} \url{https://CRAN.R-project.org/package=rquery} and \code{cdata} \url{https://CRAN.R-project.org/package=cdata}.
#' }
#'
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
#' \code{replyr} is in maintenance mode. Better version of the functionality have been ported to the following packages:
#' \code{wrapr}, \code{cdata}, \code{rquery}, and \code{seplyr}.
#'
#'
#' To learn more about replyr, please start with the vignette:
#' \code{vignette('replyr','replyr')}
#'
#' @docType package
#' @name replyr
NULL


# re-export so old code and demos work (from when functions were here)

#' @importFrom wrapr let %.>% := mk_tmp_name_source
NULL


# so it does not look like an unbound reference in pipes
. <- NULL

