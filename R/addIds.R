
#' Add unique ids to rows.
#'
#' NOT TESTED YET!
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
  # SQL-style try
  REPLYRIDCOLNAME <- NULL # indicate not an unbound variable
  wrapr::let(
    c(REPLYRIDCOLNAME= idColName),
    df %>%
      mutate(REPLYRIDCOLNAME= 1) %>%
      mutate(REPLYRIDCOLNAME= cumsum(REPLYRIDCOLNAME)) -> df
  )
  df
}