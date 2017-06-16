Example
-------

In [`R`](https://www.r-project.org) [`tidyeval`/`rlang`](https://CRAN.R-project.org/package=rlang) generates domains specific languages that, in my opinion, have somewhat involved laws. Here are some details paraphrased from [`vignette('programming', package = 'dplyr')`](https://cran.r-project.org/web/packages/dplyr/vignettes/programming.html)):

-   "`:=`" is needed to make left-hand-side re-mapping possible (adding yet another "more than one assignment type operator running around" notation issue).
-   "`!!`" substitution requires parenthesis to safely bind (so the notation is actually "`(!! )`, not "`!!`").
-   Left-hand-sides of expressions are names or strings, while right-hand-sides are `quosures`/expressions.

This all can be learned (and some of it is fundamentally needed). However: students try variations of what they are taught, and it is best when that experience is regular and rewarding.

Let's take a look at what one must keep in mind to correctly use `tidyeval`/`rlang` notation in [`R`](https://www.r-project.org).

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

So it seems the way to write general expressions (controlling both left-hand and right-hand sides) is the following:

``` r
tidy_mutate <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- quo_name(enquo(res_var))
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutate(d, res, a)
```

    ##   a res
    ## 1 1   2

The above works, but it feels like we are fighting the package when we use a composite function application such as: `quo_name(enquo())` for a fundamental operation (capturing a variable name). Let's try dropping out terms.

### Variations

The following variations are all incorrect:

``` r
tidy_mutate1 <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- quo_name(res_var)
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutate1(d, a)
```

    ## Error in is_quosure(quo): object 'a' not found

``` r
tidy_mutate2 <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- enquo(res_var)
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutate2(d, a)
```

    ## Error: LHS must be a name or string

We could try `quo()`:

``` r
tidy_mutatequo <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- quo(res_var)
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutatequo(d, res, a)
```

    ## Error: LHS must be a name or string

We could try `rlang::sym()` (but I think that is for quoting arguments prior to the function call):

``` r
tidy_mutateq <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- rlang::sym(res_var)
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutateq(d, res, a)
```

    ## Error in is_symbol(x): object 'res' not found

We could try `base::as.name()`:

``` r
tidy_mutatenm <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- as.name(res_var)
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutatenm(d, res, a)
```

    ## Error in as.name(res_var): object 'res' not found

The following works, but isn't short (and actually the `substitute()` is doing all of the work, everything after that is at best a `NOOP`).

``` r
tidy_mutatesym2 <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- deparse(substitute(res_var))
  res_var <- quo(!! rlang::sym(res_var))
  res_var <- res_var[[2]]
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutatesym2(d, res, a)
```

    ##   a res
    ## 1 1   2

Back to the example
-------------------

It looks like `base::substitute()` and `base::quote()` are usable "short forms" for what we are trying to do:

``` r
tidy_mutates <- function(df, res_var, input_var) {
  input_var <- enquo(input_var)
  res_var <- base::quote(res_var)
  mutate(df,
         !!res_var := (!!input_var) + 1)
}

tidy_mutates(d, res, a)
```

    ##   a res_var
    ## 1 1       2

wrapr::let
----------

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

Or, if you are uncomfortable with macros being implemented through string-substitution one can use `wrapr::let()` in "language mode" (where it works directly on abstract syntax trees).

``` r
wrapr_mutate_se <- function(df, res_var, input_var) {
  wrapr::let(
    c(RESVAR= res_var,
      INPUTVAR= input_var),
    df %>%
      mutate(RESVAR = INPUTVAR + 1),
    subsMethod= 'langsubs'
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
      mutate(RESVAR = INPUTVAR + 1),
    subsMethod= 'langsubs'
  )
}

wrapr_mutate_nse(d, res, a)
```

    ##   a res
    ## 1 1   2

Conclusion
----------

`tidyeval`/`rlang` provides general tools to compose or daisy-chain non-standard-evaluation functions (i.e., write new non-standard-evaluation functions in terms of others. This abrogates the issue that it can be hard to compose non-standard function interfaces (i.e., one can not [parameterize them or program over them](https://www.youtube.com/watch?v=iKLGxzzm9Hk) without a tool such as `tidyeval`/`rlang`). `wrapr::let()` concentrates on standard evaluation, providing a tool that allows one to re-wrap non-standard-evaluation interfaces as standard evaluation interfaces.

I think the `tidyeval`/`rlang` philosophy is a "tools to application view" and `wrapr::let()` is a "use-case to tool view." These are differing views, so each will artificially look "silly" if judged in terms of the other.

A lot of the `tidyeval`/`rlang` design is centered on treating variable names as lexical closures that capture an environment they should be evaluated in. This does make them more like general `R` functions (which also have this behavior).

However, creating so many long-term bindings is a actually counter to some common data analyst practice.

The `my_mutate(df, expr)` example itself from `vignette('programming', package = 'dplyr')` even shows the pattern I am referring to: the analyst transiently pairs abstract variable names to a chosen concrete data set. One argument is the data and the other is the expression to be applied to that data (and only that data, with clean code not capturing values from environments).

Many calls are written this way (for example `predict()`) and it has the huge advantage that it documents your intent to change out what data is being applied (such as running a procedure twice, once on training data and once on future application data).

This is a principle we also strongly apply in our [join controller](http://www.win-vector.com/blog/2017/06/use-a-join-controller-to-document-your-work/) which has no issue sharing variables out as an external spreadsheet, because it thinks of variable names as fundamentally being strings (not as `quosures` temporally working "under cover" in string representations).
