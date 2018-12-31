

#' @importFrom dplyr n
NULL

getConcreteTableName <- function(handle) {
  # TODO: get a safe way to get the concrete name
  #  https://github.com/tidyverse/dplyr/issues/2824
  concreteName <- as.character(handle$ops$x)
}

#' build some example tables
#'
#' @param con db connection
#' @return example tables
#'
#'
#' @export
#
example_employeeAndDate <- function(con) {
  . <- NULL # Declare not an unbound varaible
  # note: employeeanddate is likely built as a cross-product
  #       join of an employee table and set of dates of interest
  #       before getting to the join controller step.  We call
  #       such a table "row control" or "experimental design."
  keymap <- list()
  DBI::dbExecute(con, "
  CREATE TABLE employeeanddate (
                 id TEXT,
                 date INTEGER
  );
                 ")
  keymap[['employeeanddate']] = c()
  data.frame(id= c('i4', 'i4'),
             date = c(20140501, 20140601)) %.>%
    DBI::dbWriteTable(con, 'employeeanddate', value=., append=TRUE)
  DBI::dbExecute(con, "
                 CREATE TABLE orgtable (
                 eid TEXT,
                 date INTEGER,
                 dept TEXT,
                 location TEXT,
                 PRIMARY KEY (eid, date)
                 );
                 ")
  keymap[['orgtable']] = c('eid', 'date')
  data.frame(eid= c('i4', 'i4'),
             date = c(20140501, 20140601),
             dept = c('IT', 'SL'),
             location = c('CA', 'TX')) %.>%
    DBI::dbWriteTable(con, 'orgtable', value=., append=TRUE)
  DBI::dbExecute(con, "
                 CREATE TABLE revenue (
                 date INTEGER,
                 dept TEXT,
                 rev INTEGER,
                 PRIMARY KEY (date, dept)
                 );
                 ")
  keymap[['revenue']] = c('dept', 'date')
  data.frame(date = c(20140501, 20140601),
             dept = c('SL', 'SL'),
             rev = c(1000, 2000)) %.>%
    DBI::dbWriteTable(con, 'revenue', value=., append=TRUE)
  DBI::dbExecute(con, "
                 CREATE TABLE activity (
                 eid TEXT,
                 date INTEGER,
                 hours INTEGER,
                 location TEXT,
                 PRIMARY KEY (eid, date)
                 );
                 ")
  keymap[['activity']] = c('eid', 'date')
  data.frame(eid= c('i4', 'i4'),
             date = c(20140501, 20140601),
             hours = c(50, 3),
             location = c('office', 'client')) %.>%
    DBI::dbWriteTable(con, 'activity', value=., append=TRUE)
  tableNames <- c('employeeanddate',
                  'revenue',
                  'activity',
                  'orgtable')
  key_inspector_by_name <- function(handle) {
    concreteName <- getConcreteTableName(handle)
    keys <- keymap[[concreteName]]
    names(keys) <- keys
    keys
  }
  tDesc <- tableNames %.>%
    lapply(.,
      function(ni) {
        replyr::tableDescription(ni,
                                 dplyr::tbl(con, ni),
                                 keyInspector = key_inspector_by_name)
      }) %.>%
    dplyr::bind_rows(.)
  tDesc
}


uniqueInOrder <- function(names) {
  name <- NULL # declare not unbound reference
  rowid <- NULL # declare not unbound reference
  dn <- data.frame(name= names,
                   rowid= seq_len(length(names)),
                   stringsAsFactors = FALSE)
  dn <- dn %.>%
    dplyr::group_by(., name) %.>%
    dplyr::summarize(., rowid=min(rowid)) %.>%
    dplyr::arrange(., rowid)
  dn$name
}



makeTableIndMap <- function(tableNameSeq) {
  tableNameSeq <- uniqueInOrder(tableNameSeq)
  tableIndColNames <- paste('table',
                            gsub("[^a-zA-Z0-9]+", '_', tableNameSeq),
                            'present', sep= '_')
  names(tableIndColNames) <- tableNameSeq
  tableIndColNames
}


#' Return all columns as guess at preferred primary keys.
#'
#' @seealso \code{tableDescription}
#'
#' @param handle data handle
#' @return map of keys to keys
#'
#' @examples
#'
#' d <- data.frame(x=1:3, y=NA)
#' key_inspector_all_cols(d)
#'
#' @export
#'
key_inspector_all_cols <- function(handle) {
  cols <- colnames(handle)
  keys <- cols
  names(keys) <- keys
  keys
}


#' Return all primary key columns as guess at preferred primary keys for a SQLite handle.
#'
#' @seealso \code{tableDescription}
#'
#' @param handle data handle
#' @return map of keys to keys
#'
#'
#' @export
#'
key_inspector_sqlite <- function(handle) {
  src <- replyr_get_src(handle)
  if(is.null(src) || is.character(src)) {
    stop("replyr::key_inspector_sqlite: not a SQLite source")
  }
  con <- dplyr_src_to_db_handle(src)
  if(is.null(con) || is.character(con)) {
    stop("replyr::key_inspector_sqlite: could not get DB handle")
  }
  concreteName <- getConcreteTableName(handle)
  if(is.null(concreteName) || (!is.character(concreteName))) {
    stop("replyr::key_inspector_sqlite: could not get concrete table name")
  }
  tabInfo <- DBI::dbGetQuery(con,
                             paste0("pragma table_info(",
                                    concreteName,
                                    ")"))
  keys <- NULL
  if((!is.null(tabInfo))&&(replyr_nrow(tabInfo)>0)) {
    keys <- tabInfo$name[tabInfo$pk>0]
    names(keys) <- keys
  }
  keys
}


#' Return all primary key columns as guess at preferred primary keys for a PostgreSQL handle.
#'
#' @seealso \code{tableDescription}
#'
#' @param handle data handle
#' @return map of keys to keys
#'
#'
#' @export
#'
key_inspector_postgresql <- function(handle) {
  src <- replyr_get_src(handle)
  if(is.null(src) || is.character(src)) {
    stop("replyr::key_inspector_postgresql: not a PostgreSQL source")
  }
  con <- dplyr_src_to_db_handle(src)
  if(is.null(con) || is.character(con)) {
    stop("replyr::key_inspector_postgresql: could not get DB handle")
  }
  concreteName <- getConcreteTableName(handle)
  if(is.null(concreteName) || (!is.character(concreteName))) {
    stop("replyr::key_inspector_postgresql: could not get concrete table name")
  }
  # from https://wiki.postgresql.org/wiki/Retrieve_primary_key_columns
  q <- paste0(
    "
    SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type
    FROM   pg_index i
    JOIN   pg_attribute a ON a.attrelid = i.indrelid
    AND a.attnum = ANY(i.indkey)
    WHERE  i.indrelid = '", concreteName, "'::regclass
    AND    i.indisprimary;
    "
  )
  tabInfo <- DBI::dbGetQuery(con, q)
  keys <- NULL
  if((!is.null(tabInfo))&&(replyr_nrow(tabInfo)>0)) {
    keys <- tabInfo$attname
    names(keys) <- keys
  }
  keys
}

#' Build a nice description of a table.
#'
#' Please see \url{http://www.win-vector.com/blog/2017/05/managing-spark-data-handles-in-r/} for details.
#' Note: one usually needs to alter the keys column which is just populated with all columns.
#'
#' Please see \code{vignette('DependencySorting', package = 'replyr')} and \code{vignette('joinController', package= 'replyr')} for more details.
#'
#' @seealso \code{\link{buildJoinPlan}}, \code{\link{keysAreUnique}}, \code{\link{makeJoinDiagramSpec}}, \code{\link{executeLeftJoinPlan}}
#'
#' @param tableName name of table to add to join plan.
#' @param handle table or table handle to add to join plan (can already be in the plan).
#' @param ... force later arguments to bind by name.
#' @param keyInspector function that determines preferred primary key set for table.
#' @return table describing the data.
#'
#' @examples
#'
#' d <- data.frame(x=1:3, y=NA)
#' tableDescription('d', d)
#'
#'
#' @export
#'
tableDescription <- function(tableName,
                            handle,
                            ...,
                            keyInspector= key_inspector_all_cols) {
  if(length(nchar(tableName))<=0) {
    stop("replyr::tableDescription empty name")
  }
  sample <- dplyr::collect(head(handle))
  cols <- colnames(handle)
  # may not get classes on empty tables
  # https://github.com/tidyverse/dplyr/issues/2913
  classes <- vapply(cols,
                    function(si) {
                      paste(class(sample[[si]]),
                                  collapse=', ')
                    }, character(1))
  source <- replyr_get_src(handle)
  keys <- keyInspector(handle)
  tableIndColNames <- makeTableIndMap(tableName)
  if(length(intersect(tableIndColNames, cols))>0) {
    warning("replyr::tableDescription table_CLEANEDTABNAME_present column may cause problems (please consider renaming before these steps)")
  }
  dplyr::data_frame(tableName= tableName,
                    handle= list(handle),
                    columns= list(cols),
                    keys= list(keys),
                    colClass= list(classes),
                    sourceClass= paste(class(source), collapse = " "),
                    isEmpty= replyr_nrow(sample)<=0,
                    indicatorColumn= tableIndColNames[[1]])
}


#' Check uniqueness of rows with respect to keys.
#'
#' Can be an expensive operation.
#'
#' @seealso \code{\link{tableDescription}}
#'
#' @param tDesc description of tables, from \code{\link{tableDescription}} (and likely altered by user).
#' @return logical TRUE if keys are unique
#'
#' @examples
#'
#' d <- data.frame(x=c(1,1,2,2,3,3), y=c(1,2,1,2,1,2))
#' tDesc1 <- tableDescription('d1', d)
#' tDesc2 <- tableDescription('d2', d)
#' tDesc <- rbind(tDesc1, tDesc2)
#' tDesc$keys[[2]] <- c(x='x')
#' keysAreUnique(tDesc)
#'
#' @export
#'
keysAreUnique <- function(tDesc) {
  isunique <- vapply(seq_len(replyr_nrow(tDesc)),
                     function(i) {
                       gi <- tDesc$handle[[i]]
                       nrow <- replyr::replyr_nrow(gi)
                       if(nrow<=0) {
                         return(TRUE)
                       }
                       keys <- tDesc$keys[[i]]
                       nunique <- gi %.>%
                         replyr_group_by(., keys) %.>%
                         dplyr::summarize(., count = n()) %.>%
                         replyr::replyr_nrow(.)
                       return(nunique==nrow)
                     },
                     logical(1))
  names(isunique) <- tDesc$tableName
  isunique
}

# type unstable: return data.frame if okay, character if problem
inspectAndLimitJoinPlan <- function(columnJoinPlan, checkColClasses) {
  # sanity check
  for(ci in c('tableName', 'sourceColumn', 'sourceClass', 'resultColumn')) {
    if(is.null(columnJoinPlan[[ci]])) {
      return(paste('columnJoinPlan column', ci, 'not present'))
    }
    if(!is.character(columnJoinPlan[[ci]])) {
      return(paste('columnJoinPlan column', ci, 'should be of type character'))
    }
    if(any(nchar(columnJoinPlan[[ci]])<=0) ||
       any(is.na(columnJoinPlan))) {
      return(paste("empty or NA', ci, ' column in columnJoinPlan"))
    }
  }
  for(ci in c('isKey','want')) {
    if(is.null(columnJoinPlan[[ci]])) {
      return(paste('columnJoinPlan column', ci, 'not present'))
    }
    if(!is.logical(columnJoinPlan[[ci]])) {
      return(paste('columnJoinPlan column', ci, 'should be of type logical'))
    }
    if(any(is.na(columnJoinPlan))) {
      return(paste("NA', ci, ' colum in columnJoinPlan"))
    }
  }
  if(any(columnJoinPlan$isKey & (!columnJoinPlan$want))) {
    return("any row marked isKey must also be marked want")
  }
  valCols <- columnJoinPlan$resultColumn[!columnJoinPlan$isKey]
  if(length(valCols) !=
     length(unique(valCols))) {
    return("columnJoinPlan result columns must be unique")
  }
  tabs <-  uniqueInOrder(columnJoinPlan$tableName)
  for(tabnam in tabs) {
    ci <- columnJoinPlan[columnJoinPlan$tableName==tabnam, , drop=FALSE]
    if(length(ci$sourceColumn) !=
       length(unique(ci$sourceColumn))) {
      return(paste("columnJoinPlan sourceColumns not unique for table",
                   ci))
    }
    if((sum(ci$isKey)<=0) && (tabnam!=tabs[[1]])) {
      return("no keys for table", tabnam)
    }
  }
  tableIndColNames <- makeTableIndMap(columnJoinPlan$tableName)
  tabNOverlap <- intersect(tableIndColNames,
                           c(columnJoinPlan$resultColumn, columnJoinPlan$sourceColumn))
  if(length(tabNOverlap)>0) {
    return(paste("column source or result names intersect table present columns:",
                 paste(tabNOverlap, collapse = ', ')))

  }
  # limit down to things we are using
  columnJoinPlan <- columnJoinPlan[columnJoinPlan$want, , drop=FALSE]
  # check a few desired invariants of the plan
  columnJoinPlan$joinSource <- ''
  prevResultColInfo <- list()
  for(tabnam in tabs) {
    ci <- columnJoinPlan[columnJoinPlan$tableName==tabnam, , drop=FALSE]
    cMap <- ci$sourceClass
    names(cMap) <- ci$resultColumn
    keyCols <- ci$resultColumn[ci$isKey]
    if(tabnam!=tabs[[1]]) {
      if(length(keyCols)<=0) {
        return(paste("table", tabnam, "declares no keys"))
      }
    }
    resCols <- ci$resultColumn[ci$want]
    if(length(prevResultColInfo)>0) {
      missedKeys <- setdiff(keyCols, names(prevResultColInfo))
      if(length(missedKeys)>0) {
        return(paste("key col(s) (",
                     paste(missedKeys, collapse = ', '),
                     ") not contained in result cols of previous table(s) for table:", tabnam))
      }
      for(ki in keyCols) {
        prevInfo <- prevResultColInfo[[ki]]
        #print(paste(prevInfo$tabableName, ki, '->', tabnam, ki))
        columnJoinPlan$joinSource[(columnJoinPlan$tableName==tabnam) &
                         (columnJoinPlan$resultColumn==ki)] <- prevInfo$tabableName
      }
    }
    for(ki in resCols) {
      prevInfo <- prevResultColInfo[[ki]]
      curClass <- cMap[[ki]]
      if((checkColClasses)&&(!is.null(prevInfo))&&
         (curClass!=prevInfo$clsname)) {
        return(paste("column",ki,"changed from",
                     prevInfo$clsname,"to",curClass,"at table",
                     tabnam))

      }
      if(is.null(prevInfo)) {
        prevResultColInfo[[ki]] <- list(clsname= curClass,
                                        tabableName= tabnam)
      }
    }
  }
  columnJoinPlan
}


#' Topologically sort join plan so values are available before uses.
#'
#' Depends on \code{igraph} package.
#' Please see \code{vignette('DependencySorting', package = 'replyr')} and \code{vignette('joinController', package= 'replyr')} for more details.
#'
#' @param columnJoinPlan join plan
#' @param leftTableName which table is left
#' @param ... force later arguments to bind by name
#' @return list with dependencyGraph and sorted columnJoinPlan
#'
#' @examples
#'
#' if (requireNamespace("RSQLite", quietly = TRUE)) {
#'   # note: employeeanddate is likely built as a cross-product
#'   #       join of an employee table and set of dates of interest
#'   #       before getting to the join controller step.  We call
#'   #       such a table "row control" or "experimental design."
#'   my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#'   RSQLite::initExtension(my_db)
#'   tDesc <- example_employeeAndDate(my_db)
#'   columnJoinPlan <- buildJoinPlan(tDesc, check= FALSE)
#'   # unify keys
#'   columnJoinPlan$resultColumn[columnJoinPlan$resultColumn=='id'] <- 'eid'
#'   # look at plan defects
#'   print(paste('problems:',
#'               inspectDescrAndJoinPlan(tDesc, columnJoinPlan)))
#'   # fix plan
#'   if(requireNamespace('igraph', quietly = TRUE)) {
#'     sorted <- topoSortTables(columnJoinPlan, 'employeeanddate')
#'     print(paste('problems:',
#'                 inspectDescrAndJoinPlan(tDesc, sorted$columnJoinPlan)))
#'     # plot(sorted$dependencyGraph)
#'   }
#'   DBI::dbDisconnect(my_db)
#'   my_db <- NULL
#' }
#'
#' @export
#'
topoSortTables <- function(columnJoinPlan, leftTableName,
                           ...) {
  if(!requireNamespace('igraph', quietly = TRUE)) {
    warning("topoSortTables: requres igraph to sort tables")
    return(list(columnJoinPlan= columnJoinPlan,
                dependencyGraph= NULL,
                tableOrder= NULL))
  }
  g <- igraph::make_empty_graph()
  vnams <- sort(unique(columnJoinPlan$tableName))
  for(vi in vnams) {
    g <- g + igraph::vertex(vi)
  }
  # left table is special, prior to all
  for(vi in setdiff(vnams, leftTableName)) {
    g <- g + igraph::edge(leftTableName, vi)
  }
  # add in any other order conditions
  n <- length(vnams)
  for(vii in seq_len(n)) {
    if(vnams[[vii]]!=leftTableName) {
      ci <- columnJoinPlan[columnJoinPlan$tableName==vnams[[vii]], ,
                           drop=FALSE]
      knownI <- ci$resultColumn[!ci$isKey]
      for(vjj in setdiff(seq_len(n), vii)) {
        if(vnams[[vjj]]!=leftTableName) {
          cj <- columnJoinPlan[columnJoinPlan$tableName==vnams[[vjj]], ,
                               drop=FALSE]
          keysJ <- cj$resultColumn[cj$isKey]
          if(length(intersect(knownI, keysJ))>0) {
            g <- g + igraph::edge(vnams[[vii]], vnams[[vjj]])
          }
        }
      }
    }
  }
  tableOrder <- vnams[as.numeric(igraph::topo_sort(g))]
  tabs <- split(columnJoinPlan, columnJoinPlan$tableName)
  tabs <- tabs[tableOrder]
  list(columnJoinPlan= dplyr::bind_rows(tabs),
       dependencyGraph= g,
       tableOrder= tableOrder)
}

#' Build a drawable specification of the join diagram
#'
#' Please see \code{vignette('DependencySorting', package = 'replyr')} and \code{vignette('joinController', package= 'replyr')} for more details.
#'
#' @seealso \code{\link{tableDescription}}, \code{\link{buildJoinPlan}}, \code{\link{executeLeftJoinPlan}}
#'
#' @param columnJoinPlan join plan
#' @param ... force later arguments to bind by name
#' @param groupByKeys logical if true build key-equivalent sub-graphs
#' @param graphOpts options for graphViz
#' @return grViz diagram spec
#'
#' @examples
#'
#'
#' if (requireNamespace("RSQLite", quietly = TRUE)) {
#'   # note: employeeanddate is likely built as a cross-product
#'   #       join of an employee table and set of dates of interest
#'   #       before getting to the join controller step.  We call
#'   #       such a table "row control" or "experimental design."
#'   my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#'   RSQLite::initExtension(my_db)
#'   tDesc <- example_employeeAndDate(my_db)
#'   # fix order by hand, please see replyr::topoSortTables for
#'   # how to automate this.
#'   ord <- match(c('employeeanddate', 'orgtable', 'activity', 'revenue'),
#'                tDesc$tableName)
#'   tDesc <- tDesc[ord, , drop=FALSE]
#'   columnJoinPlan <- buildJoinPlan(tDesc, check= FALSE)
#'   # unify keys
#'   columnJoinPlan$resultColumn[columnJoinPlan$resultColumn=='id'] <- 'eid'
#'   # look at plan defects
#'   print(paste('problems:',
#'               inspectDescrAndJoinPlan(tDesc, columnJoinPlan)))
#'   diagramSpec <- makeJoinDiagramSpec(columnJoinPlan)
#'   # to render as JavaScript:
#'   #   DiagrammeR::grViz(diagramSpec)
#'   DBI::dbDisconnect(my_db)
#'   my_db <- NULL
#' }
#'
#' @export
#'
#'
makeJoinDiagramSpec <- function(columnJoinPlan, ...,
                                groupByKeys= TRUE,
                                graphOpts= NULL) {
  columnJoinPlan <- inspectAndLimitJoinPlan(columnJoinPlan, FALSE)
  if(is.character(columnJoinPlan)) {
    stop(columnJoinPlan)
  }
  if(is.null(graphOpts)) {
    graphOpts <- paste(" graph [",
                       "layout = dot, rankdir = LR, overlap = prism,",
                       "compound = true, nodesep = .5, ranksep = .25]\n",
                       " edge [decorate = true, arrowhead = dot]\n",
                       " node [style=filled, fillcolor=lightgrey]\n")
  }
  tabs <- uniqueInOrder(columnJoinPlan$tableName)
  tabIndexes <- seq_len(length(tabs))
  names(tabIndexes) <- tabs
  keysToGroups <- list()
  graph <- paste0("digraph joinplan {\n ", graphOpts, "\n")
  # pass 1: define nodes and groups of nodes
  for(idx in seq_len(length(tabs))) {
    ti <- tabs[[idx]]
    ci <- columnJoinPlan[columnJoinPlan$tableName==ti, ,
                         drop=FALSE]
    keys <- paste('{',
                  paste(sort(ci$resultColumn[ci$isKey]),
                  collapse = ', '),
                  '}')
    if(nchar(keys)<=0) {
      keys <- '.' # can't use '' as a list key
    }
    keysToGroups[[keys]] <- c(keysToGroups[[keys]], idx)
    sourceAnnotations <- paste(' (', ci$sourceColumn, ')')
    ind <- NULL
    if(idx>1) {
      ind <- paste('i:', makeTableIndMap(ti)[[1]])
    }
    cols <- paste0(ifelse(ci$isKey, 'k: ', 'v: '),
                  ci$resultColumn,
                  ifelse(ci$resultColumn==ci$sourceColumn,
                         '', sourceAnnotations))
    cols <- paste(c(ind, cols), collapse ='\\l')
    ndi <- paste0(idx, ': ', ti, '\n\\l', cols)
    shape = 'tab'
    if(idx<=1) {
      shape = 'folder'
    }
    graph <- paste0(graph, "\n  ",
                    'node', idx,
                    " [ shape = '", shape, "' , label = '", ndi, "\\l']\n"
                    )
  }
  # pass 2: edges
  columnJoinPlanK <- columnJoinPlan[columnJoinPlan$isKey, ,
                                    drop=FALSE]
  for(tii in seq_len(length(tabs))) {
    ti <- tabs[[tii]]
    ci <- columnJoinPlanK[columnJoinPlanK$tableName==ti &
                            nchar(columnJoinPlanK$joinSource)>0, ,
                          drop=FALSE]
    sources <- sort(unique(ci$joinSource))
    for(si in sources) {
      sii <- tabIndexes[[si]]
      ki <- paste(ci$resultColumn[ci$joinSource==si],
                  collapse = '\\l')
      graph <- paste0(graph, "\n",
                      " node", sii, " -> ", "node", tii,
                      " [ label='", ki, "\\l' ]")
    }
  }
  if(groupByKeys) {
    # assign subgraphs
    for(gii in seq_len(length(names(keysToGroups)))) {
      gi <- names(keysToGroups)[[gii]]
      group <- keysToGroups[[gi]]
      if(length(group)>0) {
        group <- paste0('node', group)
        graph <- paste0(graph, '\n',
                        'subgraph cluster_', gii, ' {\n',
                        'label = "',gi,'"\n',
                        paste(group, collapse=' ; '),
                        '\n}')
      }
    }
  }
  graph <- paste0(graph, '\n', '}\n')
  graph
}








#' check that a join plan is consistent with table descriptions
#'
#' Please see \code{vignette('DependencySorting', package = 'replyr')} and \code{vignette('joinController', package= 'replyr')} for more details.
#' @seealso \code{\link{tableDescription}}, \code{\link{buildJoinPlan}}, \code{\link{makeJoinDiagramSpec}}, \code{\link{executeLeftJoinPlan}}
#'
#' @param tDesc description of tables, from \code{\link{tableDescription}} (and likely altered by user).
#' @param columnJoinPlan columns to join, from \code{\link{buildJoinPlan}} (and likely altered by user). Note: no column names must intersect with names of the form \code{table_CLEANEDTABNAME_present}.
#' @param ... force later arguments to bind by name.
#' @param checkColClasses logical if true check for exact class name matches
#' @return NULL if okay, else a string
#'
#' @examples
#'
#' # example data
#' d1 <- data.frame(id= 1:3,
#'                  weight= c(200, 140, 98),
#'                  height= c(60, 24, 12))
#' d2 <- data.frame(pid= 2:3,
#'                  weight= c(130, 110),
#'                  width= 1)
#' # get the initial description of table defs
#' tDesc <- rbind(tableDescription('d1', d1),
#'                tableDescription('d2', d2))
#' # declare keys (and give them consistent names)
#' tDesc$keys[[1]] <- list(PrimaryKey= 'id')
#' tDesc$keys[[2]] <- list(PrimaryKey= 'pid')
#' # build the join plan
#' columnJoinPlan <- buildJoinPlan(tDesc)
#' # confirm the plan
#' inspectDescrAndJoinPlan(tDesc, columnJoinPlan,
#'                         checkColClasses= TRUE)
#' # damage the plan
#' columnJoinPlan$sourceColumn[columnJoinPlan$sourceColumn=='width'] <- 'wd'
#' # find a problem
#' inspectDescrAndJoinPlan(tDesc, columnJoinPlan,
#'                         checkColClasses= TRUE)
#'
#' @export
#'
inspectDescrAndJoinPlan <- function(tDesc, columnJoinPlan,
                                    ...,
                                    checkColClasses= FALSE) {
  columnJoinPlan <- inspectAndLimitJoinPlan(columnJoinPlan,
                                 checkColClasses=checkColClasses)
  if(is.character(columnJoinPlan)) {
    return(columnJoinPlan)
  }
  # sanity check
  if(length(unique(tDesc$tableName)) != length(tDesc$tableName)) {
    return("non-unique table names in tDesc")
  }
  # limit down to things we are using
  tabsC <- unique(columnJoinPlan$tableName)
  if(length(setdiff(tabsC, tDesc$tableName))>0) {
    return("tDesc does not have all the needed tables to join")
  }
  tDesc <- tDesc[tDesc$tableName %in% tabsC, , drop=FALSE]
  if( replyr_nrow(tDesc)<=0) {
    return("no tables selected")
  }
  tabsD <- unique(tDesc$tableName)
  columnJoinPlan <- columnJoinPlan[columnJoinPlan$tableName %in% tabsD, ,
                                   drop=FALSE]
  # check a few desired invariants of the plan
  for(i in seq_len(replyr_nrow(tDesc))) {
    tnam <- tDesc$tableName[[i]]
    ci <- columnJoinPlan[columnJoinPlan$tableName==tnam, , drop=FALSE]
    # don't check tDesc$keys here, as it isn't used after join plan is constructed.
    if(!all(ci$sourceColumn %in% tDesc$columns[[i]])) {
      probs <- paste(setdiff(ci$sourceColumn, tDesc$columns[[i]]),
                     collapse = ', ')
      return(paste("table description",
                   tnam, "refers to non-column(s):",probs))
    }
  }
  return(NULL) # okay!
}



#' Build a join plan
#'
#' Please see \code{vignette('DependencySorting', package = 'replyr')} and \code{vignette('joinController', package= 'replyr')} for more details.
#' @seealso \code{\link{tableDescription}}, \code{\link{inspectDescrAndJoinPlan}}, \code{\link{makeJoinDiagramSpec}}, \code{\link{executeLeftJoinPlan}}
#'
#' @param tDesc description of tables from \code{\link{tableDescription}} (and likely altered by user). Note: no column names must intersect with names of the form \code{table_CLEANEDTABNAME_present}.
#' @param ... force later arguments to bind by name.
#' @param check logical, if TRUE check the join plan for consistency.
#' @return detailed column join plan (appropriate for editing)
#'
#' @examples
#'
#' d <- data.frame(id=1:3, weight= c(200, 140, 98))
#' tDesc <- rbind(tableDescription('d1', d),
#'                tableDescription('d2', d))
#' tDesc$keys[[1]] <- list(PrimaryKey= 'id')
#' tDesc$keys[[2]] <- list(PrimaryKey= 'id')
#' buildJoinPlan(tDesc)
#'
#' @export
#'
buildJoinPlan <- function(tDesc,
                          ...,
                          check= TRUE) {
  count <- NULL # declare not an unbound ref
  ntab <- replyr_nrow(tDesc)
  if(length(unique(tDesc$tableName))!=ntab) {
    stop("replyr::buildJoinPlan must have unique table name(s)")
  }
  if(any(nchar(tDesc$tableName)<=0)) {
    stop("replyr::buildJoinPlan empty table name(s)")
  }
  plans <- vector(ntab, mode='list')
  for(i in seq_len(ntab)) {
    cols <- tDesc$columns[[i]]
    keys <- tDesc$keys[[i]]
    tnam <- tDesc$tableName[[i]]
    classes <- tDesc$colClass[[i]]
    if(length(cols)<=0) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "no columns"))
    }
    if((length(keys)<=0)&&(i>1)) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "no keys"))
    }
    if(any(nchar(keys)<=0)) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "empty key columns"))
    }
    if(length(unique(keys))!=length(keys)) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "declares duplicate key columns"))
    }
    if(any(nchar(names(keys))<=0)) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "empty key mappings"))
    }
    if(length(unique(names(keys)))!=length(names(keys))) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "declares duplicate key mappings"))
    }
    if(!all(keys %in% cols)) {
      stop(paste("replyr::buildJoinPlan table",
                 tnam, "declares a key that is not a column"))
    }
    isKey <- rep(FALSE, length(cols))
    keyIndexes <- match(keys, cols)
    isKey[keyIndexes] <- TRUE
    resultColumn= cols
    resultColumn[keyIndexes] <- names(keys)
    pi <- dplyr::data_frame(tableName= tnam,
                            sourceColumn= cols,
                            sourceClass= classes,
                            resultColumn= resultColumn,
                            isKey= isKey,
                            want= TRUE)
    plans[[i]] <- pi
  }
  plans <- dplyr::bind_rows(plans)
  # disambiguate non-key result columns
  dups <- plans %.>%
    dplyr::filter(., !isKey) %.>%
    dplyr::select(., resultColumn) %.>%
    dplyr::group_by(., resultColumn) %.>%
    dplyr::summarize(., count=n()) %.>%
    dplyr::filter(., count>1)
  if(replyr_nrow(dups)>0) {
    for(ci in dups$resultColumn) {
      indices <- which(plans$resultColumn==ci)
      for(i in indices) {
        ti <- gsub("[^a-zA-Z0-9]+", '_', plans$tableName[[i]])
        rc <- paste(ti, ci, sep= '_')
        plans$resultColumn[[i]] <- rc
      }
    }
  }
  # catch any remaining duplication
  nonKeyIndexes <- which(!plans$isKey)
  plans$resultColumn[nonKeyIndexes] <- make.unique( plans$resultColumn[nonKeyIndexes],
                                                    sep= '_')
  if(check) {
    # just in case
    problem <- inspectDescrAndJoinPlan(tDesc, plans)
    if(!is.null(problem)) {
      stop(paste("replyr::buildJoinPlan produced plan issue:",
                    problem))
    }
  }
  plans
}


charArrayToString <- function(v) {
  vl <- vapply(v,
         function(vi) {
           paste0("'", vi, "'")
         },
         character(1))
  vs <- paste(vl, collapse= ', ')
  paste('c(', vs, ')')
}

strMapToString <- function(m) {
  vl <- vapply(names(m),
               function(ni) {
                 paste0("'", ni, "'='",m[[ni]],"'")
               },
               character(1))
  vs <- paste(vl, collapse= ', ')
  paste('c(', vs, ')')
}


#' Execute an ordered sequence of left joins.
#'
#' Please see \code{vignette('DependencySorting', package = 'replyr')} and \code{vignette('joinController', package= 'replyr')} for more details.
#' @seealso \code{\link{tableDescription}}, \code{\link{buildJoinPlan}}, \code{\link{inspectDescrAndJoinPlan}}, \code{\link{makeJoinDiagramSpec}}
#'
#'
#' @param tDesc description of tables, either a \code{data.frame} from \code{\link{tableDescription}}, or a list mapping from names to handles/frames.  Only used to map table names to data.
#' @param columnJoinPlan columns to join, from \code{\link{buildJoinPlan}} (and likely altered by user).  Note: no column names must intersect with names of the form \code{table_CLEANEDTABNAME_present}.
#' @param ... force later arguments to bind by name.
#' @param checkColumns logical if TRUE confirm column names before starting joins.
#' @param computeFn function to call to try and materialize intermediate results.
#' @param eagerCompute logical if TRUE materialize intermediate results with computeFn.
#' @param checkColClasses logical if true check for exact class name matches
#' @param verbose logical if TRUE print more.
#' @param dryRun logical if TRUE do not perform joins, only print steps.
#' @param tempNameGenerator temp name generator produced by wrapr::mk_tmp_name_source, used to record dplyr::compute() effects.
#' @return joined table
#'
#' @examples
#'
#'
#' # example data
#' meas1 <- data.frame(id= c(1,2),
#'                     weight= c(200, 120),
#'                     height= c(60, 14))
#' meas2 <- data.frame(pid= c(2,3),
#'                     weight= c(105, 110),
#'                     width= 1)
#' # get the initial description of table defs
#' tDesc <- rbind(tableDescription('meas1', meas1),
#'                tableDescription('meas2', meas2))
#' # declare keys (and give them consitent names)
#' tDesc$keys[[1]] <- list(PatientID= 'id')
#' tDesc$keys[[2]] <- list(PatientID= 'pid')
#' # build the column join plan
#' columnJoinPlan <- buildJoinPlan(tDesc)
#' # decide we don't want the width column
#' columnJoinPlan$want[columnJoinPlan$resultColumn=='width'] <- FALSE
#' # double check our plan
#' if(!is.null(inspectDescrAndJoinPlan(tDesc, columnJoinPlan,
#'             checkColClasses= TRUE))) {
#'   stop("bad join plan")
#' }
#' # execute the left joins
#' executeLeftJoinPlan(tDesc, columnJoinPlan,
#'                     checkColClasses= TRUE,
#'                     verbose= TRUE)
#' # also good
#' executeLeftJoinPlan(list('meas1'=meas1, 'meas2'=meas2),
#'                     columnJoinPlan,
#'                     checkColClasses= TRUE,
#'                     verbose= TRUE)
#'
#' @export
#'
#'
executeLeftJoinPlan <- function(tDesc, columnJoinPlan,
                                ...,
                                checkColumns= FALSE,
                                computeFn= function(x, name) {
                                  dplyr::compute(x, name=name)
                                },
                                eagerCompute= TRUE,
                                checkColClasses= FALSE,
                                verbose= FALSE,
                                dryRun= FALSE,
                                tempNameGenerator= mk_tmp_name_source("executeLeftJoinPlan")) {
  # sanity check (if there is an obvious config problem fail before doing potentially expensive work)
  columnJoinPlan <- inspectAndLimitJoinPlan(columnJoinPlan,
                                            checkColClasses=checkColClasses)
  if(is.character(columnJoinPlan)) {
    stop(paste("replyr::executeLeftJoinPlan", columnJoinPlan))
  }
  if(dryRun) {
    verbose = TRUE
  }
  tMap <- NULL
  if('data.frame' %in% class(tDesc)) {
    if(length(unique(tDesc$tableName))!=length(tDesc$tableName)) {
      stop("replyr::executeLeftJoinPlan duplicate table names in tDesc")
    }
    tMap <- tDesc$handle
    names(tMap) <- tDesc$tableName
  } else {
    # named list
    tMap <- tDesc
    if(length(unique(names(tMap)))!=length(names(tMap))) {
      stop("replyr::executeLeftJoinPlan duplicate table names in tDesc")
    }
  }
  if(!all(columnJoinPlan$tableName %in% names(tMap))) {
    stop("replyr::executeLeftJoinPlan some needed columnJoinPlan table(s) not in tDesc")
  }
  # get the names of tables in columnJoinPlan order
  tableNameSeq <- uniqueInOrder(columnJoinPlan$tableName)
  tableIndColNames <- makeTableIndMap(tableNameSeq)
  if(length(intersect(tableIndColNames,
                      c(columnJoinPlan$resultColumn, columnJoinPlan$sourceColumn)))>0) {
    stop("executeLeftJoinPlan: column mappings intersect intended table label columns")
  }
  if(checkColumns && (!dryRun)) {
    for(tabnam in tableNameSeq) {
      handlei <- tMap[[tabnam]]
      newdesc <- tableDescription(tabnam, handlei)
      if(newdesc$isEmpty[[1]]) {
        warning(paste("replyr::executeLeftJoinPlan table is empty:",
                      tabnam))
      }
      tabcols <- newdesc$columns[[1]]
      tableIndCol <- tableIndColNames[[tabnam]]
      if(tableIndCol %in% tabcols) {
        stop(paste("replyr::executeLeftJoinPlan column",
                   tableIndCol, "already in table",
                   tabnam))
      }
      keyRows <- which((columnJoinPlan$tableName==tabnam) &
                         (columnJoinPlan$isKey))
      valRows <- which((columnJoinPlan$tableName==tabnam) &
                         (!columnJoinPlan$isKey) &
                         (columnJoinPlan$want))
      needs <- c(columnJoinPlan$sourceColumn[keyRows],
                columnJoinPlan$sourceColumn[valRows])
      missing <- setdiff(needs, tabcols)
      if(length(missing)>0) {
        stop(paste("replyr::executeLeftJoinPlan table",
                   tabnam, "missing needed columns",
                   paste(missing, collapse = ', ')))
      }
    }
  }
  # start joining
  dataSource <- NULL
  res <- NULL
  first <- TRUE
  for(tabnam in tableNameSeq) {
    if(verbose) {
      print(paste('start',tabnam, base::date()))
    }
    handlei <- NULL
    if(!dryRun) {
      handlei <- tMap[[tabnam]]
      if(is.null(dataSource)) {
        dataSource <- replyr_get_src(handlei)
      }
    }
    keyRows <- which((columnJoinPlan$tableName==tabnam) &
      (columnJoinPlan$isKey))
    valRows <- which((columnJoinPlan$tableName==tabnam) &
                       (columnJoinPlan$want) &
                       (!columnJoinPlan$isKey))
    tableIndCol <- tableIndColNames[[tabnam]]
    if(first) {
      nmap <- c(columnJoinPlan$sourceColumn[keyRows],
                columnJoinPlan$sourceColumn[valRows])
      names(nmap) <- c(columnJoinPlan$resultColumn[keyRows],
                       columnJoinPlan$resultColumn[valRows])
    } else {
      nmap <- c(tableIndCol,
                columnJoinPlan$sourceColumn[keyRows],
                columnJoinPlan$sourceColumn[valRows])
      names(nmap) <- c(tableIndCol,
                       columnJoinPlan$resultColumn[keyRows],
                       columnJoinPlan$resultColumn[valRows])
    }
    # adding an indicator column lets us handle cases where we are taking
    # no values.
    if(verbose) {
      print(paste(" rename/restrict", tabnam))
      #print(paste(" ",strMapToString(nmap)))
      for(ni in names(nmap)) {
        print(paste0("   '",ni,"' = '",nmap[[ni]],"'"))
      }
    }
    ti <- NULL
    if(!is.null(handlei)) {
      ti <- handlei %.>%
        addConstantColumn(., tableIndCol, 1) %.>%
        replyr_mapRestrictCols(., nmap, restrict=TRUE)
      if(eagerCompute) {
        ti <- computeFn(ti, name=tempNameGenerator())
      }
    }
    if(first) {
      res <- ti
      if(verbose) {
        print(paste0(" res <- ", tabnam))
      }
    } else {
      rightKeys <- columnJoinPlan$resultColumn[keyRows]
      if(verbose) {
        print(paste0(" res <- left_join(res, ", tabnam, ","))
        print(paste0("                  by = ",
                     charArrayToString(rightKeys),
                     ")"))
      }
      if(!dryRun) {
        res <- dplyr::left_join(res, ti, by= rightKeys)
        REPLYR_TABLE_PRESENT_COL <- NULL # signal not an unbound variable
        wrapr::let(
          c(REPLYR_TABLE_PRESENT_COL= tableIndCol),
          res <- dplyr::mutate(res, REPLYR_TABLE_PRESENT_COL =
                                 ifelse(is.na(REPLYR_TABLE_PRESENT_COL), 0, 1))
        )
        if(eagerCompute) {
          res <- computeFn(res, name=tempNameGenerator())
        }
      }
    }
    if(verbose) {
      print(paste('done',tabnam, base::date()))
    }
    first <- FALSE
  }
  res
}
