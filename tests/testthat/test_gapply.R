library('replyr')

context("gapply")

test_that("test_gapply.R", {
  library('dplyr')
  d <- data.frame(
    group = c(1, 1, 2, 2, 2),
    order = c(.1, .2, .3, .4, .5),
    values = c(10, 20, 2, 4, 8)
  )

  # User supplied window functions.  They depend on known column names and
  # the data back-end matching function names (as cumsum).
  cumulative_sum <- . %>% arrange(order) %>% mutate(cv = cumsum(values))
  rank_in_group <- . %>% mutate(constcol = 1) %>%
    mutate(rank = cumsum(constcol)) %>% select(-constcol)

  for (partitionMethod in c('group_by', 'split', 'extract')) {
    #print(partitionMethod)
    #print('cumulative sum example')
    #print(
      d %>% gapply(
        'group',
        cumulative_sum,
        ocolumn = 'order',
        partitionMethod = partitionMethod
     )
    # )
    #print('ranking example')
    #print(
      d %>% gapply(
        'group',
        rank_in_group,
        ocolumn = 'order',
        partitionMethod = partitionMethod
    #  )
    )
    #print('ranking example (decreasing)')
    #print(
      d %>% gapply(
        'group',
        rank_in_group,
        ocolumn = 'order',
        decreasing = TRUE,
        partitionMethod = partitionMethod
      )
   # )
  }

})
