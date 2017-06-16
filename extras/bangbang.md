[`tidyeval`/`rlang`](https://CRAN.R-project.org/package=rlang) generates domains specific languages that, in my opinion, have somewhat involved and irregular laws. Here are some details paraphrased from [`vignette('programming', package = 'dplyr')`](https://cran.r-project.org/web/packages/dplyr/vignettes/programming.html)):

-   "`:=`" is needed to make left-hand-side re-mapping possible (adding yet another "more than one assignment type operator running around" notation issue).
-   "`!!`" substitution requires parenthesis to safely bind (so the notation is actually "`(!! )`, not "`!!`").
-   Left-hand-sides of expressions are names or strings, while right-hand-sides are `quosures`/expressions.

This all can be learned (and some of it is fundamentally needed). However: students try variations of what they are taught, and it is best when that experience is regular and rewarding.

Let's take a look at what one must keep in mind to correctly use the notation in [`R`](https://www.r-project.org).

``` r
suppressPackageStartupMessages(library("dplyr"))
packageVersion("dplyr")
```

    ## [1] '0.7.0'

``` r
d <- data.frame(a=1)
```

[`vignette('programming', package = 'dplyr')`](https://cran.r-project.org/web/packages/dplyr/vignettes/programming.html) includes examples such as:

``` r
my_mutate <- function(df, expr) {
  expr <- enquo(expr)
  mean_name <- paste0("mean_", quo_name(expr))
  sum_name <- paste0("sum_", quo_name(expr))

  mutate(df, 
    !!mean_name := mean(!!expr), 
    !!sum_name := sum(!!expr)
  )
}

my_mutate(d, a)
```

    ##   a mean_a sum_a
    ## 1 1      1     1

So we would expect from working examples we could write a function that adds one to a column as follows:

``` r
tidy_mutate <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- as.character(quo_name(res_var))
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutate(d, res, a)
```

    ## Error in is_quosure(quo): object 'res' not found

(The above filed as [`rlang` issue 181](https://github.com/tidyverse/rlang/issues/181) and [`dplyr` issue 2881](https://github.com/tidyverse/dplyr/issues/2881).)

The following *does* work:

``` r
tidy_mutate1 <- function(df, input_var) {
  input_var <- enquo(input_var)
  res_var <- as.character(quo_name(input_var))
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutate1(d, a)
```

    ##   a
    ## 1 2

That almost looks like some sort of side-effect of the first `enquo()` causing the `quo_name()` to behave differently.

We could try `rlang::sym()`, but I think that is for quoting arguments prior to the function call:

``` r
tidy_mutate3 <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- rlang::sym(res_var)
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutate3(d, res, a)
```

    ## Error in is_symbol(x): object 'res' not found

Or we could try `base::substitute()` to do the quoting (which works):

``` r
tidy_mutate3 <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- deparse(substitute(res_var))
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutate3(d, res, a)
```

    ##   a res
    ## 1 1   2

#### wrapr::let

It is easy to specify the function we want with [`wrapr`](https://CRAN.R-project.org/package=wrapr) as follows (both using standard evaluation, and using non-standard evaluation):

``` r
library("wrapr")

wrapr_mutate_se <- function(df, res_var, input_var) {
  wrapr::let(
    c(RESVAR= res_var,
      INPUTVAR= input_var),
    df %>%
      mutate(RESVAR = INPUTVAR + 1)
  )
}

wrapr_mutate_se(d, 'res', 'a')
```

    ##   a res
    ## 1 1   2

``` r
wrapr_mutate_nse <- function(df, res_var, input_var) {
  wrapr::let(
    c(RESVAR= substitute(res_var),
      INPUTVAR= substitute(input_var)),
    df %>%
      mutate(RESVAR = INPUTVAR + 1)
  )
}

wrapr_mutate_nse(d, res, a)
```

    ##   a res
    ## 1 1   2

### Conclusion

A lot of the `tidyeval`/`rlang` design is centered on treating variable names as lexical closures that capture an environment they should be evaluated in. This does make them more like general `R` functions (which also have this behavior).

Instead of converting non-standard-evaluation functions to standard-evaluation interfaces (as is the `wrapr::let()` strategy) `tidyeval`/`rlang` concentrates on daisy-chaining non-standard-evaluation functions (i.e., writing new non-standard-evaluation functions in terms of others, which is difficult without `tidyeval`/`rlang`).

However, I think that is actually counter to common analyst practice. Analysts actually like standard evaluation and are willing to believe variable names are mere strings.

The `my_mutate(df, expr)` example itself from `vignette('programming', package = 'dplyr')` even shows the pattern: the analyst transiently binds abstract variable names to a chosen data set. One argument is the data and the other is the expression to be applied to that data.

Many calls are written this way (for example `predict()`) and it has the huge advantage that it documents your intent to change out what data is being applied (such as running a procedure twice, once on training data and once on future application data). In fact instead of going to a lot of effort to say variable names are not mere strings, I say go the opposite way: prefer variables names as strings.

This is a principle we use in our [join controller](http://www.win-vector.com/blog/2017/06/use-a-join-controller-to-document-your-work/) which has no issue sharing variables out as an external spreadsheet, because it thinks of variable names as fundamentally being strings (not as `quosures` temporally working "under cover" in string representations).
