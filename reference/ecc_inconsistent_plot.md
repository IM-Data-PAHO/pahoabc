# (E)ligibility (C)onsistency (C)omparison Inconsistent Records Plot

Generates a diverging lollipop plot of ineligible records by the
magnitude of days outside the scheduled age window, binned into
customizable intervals with a final open-ended category. The same
magnitude bins are shared by both directions on the x axis: records
vaccinated too early (before `age_schedule_low`) are plotted below zero,
and records vaccinated too late (after `age_schedule_high`) are plotted
above zero.

## Usage

``` r
ecc_inconsistent_plot(
  data.EIR,
  data.schedule,
  vaccines = NULL,
  day_groups = list(c(0, 10), c(10, 20), c(20, 30), c(30, 40), c(40, 50), c(50, 60),
    c(60, 70), c(70, 80), c(80, 90), c(90, 100))
)
```

## Arguments

- data.EIR:

  Data frame. A data frame containing individual vaccination records.
  See `pahoabc.EIR` for expected structure.

- data.schedule:

  Data frame. A data frame defining the vaccination schedule. See
  `pahoabc.schedule` for expected structure.

- vaccines:

  Character (optional). A character vector specifying the doses to
  include in the analysis, faceting the plot by `dose` when more than
  one is given. If `NULL` (default), all doses in `data.schedule` are
  included and pooled together (no facet).

- day_groups:

  List of numeric vectors of length 2. Each element is a
  `c(lower, upper)` pair defining a magnitude bin, shared by both the
  "before" and "after" direction. The last bin is extended to `Inf`.
  Default is 10-day bins from 0 to 100.

## Value

A ggplot object representing the diverging lollipop plot.
