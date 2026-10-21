# (V)accination (T)imeliness Inconsistent Records Plot

Generates a lollipop plot showing the distribution of untimely records,
grouping them in bins of days outside of the timeliness window. The
`UNTIMELY_LATE` records and the `UNTIMELY_EARLY` records are shown in
separate rows.

## Usage

``` r
vt_inconsistent_plot(
  data.EIR,
  data.schedule,
  vaccines = NULL,
  birth_cohorts = NULL,
  day_groups = list(c(0, 10), c(10, 20), c(20, 30), c(30, 40), c(40, 50), c(50, 60),
    c(60, 70), c(70, 80), c(80, 90), c(90, 100))
)
```

## Arguments

- data.EIR:

  Data frame. A data frame containing individual vaccination records.
  See `immunABC.EIR` for expected structure.

- data.schedule:

  Data frame. A data frame defining the vaccination schedule. See
  `immunABC.schedule` for expected structure.

- vaccines:

  Character (optional). A character vector specifying the doses to
  include in the analysis. If `NULL` (default), all doses in
  `data.schedule` are included and pooled together.

- birth_cohorts:

  Numeric (optional). A vector specifying the birth cohort(s) to include
  in the plot. If `NULL` (default), all available cohorts are used. Note
  that specifying cohorts excludes records with no `date_birth`, so the
  `DATE_MISSING` category may be undercounted.

- day_groups:

  List of numeric vectors of length 2. Each element is a
  `c(lower, upper)` pair defining each bin's lower and upper limit in
  days. Bins must start at 0 and be contiguous (each bin starts where
  the previous one ends). The last bin is extended to `Inf`, so its
  upper value is ignored (e.g. `c(90, 120)` and `c(90, 100)` both
  produce a "90+" bin). Default is 10-day bins from 0 to 100.

## Value

A ggplot object representing the lollipop plot.
