
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr mutate arrange
NULL

# binary search adapted for number of rows queries
qsearch <- function(f,fLeft,fRight,ui) {
  left <- fLeft
  right <- fRight
  while(TRUE) {
    if(left$count>=ui) {
      return(left)
    }
    if(right$count<=ui) {
      return(right)
    }
    if(left$rv>=right$lv) {
      return(rbind(left,right))
    }
    probe <- (left$rv+right$lv)/2
    fx <- f(probe)
    if(fx$count==ui) {
      return(fx)
    }
    if(fx$count>=ui) {
      right = fx
    } else {
      left = fx
    }
  }
}

#' Compute quantiles on remote column (NA's filtered out).
#'
#' NA's filtered out and does not break ties the same as stats::quantile.
#'
#' @param x tbl or item that can be coerced into such.
#' @param cname column name to compute over
#' @param probs	numeric vector of probabilities with values in [0,1].
#'
#' @examples
#'
#' d <- data.frame(xvals=rev(1:1000))
#' replyr_quantile(d,'xvals')
#'
#' @export
replyr_quantile <- function(x,cname,probs = seq(0, 1, 0.25)) {
  if((!is.character(cname))||(length(cname)!=1)) {
    stop('replyr_quantile cname must be a single string')
  }
  x %>% replyr_select(cname) %>% dplyr::ungroup() -> x
  # make the variable name "x" as dplyr is much easier if we know the variable name
  if(cname!='x') {
    XCOL <- NULL # declare no external binding
    let(
      list(XCOL=cname),
      x %>% dplyr::rename(x=XCOL) -> x
    )
  }
  # filter out NA
  x %>% dplyr::filter(!is.na(x)) -> x
  nrows <- replyr_nrow(x)
  # targets <- pmin(pmax(1,round(probs*nrows)),nrows)
  # # if we had cumsum() could finish with:
  # # add row numbers
  # x %>% dplyr::mutate(const=1) %>% dplyr::arrange(x) %>% dplyr::mutate(s=cumsum(const)) %>%
  #   replyr_filter('s',targets) %>% as.data.frame() -> x
  # x <- x[order(x$s),]
  # x$x
  # # But sqllite doesn't have such window functions (or row_number())
  # # so we need one more idea.
  # For now binary search for a given target.
  x %>% dplyr::summarise(xmax=max(x),xmin=min(x)) %>%
    dplyr::collect() %>% as.data.frame() %>% as.numeric() -> lims
  f <- function(v) {
    v <- as.numeric(v)
    x %>% dplyr::filter(x<=v) -> xsub
    xsub %>% replyr_nrow() -> count
    xsub %>% dplyr::summarise(xmax=max(x)) %>%
      dplyr::collect() %>% as.data.frame() %>% as.numeric() -> lv
    x %>% dplyr::filter(x>v) -> xup
    rv <- max(lims)
    if(count<nrows) {
      x %>% dplyr::filter(x>v) %>% dplyr::summarise(xmin=min(x)) %>%
        dplyr::collect() %>% as.data.frame() %>% as.numeric() -> rv
    }
    data.frame(v=v,count=count,lv=lv,rv=rv)
  }
  fLeft <- f(min(lims))
  fRight <- f(max(lims))
  # could do more precise polishin by adpating below to polishQ
  #marks <- dplyr::bind_rows(lapply(probs*nrows,function(ti) qsearch(f,fLeft,fRight,ti)))
  r <- vapply(probs*nrows,
              function(ti) {
                mean(qsearch(f,fLeft,fRight,ti)$v)
              },numeric(1))
  names(r) <- probs
  r
}

# polish quantiles estimate from known summaries
polishQ <- function(nrows,marks,probs) {
  r <- vapply(probs,
              function(pi) {
                lv <- pmax(1,pmin(nrows,floor(pi*nrows)))
                ls <- marks$x[marks$s==lv]
                hv <- pmax(1,pmin(nrows,ceiling(pi*nrows)))
                if((hv<=lv)||(pi<=lv)) {
                  return(ls)
                }
                hs <- marks$x[marks$s==hv]
                lambda <- (pi-lv)/(hv-lv)
                return(ls*lambda + (1-lambda)*hs)
              },numeric(1))
  names(r) <- probs
  r
}

#' Compute quantiles on remote column (NA's filtered out) using cumsum.
#'
#' NA's filtered out and does not break ties the same as stats::quantile.
#'
#' @param x tbl or item that can be coerced into such.
#' @param cname column name to compute over (not 'n' or 'csum')
#' @param probs	numeric vector of probabilities with values in [0,1].
#'
#' @examples
#'
#' d <- data.frame(xvals=rev(1:1000))
#' replyr_quantilec(d,'xvals')
#'
#' @export
replyr_quantilec <- function(x,cname,probs = seq(0, 1, 0.25)) {
  if((!is.character(cname))||(length(cname)!=1)) {
    stop('replyr_quantilec cname must be a single string')
  }
  x %>% replyr_select(cname) %>% dplyr::ungroup() -> x
  # make the variable name "x" as dplyr is much easier if we know the variable name
  if(cname!='x') {
    XCOL <- NULL # declare no external binding
    let(
      list(XCOL=cname),
      x %>% dplyr::rename(x=XCOL) -> x
    )
  }
  # filter out NA
  x %>% dplyr::filter(!is.na(x)) -> x
  # get targets
  nrows <- replyr_nrow(x)
  targets <- sort(unique(pmax(1,pmin(nrows,c(
    1,
    nrows,
    ceiling(probs*nrows),
    floor(probs*nrows))))))
  const <- NULL; # incicate we are using this as a name and it does not need a binding.
  x %>% dplyr::mutate(const=1) %>%
    dplyr::arrange(x) %>%
    dplyr::mutate(s=cumsum(const)) %>%
    replyr_filter('s',targets) %>%
    dplyr::collect() %>%
    as.data.frame() -> marks
  polishQ(nrows,marks,probs)
}
