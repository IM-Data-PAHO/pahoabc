# (V)accination (T)imeliness Cumulative Distribution Plot

Generates a plot of the cumulative percentage vaccinated since the start
of the timeliness window.

## Usage

``` r
vt_cdf_plot(
  data,
  percentile = NULL,
  highlight = NULL,
  within_ADM1 = NULL,
  max_days = NULL
)
```

## Arguments

- data:

  The output from the
  [`pahoabc::vt_distribution`](https://im-data-paho.github.io/pahoabc/reference/vt_distribution.md)
  function.

- percentile:

  Numeric (optional). A single percentile (greater than 0 and at
  most 100) to highlight in the plot. This is inserted as a label for
  all highlighted areas and for the combined plot. Default is `NULL`,
  which highlights nothing.

- highlight:

  Character (optional). Up to 5 geographic areas to highlight in color.
  Only available when `data` is disaggregated by "ADM1" or "ADM2".
  Default is `NULL`, which highlights nothing.

- within_ADM1:

  Character (optional). When analyzing data at the "ADM2" level, this
  optional character vector lets you specify one or several "ADM1" to
  filter. Default is `NULL`, which means no filtering by "ADM1".

- max_days:

  Numeric (optional). Maximum number of days to show on the x-axis,
  useful to trim long tails of late vaccinations. Default is `NULL`,
  which shows up to the day at which 95% of records are vaccinated.

## Value

A ggplot object representing the cumulative distribution plot.

## Details

If `data` is disaggregated by geographic area, each area is drawn as a
thin grey line for context, and all areas combined are drawn as a single
highlighted line. Specific areas can be highlighted in color with
`highlight`. If `data` is disaggregated by `dose`, the plot is faceted
by dose and the timeliness window of each dose is shaded. Records
vaccinated before the timeliness window and records with a missing date
are excluded from the distribution and reported in the caption.
