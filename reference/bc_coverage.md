# (B)irth (C)ohort Coverage

This function calculates the coverage by birth cohort, further
disagreggating by geographic level, using data from the electronic
immunization registry (EIR).

## Usage

``` r
bc_coverage(
  data.EIR,
  data.schedule,
  geo_level = "ADM0",
  vaccines = NULL,
  birth_cohorts = NULL,
  data.pop = NULL,
  validate_doses = TRUE
)
```

## Arguments

- data.EIR:

  Data frame. A data frame containing individual vaccination records.
  See `pahoabc.EIR` for expected structure.

- data.schedule:

  Data frame. A data frame defining the vaccination schedule. See
  `pahoabc.schedule` for expected structure.

- geo_level:

  Character. The geographic level to aggregate results by. Must be
  "ADM0", "ADM1" or "ADM2". If not specified, the default is "ADM0".
  Note also that if `data.pop` is in use, it must contain the columns to
  match.

- vaccines:

  Character (optional). A character vector specifying the doses to
  include in the analysis. If `NULL` (default), all vaccines in
  `data.EIR` are included.

- birth_cohorts:

  Numeric (optional). A vector specifying the birth cohort(s) for which
  coverage should be calculated. If `NULL` (default), coverage is
  calculated for all available cohorts.

- data.pop:

  Data frame (optional). A data frame with population denominators. See
  `pahoabc.pop.ADMX` for structure examples. If `NULL` (default), the
  denominator is taken from `data.EIR` for each year and `geo_level`.

- validate_doses:

  Logical (optional). If `TRUE` (default), only count vaccinations that
  occurred within the valid age window defined by `age_schedule_low` and
  `age_schedule_high`. If `FALSE`, does not validate doses before
  counting them.

## Value

A data frame containing the coverage by birth cohort for the specified
`geo_level`.
