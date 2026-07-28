# (E)ligibility (C)onsistency (C)omparison Barplot

Generates a bar plot of eligibility rates (doses administered within vs
outside the scheduled age window), grouped by geographic area and
colored by eligibility result. If `data` is disaggregated by `dose`
(i.e. `ecc_rate` was run with `vaccines` specified), the plot is faceted
by dose.

## Usage

``` r
ecc_barplot(data, within_ADM1 = NULL, plot_missing = TRUE)
```

## Arguments

- data:

  The output from the
  [`pahoabc::ecc_rate`](https://im-data-paho.github.io/pahoabc/reference/ecc_rate.md)
  function.

- within_ADM1:

  Character (optional). When analyzing data at the "ADM2" level, this
  optional character vector lets you specify one or several "ADM1" to
  filter. Default is `NULL`, which means no filtering by "ADM1".

- plot_missing:

  Boolean (default TRUE). Plots DATE_MISSING records as its own
  category. Defaults to TRUE so all bars add to 100.

## Value

A ggplot object representing the bar plot.
