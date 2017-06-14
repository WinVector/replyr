


#' Add constant to a table.
#'
#' Work around different treatment of character types accross remote
#' data soures when adding a
#' constant column to a table.  Deals with issues such as Postgresql
#' requiring a charcater-cast and MySQL not allowing such.
#'
#' @param d data.frame like object to add column to.
#' @param colName character, name of column to add.
#' @param val scalar, value to add.
#' @param ... force later arguments to be bound by name.
#' @param tempNameGenerator temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.
#' @return table with new column added.
#'
#' @examples
#'
#' d <- data.frame(x= c(1:3))
#' addConstantColumn(d, 'newCol', 'newVal')
#'
#' @export
addConstantColumn <- function(d,
                              colName, val,
                              ...,
                              tempNameGenerator= makeTempNameGenerator("replyr_addConstantColumn")) {
  # PostgresSQL and Spark1.6.2 don't like blank character values
  # hope dplyr lazyeval carries the cast over to the database
  # And MySQL can't accept the SQL dplyr emits with character cast
  if((length(colName)!=1)||(!is.character(colName))) {
    stop("replyr::addConstantColumn colName must be a string")
  }
  if((length(val)!=1)||(is.list(val))) {
    stop("replyr::addConstantColumn val non-nul length 1 vector")
  }
  isMySQL <- replyr_is_MySQL_data(d)
  useCharCast <- is.character(val) && (!isMySQL)
  if(useCharCast) {
    let(list(REPLYRCOLNAME=colName),
        dm <- dplyr::mutate(d, REPLYRCOLNAME=as.character(val))
    )
  } else {
    let(list(REPLYRCOLNAME=colName),
        dm <- dplyr::mutate(d, REPLYRCOLNAME=val)
    )
  }
  # force calculation as chaning of replyr_private_name_vi was chaning previously assigned columns!
  # needed to work around this: https://github.com/WinVector/replyr/blob/master/issues/TrailingRefIssue.md
  dm <- dplyr::compute(dm, name= tempNameGenerator())
  throwAway <- collect(head(dm)) # make sure calc is forced
  dm
}
