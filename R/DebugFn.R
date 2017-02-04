
#' Capture arguments of exception throwing function call for later debugging.
#'
#' Run fn, save arguments on failure.
#' @seealso \code{\link{DebugFn}}, \code{\link{DebugFnW}},  \code{\link{DebugFnWE}}, \code{\link{DebugPrintFn}}, \code{\link{DebugFnE}}, \code{\link{DebugPrintFnE}}
#'
#' @param saveFile path to save RDS to.
#' @param fn function to call
#' @param ... arguments for fn
#' @return fn(...) normally, but if fn(...) throws an exception save to saveFile RDS of list r such that do.call(r$fn,r$args) repeats the call to fn with args.
#'
#' @examples
#'
#' saveName <- paste0(tempfile('debug'),'.RDS')
#' f <- function(i) { (1:10)[[i]] }
#' # correct run
#' DebugFn(saveName, f, 5)
#' # now re-run
#' # capture error on incorrect run
#' tryCatch(
#'    DebugFn(saveName, f, 12),
#'    error = function(e) { print(e) })
#' # examine details
#' situation <- readRDS(saveName)
#' str(situation)
#' # fix and re-run
#' situation$args[[1]] <- 6
#' do.call(situation$fn,situation$args)
#' # clean up
#' file.remove(saveName)
#'
#' @export
DebugFn <- function(saveFile,fn,...) {
  args <- list(...)
  envir = parent.frame()
  namedargs <- match.call()
  fn_name <- as.character(namedargs[['fn']])
  force(saveFile)
  force(fn)
  tryCatch({
    do.call(fn, args, envir=envir)
  },
  error = function(e) {
    if(is.null(saveFile)) {
      saveFile <- paste0(tempfile('debug'),'.RDS')
    }
    saveRDS(object=list(fn=fn,
                        args=args,
                        fn_name=fn_name),
            file=saveFile)
    stop(paste0("replyr::DebugFn: wrote '",saveFile,
                "' on catching '",as.character(e),"'",
                "\n You can reproduce the error with:",
                "\n'p <- readRDS('",saveFile,
                "'); do.call(p$fn, p$args)'"))
    })
}

#' Wrap a function for debugging.
#'
#' Run fn, save arguments on failure.
#' @seealso \code{\link{DebugFn}}, \code{\link{DebugFnW}},  \code{\link{DebugFnWE}}, \code{\link{DebugPrintFn}}, \code{\link{DebugFnE}}, \code{\link{DebugPrintFnE}}
#'
#' Idea from: https://gist.github.com/nassimhaddad/c9c327d10a91dcf9a3370d30dff8ac3d
#'
#' @param saveFile path to save RDS to.
#' @param fn function to call
#' @return wrapped function that saves state on error.
#'
#' @examples
#'
#' saveName <- paste0(tempfile('debug'),'.RDS')
#' f <- function(i) { (1:10)[[i]] }
#' df <- DebugFnW(saveName,f)
#' # correct run
#' df(5)
#' # now re-run
#' # capture error on incorrect run
#' tryCatch(
#'    df(12),
#'    error = function(e) { print(e) })
#' # examine details
#' situation <- readRDS(saveName)
#' str(situation)
#' # fix and re-run
#' situation$args[[1]] <- 6
#' do.call(situation$fn,situation$args)
#' # clean up
#' file.remove(saveName)
#'
#' @export
DebugFnW <- function(saveFile,fn) {
  namedargs <- match.call()
  fn_name <- as.character(namedargs[['fn']])
  force(saveFile)
  force(fn)
  function(...) {
    args <- list(...)
    envir = parent.frame()
    namedargs <- match.call()
    tryCatch({
      do.call(fn, args, envir=envir)
    },
    error = function(e) {
      if(is.null(saveFile)) {
        saveFile <- paste0(tempfile('debug'),'.RDS')
      }
      saveRDS(object=list(fn=fn,
                          args=args,
                          namedargs=namedargs,
                          fn_name=fn_name),
              file=saveFile)
      stop(paste0("replyr::DebugFnW: wrote '",saveFile,
                  "' on catching '",as.character(e),"'",
                  "\n You can reproduce the error with:",
                  "\n'p <- readRDS('",saveFile,
                  "'); do.call(p$fn, p$args)'"))
    })
  }
}


#' Capture arguments of exception throwing function call for later debugging.
#'
#' Run fn and print result, save arguments on failure.  Use on systems like ggplot()
#' where some calculation is delayed until print().
#'
#' @seealso \code{\link{DebugFn}}, \code{\link{DebugFnW}},  \code{\link{DebugFnWE}}, \code{\link{DebugPrintFn}}, \code{\link{DebugFnE}}, \code{\link{DebugPrintFnE}}
#'
#' @param saveFile path to save RDS to.
#' @param fn function to call
#' @param ... arguments for fn
#' @return fn(...) normally, but if fn(...) throws an exception save to saveFile RDS of list r such that do.call(r$fn,r$args) repeats the call to fn with args.
#'
#' @examples
#'
#' saveName <- paste0(tempfile('debug'),'.RDS')
#' f <- function(i) { (1:10)[[i]] }
#' # correct run
#' DebugPrintFn(saveName, f, 5)
#' # now re-run
#' # capture error on incorrect run
#' tryCatch(
#'    DebugPrintFn(saveName, f, 12),
#'    error = function(e) { print(e) })
#' # examine details
#' situation <- readRDS(saveName)
#' str(situation)
#' # fix and re-run
#' situation$args[[1]] <- 6
#' do.call(situation$fn,situation$args)
#' # clean up
#' file.remove(saveName)
#'
#' @export
DebugPrintFn <- function(saveFile,fn,...) {
  args <- list(...)
  namedargs <- match.call()
  fn_name <- as.character(namedargs[['fn']])
  envir = parent.frame()
  force(saveFile)
  force(fn)
  tryCatch({
    res = do.call(fn, args, envir=envir)
    print(res)
    res
  },
  error = function(e) {
    if(is.null(saveFile)) {
      saveFile <- paste0(tempfile('debug'),'.RDS')
    }
    saveRDS(object=list(fn=fn,
                        args=args,
                        fn_name=fn_name),
            file=saveFile)
    stop(paste0("replyr::DebugPrintFn: wrote '",saveFile,
                "' on catching '",as.character(e),"'",
                "\n You can reproduce the error with:",
                "\n'p <- readRDS('",saveFile,
                "'); do.call(p$fn, p$args)'"))
  })
}

#' Capture arguments and environment of exception throwing function call for later debugging.
#'
#' Run fn, save arguments on failure.
#' @seealso \code{\link{DebugFn}}, \code{\link{DebugFnW}},  \code{\link{DebugFnWE}}, \code{\link{DebugPrintFn}}, \code{\link{DebugFnE}}, \code{\link{DebugPrintFnE}}
#'
#' @param saveFile path to save RDS to.
#' @param fn function to call
#' @param ... arguments for fn
#' @return fn(...) normally, but if fn(...) throws an exception save to saveFile RDS of list r such that do.call(r$fn,r$args) repeats the call to fn with args.
#'
#' @examples
#'
#' saveName <- paste0(tempfile('debug'),'.RDS')
#' f <- function(i) { (1:10)[[i]] }
#' # correct run
#' DebugFnE(saveName, f, 5)
#' # now re-run
#' # capture error on incorrect run
#' tryCatch(
#'    DebugFnE(saveName, f, 12),
#'    error = function(e) { print(e) })
#' # examine details
#' situation <- readRDS(saveName)
#' str(situation)
#' # fix and re-run
#' situation$args[[1]] <- 6
#' do.call(situation$fn, situation$args, envir=situation$env)
#' # clean up
#' file.remove(saveName)
#'
#' @export
DebugFnE <- function(saveFile,fn,...) {
  args <- list(...)
  envir = parent.frame()
  namedargs <- match.call()
  fn_name <- as.character(namedargs[['fn']])
  force(saveFile)
  force(fn)
  tryCatch({
    do.call(fn, args, envir=envir)
  },
  error = function(e) {
    if(is.null(saveFile)) {
      saveFile <- paste0(tempfile('debug'),'.RDS')
    }
    saveRDS(object=list(fn=fn,
                        args=args,
                        env=envir,
                        fn_name=fn_name),
            file=saveFile)
    stop(paste0("replyr::DebugFnE: wrote '",saveFile,
                "' on catching '",as.character(e),"'",
                "\n You can reproduce the error with:",
                "\n'p <- readRDS('",saveFile,
                "'); do.call(p$fn, p$args, envir=p$env)'"))
  })
}


#' Wrap function to capture arguments and environment of exception throwing function call for later debugging.
#'
#' Run fn, save arguments on failure.
#' @seealso \code{\link{DebugFn}}, \code{\link{DebugFnW}},  \code{\link{DebugFnWE}}, \code{\link{DebugPrintFn}}, \code{\link{DebugFnE}}, \code{\link{DebugPrintFnE}}
#'
#' Idea from: https://gist.github.com/nassimhaddad/c9c327d10a91dcf9a3370d30dff8ac3d
#'
#' @param saveFile path to save RDS to.
#' @param fn function to call
#' @param ... arguments for fn
#' @return wrapped function that captures state on error.
#'
#' @examples
#'
#' saveName <- paste0(tempfile('debug'),'.RDS')
#' f <- function(i) { (1:10)[[i]] }
#' df <- DebugFnWE(saveName, f)
#' # correct run
#' df(5)
#' # now re-run
#' # capture error on incorrect run
#' tryCatch(
#'    df(12),
#'    error = function(e) { print(e) })
#' # examine details
#' situation <- readRDS(saveName)
#' str(situation)
#' # fix and re-run
#' situation$args[[1]] <- 6
#' do.call(situation$fn, situation$args, envir=situation$env)
#' # clean up
#' file.remove(saveName)
#'
#' @export
DebugFnWE <- function(saveFile,fn,...) {
  namedargs <- match.call()
  fn_name <- as.character(namedargs[['fn']])
  force(saveFile)
  force(fn)
  function(...) {
    args <- list(...)
    envir = parent.frame()
    namedargs <- match.call()
    tryCatch({
      do.call(fn, args, envir=envir)
    },
    error = function(e) {
      if(is.null(saveFile)) {
        saveFile <- paste0(tempfile('debug'),'.RDS')
      }
      saveRDS(object=list(fn=fn,
                          args=args,
                          namedargs=namedargs,
                          fn_name=fn_name,
                          env=envir),
              file=saveFile)
      stop(paste0("replyr::DebugFnWE: wrote '",saveFile,
                  "' on catching '",as.character(e),"'",
                  "\n You can reproduce the error with:",
                  "\n'p <- readRDS('",saveFile,
                  "'); do.call(p$fn, p$args, envir=p$env)'"))
    })
  }
}

#' Capture arguments and environment of exception throwing function call for later debugging.
#'
#' Run fn and print result, save arguments on failure.  Use on systems like ggplot()
#' where some calculation is delayed until print().
#'
#' @seealso \code{\link{DebugFn}}, \code{\link{DebugFnW}},  \code{\link{DebugFnWE}}, \code{\link{DebugPrintFn}}, \code{\link{DebugFnE}}, \code{\link{DebugPrintFnE}}
#'
#' @param saveFile path to save RDS to.
#' @param fn function to call
#' @param ... arguments for fn
#' @return fn(...) normally, but if fn(...) throws an exception save to saveFile RDS of list r such that do.call(r$fn,r$args) repeats the call to fn with args.
#'
#' @examples
#'
#' saveName <- paste0(tempfile('debug'),'.RDS')
#' f <- function(i) { (1:10)[[i]] }
#' # correct run
#' DebugPrintFnE(saveName, f, 5)
#' # now re-run
#' # capture error on incorrect run
#' tryCatch(
#'    DebugPrintFnE(saveName, f, 12),
#'    error = function(e) { print(e) })
#' # examine details
#' situation <- readRDS(saveName)
#' str(situation)
#' # fix and re-run
#' situation$args[[1]] <- 6
#' do.call(situation$fn, situation$args, envir=situation$env)
#' # clean up
#' file.remove(saveName)
#'
#' @export
DebugPrintFnE <- function(saveFile,fn,...) {
  args <- list(...)
  envir = parent.frame()
  namedargs <- match.call()
  fn_name <- as.character(namedargs[['fn']])
  force(saveFile)
  force(fn)
  tryCatch({
    res = do.call(fn, args, envir=envir)
    print(res)
    res
  },
  error = function(e) {
    if(is.null(saveFile)) {
      saveFile <- paste0(tempfile('debug'),'.RDS')
    }
    saveRDS(object=list(fn=fn,
                        args=args,
                        env=envir,
                        fn_name=fn_name),
            file=saveFile)
    stop(paste0("replyr::DebugPrintFnE: wrote '",saveFile,
                "' on catching '",as.character(e),"'",
                "\n You can reproduce the error with:",
                "\n'p <- readRDS('",saveFile,
                "'); do.call(p$fn, p$args, envir=p$env)'"))
  })
}

