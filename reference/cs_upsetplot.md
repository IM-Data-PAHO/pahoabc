# (C)omplete (S)chedule Coverage Upset Plot

Generates an UpSet plot showing the number of individuals who received
various combinations of vaccine doses defined in a vaccination schedule,
for a given birth cohort. Individuals with a complete schedule are
highlighted.

## Usage

``` r
cs_upsetplot(
  data.EIR,
  data.schedule,
  birth_cohort,
  denominator = NULL,
  min_size = 1,
  set_order = NULL
)
```

## Arguments

- data.EIR:

  A data frame containing individual vaccination records. See
  `pahoabc.EIR` for expected structure.

- data.schedule:

  A data frame defining the vaccination schedule. See `pahoabc.schedule`
  for expected structure.

- birth_cohort:

  Numeric. A single birth year for which to calculate and visualize
  coverage.

- denominator:

  The denominator to use. If `NULL` (default), then the number of unique
  IDs in `data.EIR` is used.

- min_size:

  The minimum number of doses (as a percentage of the `denominator`) a
  group has to have in order to be shown in the plot. Default is 1
  percent.

- set_order:

  A vector containing the desired order of the doses as they will appear
  in the combination matrix. They must match the names in the `dose`
  column of `data.EIR` and `data.schedule`. If `NULL`, uses the default
  ordering scheme of
  [`ComplexUpset::upset()`](https://krassowski.github.io/complex-upset/reference/upset.html).

## Value

A ComplexUpset plot.
