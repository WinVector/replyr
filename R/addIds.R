
#' Add unique ids to rows.  Note: re-arranges rows in many cases.
#'
#'
#' @param df data.frame object to work with
#' @param idColName name of column to add
#'
#' @examples
#'
#' replyr_add_ids(data.frame(x=c('a','b')), 'id')
#'
#' @export
replyr_add_ids <- function(df, idColName) {
  if(replyr_is_local_data(df)) {
    # some source of local frame
    df[[idColName]] <- seq_len(nrow(df))
    return(df)
  }
  if(replyr_is_Spark_data(df)) {
    if(requireNamespace('sparklyr', quietly = TRUE)) {
      return(sparklyr::sdf_with_unique_id(df, id = idColName))
    }
  }
  # arrange all
  collist <- paste(colnames(df), collapse=', ')
  colsort <- paste('dplyr::arrange(df,', collist, ')')
  df <- eval(parse(text= colsort))
  # dplyr style, throws if not ordered
  REPLYRIDCOLNAME <- NULL # indicate not an unbound variable
  row_number <- function(...) { NULL } # declare not unbound function
  # using dplyr::row_number() throws:  Error in UseMethod("escape") :
  #   no applicable method for 'escape' applied to an object of class "function"
  wrapr::let(
    c(REPLYRIDCOLNAME= idColName),
    df %>%
      mutate(REPLYRIDCOLNAME = row_number()) -> df
  )
  # # SQL-style try, only warns if not ordered
  # REPLYRIDCOLNAME <- NULL # indicate not an unbound variable
  # wrapr::let(
  #   c(REPLYRIDCOLNAME= idColName),
  #   df %>%
  #     mutate(REPLYRIDCOLNAME= 1) %>%
  #     mutate(REPLYRIDCOLNAME= cumsum(REPLYRIDCOLNAME)) -> df
  # )
  df
}