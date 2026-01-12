# (R)esidence or (Oc)currence Coverage

Calculates vaccine coverage by either residence or occurrence at a
specified geographic level, for a set of years and vaccines.

## Usage

``` r
roc_coverage_by(
  coverage_type,
  data.EIR,
  data.schedule,
  data.pop,
  geo_level,
  years = NULL,
  vaccines = NULL
)
```

## Arguments

- coverage_type:

  A character string specifying the type of analysis: either "residence"
  or "occurrence".

- data.EIR:

  A data frame containing individual vaccination records. See
  `pahoabc.EIR` for expected structure.

- data.schedule:

  A data frame defining the vaccination schedule. See `pahoabc.schedule`
  for expected structure.

- data.pop:

  A data frame with population denominators. See `pahoabc.pop.ADMX` for
  structure examples.

- geo_level:

  The geographic level to aggregate results by. Must be "ADM0", "ADM1"
  or "ADM2". `data.pop` must contain the columns to match.

- years:

  Numeric (optional). The years for which the coverage calculation is
  done. If `NULL` (default), all vaccination years in `data.EIR` are
  included.

- vaccines:

  Character (optional). A character vector specifying the doses to
  include in the analysis. If `NULL` (default), all vaccines in
  `data.EIR` are included.

## Value

A data frame with calculated coverage for the specified analysis type,
year, vaccines, and geographic level.
