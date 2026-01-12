# (C)omplete (S)chedule Coverage

This function calculates complete vaccination coverage for a given birth
cohort and geographic level using electronic immunization registry (EIR)
data, a vaccination schedule, and population denominators. The function
determines which individuals have received all scheduled doses up to a
specified age and calculates the proportion of fully vaccinated children
by year and geographic subdivision.

## Usage

``` r
cs_coverage(
  data.EIR,
  data.schedule,
  geo_level,
  birth_cohorts = NULL,
  max_age = NULL,
  data.pop = NULL
)
```

## Arguments

- data.EIR:

  A data frame containing individual vaccination records. See
  `pahoabc.EIR` for expected structure.

- data.schedule:

  A data frame defining the vaccination schedule. See `pahoabc.schedule`
  for expected structure.

- geo_level:

  The geographic level to aggregate results by. Must be "ADM0", "ADM1"
  or "ADM2". If `data.pop` is in use, it must contain the columns to
  match.

- birth_cohorts:

  Numeric (optional). A vector specifying the birth cohort(s) for which
  coverage should be calculated. If `NULL` (default), coverage is
  calculated for all available years.

- max_age:

  Numeric (optional). The maximum age (in days) up to which vaccination
  completeness is assessed. If `NULL` (default), all doses in
  `data.schedule` are considered.

- data.pop:

  Data frame (optional). A data frame with population denominators. See
  `pahoabc.pop.ADMX` for structure examples. If `NULL` (default), the
  denominator is taken from `data.EIR` for each year and `geo_level`.

## Value

A data frame containing the complete schedule coverage by birth cohort
for the specified `geo_level`.
