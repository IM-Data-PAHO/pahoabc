# (D)ate (C)onsistency (C)omparison Rate

This function calculates the rate of consistency between two date
variables, further disaggregating by geographic level, using data from
the electronic immunization registry (EIR).

## Usage

``` r
dcc_rate(data.EIR, date_1, date_2, geo_level = "ADM0")
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

- geo_level:

  Character. The geographic level to aggregate results by. Must be
  "ADM0", "ADM1" or "ADM2". If not specified, the default is "ADM0".

## Value

A data frame containing the consistency rate and inconsistency rate
(inverse proportion) in percentages for the specified `geo_level`.
