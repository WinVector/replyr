
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
  src <- replyr_get_src(df)
  if(is.null((src))) {
    # some source of local frame
    df[[idColName]] <- seq_len(nrow(df))
    df
  }
  # Spark try
  if(any(c("spark_connection", "spark_shell_connection") %in% class(src))) {
    if(requireNamespace('sparklyr', quietly = TRUE)) {
      sparklyr::sdf_with_unique_id(df, id = idColName)
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