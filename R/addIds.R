
#' Add unique ids to rows.  Note: re-arranges rows in many cases.
#'
#'
#' @param df data.frame object to work with
#' @param idColName name of column to add
#' @param env environment to evaluate in (not used).
#' @param local_short_cut logical, if TRUE use base R on local data.
#'
#' @examples
#'
#' replyr_add_ids(data.frame(x=c('a','b')), 'id', local_short_cut = FALSE)
#'
#' @export
replyr_add_ids <- function(df, idColName,
                           env = parent.frame(),
                           local_short_cut = TRUE) {
  force(env)
  if(local_short_cut) {
    if(replyr_is_local_data(df)) {
      # some source of local frame
      df[[idColName]] <- seq_len(replyr_nrow(df))
      return(df)
    }
  }
  if(replyr_is_Spark_data(df)) {
    if(requireNamespace('sparklyr', quietly = TRUE)) {
      return(sparklyr::sdf_with_unique_id(df, id = idColName))
    }
  }
  # dplyr style, throws if not ordered
  REPLYRIDCOLNAME <- NULL # indicate not an unbound variable
  row_number <- dplyr::row_number # declare not unbound function
  # using dplyr::row_number() throws:  Error in UseMethod("escape") :
  #   no applicable method for 'escape' applied to an object of class "function"
  # Also https://github.com/tidyverse/dplyr/issues/3008
  wrapr::let(
    c(REPLYRIDCOLNAME= idColName),
    df <-
      mutate(df, REPLYRIDCOLNAME = row_number())
  )
  # # SQL-style try, only warns if not ordered
  # REPLYRIDCOLNAME <- NULL # indicate not an unbound variable
  # wrapr::let(
  #   c(REPLYRIDCOLNAME= idColName),
  #   df %.>%
  #     mutate(., REPLYRIDCOLNAME= 1) %.>%
  #     mutate(., REPLYRIDCOLNAME= cumsum(REPLYRIDCOLNAME)) -> df
  # )
  df
}