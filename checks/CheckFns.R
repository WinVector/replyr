

remoteCopy <- function(my_db) {
  force(my_db)
  function(df,name) {
    replyr::replyr_copy_to(dest=my_db,df=df,name=name)
  }
}

runExample <- function(copyToRemote) {
  force(copyToRemote)
  d1 <- copyToRemote(data.frame(x=c(1,2),y=c('a','b')),'d1')
  print(d1)

  cat('\nd1 %>% replyr::replyr_colClasses() \n')
  print(d1 %>% replyr::replyr_colClasses())

  cat('\nd1 %>% replyr::replyr_testCols(is.numeric) \n')
  print(d1 %>% replyr::replyr_testCols(is.numeric))

  cat('\nd1 %>% replyr::replyr_dim() \n')
  print(d1 %>% replyr::replyr_dim())

  cat('\nd1 %>% replyr::replyr_nrow() \n')
  print(d1 %>% replyr::replyr_nrow())

  cat('\nd1 %>% replyr::replyr_str() \n')
  print(d1 %>% replyr::replyr_str())

  # mysql crashes on copyToRemote with NA values in string constants
  # https://github.com/hadley/dplyr/issues/2259
  #  and sparklyr converts them to space anyway.
  d2 <- copyToRemote(data.frame(x=c(1,2,3),y=c(3,5,NA),z=c('a','a','z')),'d2')
  print(d2)

  cat('\nd2 %>% replyr::replyr_quantile("x") \n')
  print(d2 %>% replyr::replyr_quantile("x"))

  cat('\nd2 %>% replyr::replyr_summary() \n')
  print(d2 %>% replyr::replyr_summary())

  d2b <- copyToRemote(data.frame(x=c(1,2,3),y=c(3,5,NA),z=c('a','a','z'),
                                 stringsAsFactors = FALSE),'d2b')
  print(d2b)

  cat('\nd2b %>% replyr::replyr_quantile("x") \n')
  print(d2b %>% replyr::replyr_quantile("x"))

  cat('\nd2b %>% replyr::replyr_summary() \n')
  print(d2b %>% replyr::replyr_summary())

  d3 <- copyToRemote(data.frame(x=c('a','a','b','b','c','c'),
                                y=1:6,
                                stringsAsFactors=FALSE),'d3')
  print(d3)

  ## dplyr::sample_n(d3,3) # not currently implemented for tbl_sqlite
  values <- c('a','c')
  print(values)

  cat('\nd3 %>% replyr::replyr_filter("x",values,verbose=FALSE) \n')
  print(d3 %>% replyr::replyr_filter("x",values,verbose=FALSE))

  cat('\nd3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) \n')
  print(d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE))

  d4 <- copyToRemote(data.frame(x=c(1,2,3,3)),'d4')
  print(d4)

  cat('\nd4 %>% replyr::replyr_uniqueValues("x") \n')
  print(d4 %>% replyr::replyr_uniqueValues("x"))
}
