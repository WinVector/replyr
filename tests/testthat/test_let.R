library('replyr')

context("let")

test_that("test_let.R", {
  library('dplyr')
  d <- data.frame(
    Sepal_Length = c(5.8, 5.7),
    Sepal_Width = c(4.0, 4.4),
    Species = 'setosa',
    rank = c(1, 2)
  )

  mapping = list(RankColumn = 'rank', GroupColumn = 'Species')
  let(alias = mapping,
      expr = {
        # Notice code here can be written in terms of known or concrete
        # names "RankColumn" and "GroupColumn", but executes as if we
        # had written mapping specified columns "rank" and "Species".

        # restart ranks at zero.
        d %>% mutate(RankColumn = RankColumn - 1) -> dres

        # confirm set of groups.
        unique(d$GroupColumn) -> groups
      })
  #print(groups)
  #print(length(groups))
  #print(dres)

  # It is also possible to pipe into let-blocks, but it takes some extra notation
  # (notice the extra ". %>%" at the beginning and the extra "()" at the end).

  d %>% let(alias = mapping,
            expr = {
              . %>% mutate(RankColumn = RankColumn - 1)
            })()

  # Or:

  f <- let(alias = mapping,
           expr = {
             . %>% mutate(RankColumn = RankColumn - 1)
           })
  d %>% f

  # Be wary of using any assignment to attempt side-effects in these "delayed pipelines",
  # as the assignment tends to happen during the let dereference and not (as one would hope)
  # during the later pipeline application.  Example:

  g <- let(alias = mapping,
           expr = {
             . %>% mutate(RankColumn = RankColumn - 1) -> ZZZ
           })
  #print(ZZZ)
  # Notice ZZZ has captured a copy of the sub-pipeline and not waited for application of g.
  # Applying g performs a calculation, but does not overwrite ZZZ.

  g(d)
  #print(ZZZ)
  # Notice ZZZ is not a copy of g(d), but instead still the pipeline fragment.


  # let works by string substitution aligning on word boundaries,
  # so it does (unfortunately) also re-write strings.
  let(list(x = 'y'), 'x')

})
