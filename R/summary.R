
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr ungroup summarize transmute summarise_all funs
#' @importFrom stats sd
#' @importFrom utils capture.output head
NULL



#' Compute usable summary of columns of tbl.
#'
#' @param x tbl or item that can be coerced into such.
#' @param ... force additional arguments to be bound by name.
#' @param countUniqueNum logical, if true include unique non-NA counts for numeric cols.
#' @param countUniqueNonNum logical, if true include unique non-NA counts for non-numeric cols.
#' @param cols if not NULL set of columns to restrict to.
#' @return summary of columns.
#'
#' @examples
#'
#' d <- data.frame(p= c(TRUE, FALSE, NA),
#'                 s = NA,
#'                 w= 1:3,
#'                 x=c(NA,2,3),
#'                 y=factor(c(3,5,NA)),
#'                 z=c('a',NA,'z'),
#'                 stringsAsFactors=FALSE)
#' d$q <- list(1,2,3)
#' replyr_summary(d)
#'
#' @export
replyr_summary <- function(x,
                           ...,
                           countUniqueNum= FALSE,
                           countUniqueNonNum= FALSE,
                           cols= NULL) {
  if(length(list(...))>0) {
    stop("replyr::replyr_summary unexpected arguments")
  }
  x <- dplyr::ungroup(x)
  # localSample might not have columns on zero row caes
  #   https://github.com/tidyverse/dplyr/issues/2913
  localSample <- x %.>%
    head(.) %.>%
    collect(.) %.>%
    as.data.frame(.)
  cnames <- colnames(x)
  if(!is.null(cols)) {
    cnames <- intersect(cnames, cols)
  }
  nrows <- 0
  if(nrow(localSample)>0) {
    nrows <- nrow(x)
  }
  cmap <- seq_len(length(cnames))
  names(cmap) <- cnames
  numericCols <- cnames[vapply(localSample, is.numeric, logical(1))]
  logicalCols <- cnames[vapply(localSample, is.logical, logical(1))]
  charCols <- cnames[vapply(localSample,
                            function(ci) { is.character(ci) || is.factor(ci) },
                            logical(1))]
  exoticCols <- setdiff(cnames, c(numericCols, logicalCols, charCols))
  cclass <- lapply(localSample, class)
  names(cclass) <- colnames(localSample)
  # from http://stackoverflow.com/questions/34594641/dplyr-summary-table-for-multiple-variables
  # but the values as columns are not convenient.
  # see also http://stackoverflow.com/questions/26492280/non-standard-evaluation-nse-in-dplyrs-filter-pulling-data-from-mysql
  suppressWarnings({
   numSums <- lapply(numericCols,
                    function(ci) {
                      WCOL <- NULL # declare this is not a free binding
                      let(alias=list(WCOL=ci),
                          expr={
                            x %.>% dplyr::select(., WCOL) %.>%
                              dplyr::filter(., !is.na(WCOL)) -> xsub
                          })
                      ngood <- replyr_nrow(xsub)
                      xsub %.>% dplyr::summarise_all(., dplyr::funs(min = min,
                                            # q25 = quantile(., 0.25),  # MySQL can't do this
                                            # median = median,          # MySQL can't do this
                                            # q75 = quantile(., 0.75),  # MySQL can't do this
                                            max = max,
                                            mean = mean,
                                            sd = sd)) %.>%
                        dplyr::collect(.) %.>%
                        as.data.frame(.) -> si
                      # dplyr::summarize_each has sd=0 for single row SQLite examples
                      # please see here: https://github.com/WinVector/replyr/blob/master/issues/SQLitesd.md
                      if(ngood<=1) {
                        si$sd <- NA
                      }
                      nunique = NA
                      if(countUniqueNum) {
                        xsub %.>%
                          replyr_uniqueValues(., ci) %.>%
                          replyr_nrow(.) -> nunique
                      }
                      si <-  data.frame(column=ci,
                                        index=0,
                                        class='',
                                        nrows = nrows,
                                        nna = nrows - ngood,
                                        nunique = nunique,
                                        min = si$min,
                                        max = si$max,
                                        mean = si$mean,
                                        sd = si$sd,
                                        lexmin = NA_character_,
                                        lexmax = NA_character_,
                                        stringsAsFactors = FALSE)
                      si
                    })
   logSums <- lapply(logicalCols,
                     function(ci) {
                       WCOL <- NULL # declare this is not a free binding
                       let(alias=list(WCOL=ci),
                           expr={
                             x %.>%
                               dplyr::select(., WCOL) %.>%
                               dplyr::filter(., !is.na(WCOL)) %.>%
                               dplyr::mutate(., WCOL= ifelse(WCOL,1,0)) -> xsub
                           })
                       ngood <- replyr_nrow(xsub)
                       xsub %.>% dplyr::summarise_all(., dplyr::funs(min = min,
                                                                  # q25 = quantile(., 0.25),  # MySQL can't do this
                                                                  # median = median,          # MySQL can't do this
                                                                  # q75 = quantile(., 0.75),  # MySQL can't do this
                                                                  max = max,
                                                                  mean = mean,
                                                                  sd = sd)) %.>%
                         dplyr::collect(.) %.>%
                         as.data.frame(.) -> si
                       # dplyr::summarize_each has sd=0 for single row SQLite examples
                       # please see here: https://github.com/WinVector/replyr/blob/master/issues/SQLitesd.md
                       if(ngood<=1) {
                         si$sd <- NA
                       }
                       nunique = NA
                       if(countUniqueNum) {
                         xsub %.>%
                           replyr_uniqueValues(., ci) %.>%
                           replyr_nrow(.) -> nunique
                       }
                       si <-  data.frame(column=ci,
                                         index=0,
                                         class='',
                                         nrows = nrows,
                                         nna = nrows - ngood,
                                         nunique = nunique,
                                         min = si$min,
                                         max = si$max,
                                         mean = si$mean,
                                         sd = si$sd,
                                         lexmin = NA_character_,
                                         lexmax = NA_character_,
                                         stringsAsFactors = FALSE)
                       si
                     })
   exoticSums <- lapply(exoticCols,
                     function(ci) {
                       si <-  data.frame(column=ci,
                                         index=0,
                                         class='',
                                         nrows = nrows,
                                         nna = NA,
                                         nunique = NA,
                                         min = NA,
                                         max = NA,
                                         mean = NA,
                                         sd = NA,
                                         lexmin = NA_character_,
                                         lexmax = NA_character_,
                                         stringsAsFactors = FALSE)
                       si
                     })
   charSums <- lapply(charCols,
                    function(ci) {
                      WCOL <- NULL # declare this is not a free binding
                      let(alias=list(WCOL=ci),
                          expr={
                            x %.>%
                              dplyr::select(., WCOL) %.>%
                              dplyr::filter(., !is.na(WCOL)) -> xsub
                          })
                      ngood <- replyr_nrow(xsub)
                      # min/max don't work on local data.frames for factors, but do for strings.
                      si <- data.frame(lexmin = NA_character_,
                                       lexmax = NA_character_,
                                       stringsAsFactors = FALSE)
                      good <- FALSE
                      tryCatch(
                        {
                        xsub %.>%
                            dplyr::summarise_all(., dplyr::funs(lexmin = min,
                                                                   lexmax = max)) %.>%
                            dplyr::collect(.) %.>%
                            as.data.frame(.) -> si;
                        si <- data.frame(lexmin = as.character(si$lexmin),
                                         lexmax = as.character(si$lexmax),
                                         stringsAsFactors = FALSE)
                        good <- TRUE
                        },
                        error = function(x) NULL
                      )
                      if((!good)&&(replyr_is_local_data(xsub))) {
                        suppressWarnings(
                          xsub %.>%
                            as.data.frame(.) -> xsublocal
                        )
                        si <- data.frame(lexmin = min(as.character(xsublocal[[ci]])),
                                         lexmax = max(as.character(xsublocal[[ci]])),
                                         stringsAsFactors = FALSE)
                      }
                      nunique = NA
                      if(countUniqueNonNum) {
                        xsub %.>%
                          replyr_uniqueValues(., ci) %.>%
                          replyr_nrow(.) -> nunique
                      }
                      si <- data.frame(column=ci,
                                       index=0,
                                       class='',
                                       nrows = nrows,
                                       nna = nrows - ngood,
                                       nunique = nunique,
                                       min = NA_real_,
                                       max = NA_real_,
                                       mean = NA_real_,
                                       sd = NA_real_,
                                       lexmin = si$lexmin,
                                       lexmax = si$lexmax,
                                       stringsAsFactors = FALSE)
                      si
                    })
  })
  res <- dplyr::bind_rows(c(numSums, logSums, charSums, exoticSums))
  res$index <- cmap[res$column]
  classtr <- lapply(cclass,function(vi) {
    paste(vi,collapse=', ')
  })
  res$class <- classtr[res$column]
  res <- res[order(res$index),]
  rownames(res) <- NULL
  res
}


