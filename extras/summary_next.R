
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr ungroup summarize summarise_all funs
#' @importFrom stats sd
#' @importFrom utils capture.output head
NULL

# don't use transmute: https://github.com/tidyverse/dplyr/issues/3398

#' Compute usable summary of columns of tbl.
#'
#' Compute per-column summaries and return as a \code{data.frame}.  Warning: can be an expensive operation.
#'
#' Can be slow compared to \code{dplyr::summarize_all()} (but serves a different purpose).
#' Also, for numeric columns includes \code{NaN} in \code{nna} count (as is typcial for \code{R}, e.g.,
#' \code{is.na(NaN)}).  And note: \code{replyr_summary()} currently skips "raw" columns.
#'
#' @param x tbl or item that can be coerced into such.
#' @param ... force additional arguments to be bound by name.
#' @param countUniqueNum logical, if true include unique non-NA counts for numeric cols.
#' @param cols if not NULL set of columns to restrict to.
#' @param compute logical if TRUE call compute before working
#' @return summary of columns.
#'
#' @examples
#'
#' d <- data.frame(p= c(TRUE, FALSE, NA),
#'                 r= I(list(1,2,3)),
#'                 s= NA,
#'                 t= as.raw(3:5),
#'                 w= 1:3,
#'                 x= c(NA,2,3),
#'                 y= factor(c(3,5,NA)),
#'                 z= c('a',NA,'z'),
#'                 stringsAsFactors=FALSE)
#' # sc <- sparklyr::spark_connect(version='2.2.0',
#' #                                  master = "local")
#' # dS <- replyr_copy_to(sc, dplyr::select(d, -r, -t), 'dS',
#' #                      temporary=TRUE, overwrite=TRUE)
#' # replyr_summary(dS)
#' # my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' # RSQLite::initExtension(my_db)
#' # dM <- replyr_copy_to(my_db, dplyr::select(d, -r, -t), 'dM',
#' #                      temporary=TRUE, overwrite=TRUE)
#' # replyr_summary(dM)
#' d$q <- list(1,2,3)
#' replyr_summary(d)
#'
#' @export
replyr_summary <- function(x,
                           ...,
                           countUniqueNum= FALSE,
                           cols= NULL,
                           compute= TRUE) {
  if(length(list(...))>0) {
    stop("replyr::replyr_summary unexpected arguments")
  }
  tempNameGenerator = mk_tmp_name_source('replyr_summary')
  x <- x %.>%
    dplyr::ungroup(.)
  if(compute) {
    x <- x %.>%
      compute(., name = tempNameGenerator())
  }
  # localSample might not have columns on zero row caes
  #   https://github.com/tidyverse/dplyr/issues/2913
  localSample <- x %.>%
    head(.) %.>%
    collect(.) %.>%
    as.data.frame(.)
  cnames <- colnames(x)
  if(!is.null(cols)) {
    cnames <- intersect(cnames, cols)
    localSample <- localSample[, cnames, drop=FALSE]
  }
  nrows <- 0
  if(replyr_nrow(localSample)>0) {
    nrows <- replyr_nrow(x)
  }
  cmap <- seq_len(length(cnames))
  names(cmap) <- cnames
  numericCols <- cnames[vapply(localSample, is.numeric, logical(1))]
  logicalCols <- cnames[vapply(localSample, is.logical, logical(1))]
  charCols <- cnames[vapply(localSample,
                            function(ci) { is.character(ci) || is.factor(ci) },
                            logical(1))]
  workingCols <- c(numericCols, logicalCols, charCols)
  exoticCols <- setdiff(cnames, workingCols)
  cclass <- lapply(localSample, class)
  names(cclass) <- colnames(localSample)
  # from http://stackoverflow.com/questions/34594641/dplyr-summary-table-for-multiple-variables
  # but the values as columns are not convenient.
  # see also http://stackoverflow.com/questions/26492280/non-standard-evaluation-nse-in-dplyrs-filter-pulling-data-from-mysql
  res <- data.frame(column = cnames,
                    index = NA_real_,
                    class = NA_character_,
                    nrows = nrows,
                    nna = NA_real_,
                    nunique = NA_real_,
                    min = NA_real_,
                    max = NA_real_,
                    mean = NA_real_,
                    sd = NA_real_,
                    lexmin = NA_real_,
                    lexmax = NA_real_,
                    stringsAsFactors = FALSE)
  classtr <- lapply(cclass,function(vi) {
    paste(vi,collapse=', ')
  })
  res$class <- classtr[res$column]
  res$index <- match(res$column, cnames)
  res <- res[order(res$column), , drop = FALSE]
  populate_column <- function(res, colname, z) {
    z <- z %.>% collect(.) %.>%
      as.data.frame(.) %.>%
      t(.) %.>%
      as.data.frame(.)
    idxs <- match(rownames(z), res$column)
    res[[colname]][idxs] <- z[[1]]
    res
  }
  if(length(workingCols)>=1) {
    res <- x %.>%
      dplyr::summarize_at(., vars(workingCols),
                          funs(sum(dplyr::if_else(is.na(.), 1.0, 0.0), na.rm = TRUE))) %.>%
      populate_column(res, "nna", .)
  }
  # limit down to populated columns
  unpop_cols <- res$column[res$nna>=res$nrows]
  res$nunique[res$column %in% unpop_cols] <- 0.0
  numericCols <- setdiff(numericCols, unpop_cols)
  logicalCols <- setdiff(logicalCols, unpop_cols)
  charCols <-  setdiff(charCols, unpop_cols)
  if(length(numericCols)>=1) {
    res <- x %.>%
      dplyr::summarize_at(., vars(numericCols),
                          funs(max(., na.rm = TRUE))) %.>%
      populate_column(res, "max", .)
    res <- x %.>%
      dplyr::summarize_at(., vars(numericCols),
                          funs(min(., na.rm = TRUE))) %.>%
      populate_column(res, "min", .)
    res <- x %.>%
      dplyr::summarize_at(., vars(numericCols),
                          funs(mean(., na.rm = TRUE))) %.>%
      populate_column(res, "mean", .)
    # get sample standard deviations (in a numericially stable manner)
    # not all databases have sd() calc.
    for(ci in numericCols) {
      idx <- which(ci==res$column)[[1]]
      ngood <- res$nrows[[idx]] - res$nna[[idx]]
      if(ngood>=2) {
        replyr_mv_var_temp <- res$mean[[idx]]
        let(c(CI = ci),
            vi <- x %.>%
              dplyr::summarize(., CI = sum((CI - replyr_mv_var_temp)*(CI - replyr_mv_var_temp),
                                           na.rm = TRUE)) %.>%
              dplyr::collect(.) %.>%
              as.data.frame(.)
        )
        res$sd[[idx]] <- sqrt(vi[[1]][[1]]/(ngood-1))
      }
    }
    # count unique
    if(countUniqueNum) {
      for(ci in numericCols) {
        idx <- which(ci==res$column)[[1]]
        if(res$nrows[[idx]]>res$nna[[idx]]) {
          let(c(CI = ci),
              vals <- x %.>%
                dplyr::select(., CI) %.>%
                dplyr::mutate(., CI = as.character(CI)) %.>%
                dplyr::filter(., !is.na(CI))%.>%
                dplyr::group_by(., CI) %.>%
                dplyr::summarize(., count = n()) %.>%
                dplyr::ungroup(.)
          )
          nv <- replyr_nrow(vals)
          res$nunique[[idx]] <- nv
        }
      }
    }
  }
  if(length(logicalCols)>=1) {
    res <- x %.>%
      dplyr::summarize_at(., vars(logicalCols),
                          funs(min(dplyr::if_else(., 1.0, 0.0), na.rm = TRUE))) %.>%
      populate_column(res, "min", .)
    res <- x %.>%
      dplyr::summarize_at(., vars(logicalCols),
                          funs(max(dplyr::if_else(., 1.0, 0.0), na.rm = TRUE))) %.>%
      populate_column(res, "max", .)
    res <- x %.>%
      dplyr::summarize_at(., vars(logicalCols),
                          funs(mean(dplyr::if_else(., 1.0, 0.0), na.rm = TRUE))) %.>%
      populate_column(res, "mean", .)
    for(ci in logicalCols) {
      # sample standard deviation!
      idx <- which(ci==res$column)[[1]]
      res$nunique[[idx]] <- 0.0
      ngood <- res$nrows[[idx]] - res$nna[[idx]]
      if(ngood>=1) {
        res$nunique[[idx]] <- 1.0
        res$lexmin[[idx]] <- c("FALSE", "TRUE")[[res$min[[idx]]+1]]
        res$lexmax[[idx]] <- c("FALSE", "TRUE")[[res$max[[idx]]+1]]
      }
      if(ngood>=2) {
        res$nunique[[idx]] <- 2.0
        if(res$min[[idx]]>=res$max[[idx]]) {
          res$sd[[idx]] <- 0.0
        } else {
          nTrue <- res$mean[[idx]]*ngood
          nFalse <- (1-res$mean[[idx]])*ngood
          res$sd[[idx]] <- sqrt(sum(nTrue*(1.0-res$mean[[idx]])*(1.0-res$mean[[idx]]) +
                                      nFalse*(0.0-res$mean[[idx]])*(0.0-res$mean[[idx]]))/
                                  (ngood-1))
        }
      }
    }
  }
  if(length(charCols)>=1) {
    for(ci in charCols) {
      idx <- which(ci==res$column)[[1]]
      if(res$nrows[[idx]]>res$nna[[idx]]) {
        let(c(CI = ci),
            vals <- x %.>%
              dplyr::select(., CI) %.>%
              dplyr::mutate(., CI = as.character(CI)) %.>%
              dplyr::filter(., !is.na(CI))%.>%
              dplyr::group_by(., CI) %.>%
              dplyr::summarize(., count = n()) %.>%
              dplyr::ungroup(.)
        )
        nv <- replyr_nrow(vals)
        let(c(CI = ci),
            s1 <-  vals %.>%
              dplyr::arrange(., CI) %.>%
              head(., n=1) %.>%
              dplyr::collect(.) %.>%
              as.data.frame(.)
        )
        let(c(CI = ci),
            s2 <-  vals %.>%
              dplyr::arrange(., desc(CI)) %.>%
              head(., n=1) %.>%
              dplyr::collect(.) %.>%
              as.data.frame(.)
        )
        res$lexmin[[idx]] <- s1[[1]][[1]]
        res$lexmax[[idx]] <- s2[[1]][[1]]
        res$nunique[[idx]] <- nv
      }
    }
  }
  res <- res[order(res$index),]
  rownames(res) <- NULL
  sc <- dplyr_src_to_db_handle(replyr_get_src(x))
  if((!is.null(sc)) && (!is.character(sc))) {
    for(ti in tempNameGenerator(dumpList = TRUE)) {
      dplyr::db_drop_table(sc, ti)
    }
  }
  res
}


