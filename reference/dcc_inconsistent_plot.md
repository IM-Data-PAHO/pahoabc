# (D)ate (C)onsistency (C)omparison Inconsistent Records Plot

Generates a histogram of absolute day differences for inconsistent
records, binned into customizable intervals with a final open-ended
category.

## Usage

``` r
dcc_inconsistent_plot(
  data.EIR,
  date_1,
  date_2,
  date_1_name = "date 1",
  date_2_name = "date 2",
  day_groups = list(c(0, 10), c(10, 20), c(20, 30), c(30, 40), c(40, 50), c(50, 60),
    c(60, 70), c(70, 80), c(80, 90), c(90, 100))
)
```

## Arguments

- data.EIR:

  Data frame. A data frame containing individual vaccination records.
  See `pahoabc.EIR` for expected structure.

- date_1:

  Character. The name of a DATE formatted variable present in the EIR.
  This variable is the date we are checking for consistency.

- date_2:

  Character. The name of a DATE formatted variable present in the EIR.
  This variable is the date we are checking consistency against.
  Represents a date chronologically earlier than date_1.

- date_1_name:

  Character. Label for the first date variable, used in the plot
  subtitle. Default is `"date 1"`.

- date_2_name:

  Character. Label for the second date variable, used in the plot
  subtitle. Default is `"date 2"`.

- day_groups:

  List of numeric vectors of length 2. Each element is a
  `c(lower, upper)` pair defining a bin. The last bin is extended to
  `Inf` and labelled `"X+"`. Default is 10-day bins from 0 to 100.

## Value

A ggplot object representing the histogram.
