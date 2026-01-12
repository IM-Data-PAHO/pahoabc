# (No)minal (D)ropout Rate

(No)minal (D)ropout Rate

## Usage

``` r
nod_dropout(
  data.EIR,
  vaccine_init,
  vaccine_end,
  geo_level = "ADM0",
  birth_cohorts = NULL
)
```

## Arguments

- data.EIR:

  A data frame containing individual vaccination records. See
  `pahoabc.EIR` for expected structure.

- vaccine_init:

  Initial vaccine to use in nominal dropout calculation.

- vaccine_end:

  Final vaccine to use in nominal dropout calculation.

- geo_level:

  The geographic level to aggregate results by. Must be "ADM0", "ADM1"
  or "ADM2". If not specified, the default is "ADM0".

- birth_cohorts:

  Birth cohorts to calculate for. As a vector of years.

## Value

A data frame with the calculated coverage for the administrative level
selected. Includes the nominal dropout rate, numerator, denominator and
completeness rate. based on the administrative level, birth cohorts and
vaccines selected.
