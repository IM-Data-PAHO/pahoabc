# (V)accination (T)imeliness Rate

This function calculates the vaccination timeliness rate by comparing
the age at vaccination (`date_vax - date_birth`) with the timeliness
window defined in the vaccination schedule (`age_schedule_low`,
`age_schedule_high`), further disaggregating by geographic level, using
data from the electronic immunization registry (EIR).

## Usage

``` r
vt_rate(
  data.EIR,
  data.schedule,
  geo_level = "ADM0",
  vaccines = NULL,
  birth_cohorts = NULL
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

- vaccines:

  Character (optional). A character vector specifying the doses to
  include in the analysis, disaggregating results by `dose`. If `NULL`
  (default), all doses in `data.schedule` are included and pooled
  together (no `dose` column in the output).

- birth_cohorts:

  Numeric (optional). A vector specifying the birth cohort(s) for which
  the rate should be calculated. If `NULL` (default), all available
  cohorts are used. Note that specifying cohorts excludes records with
  no `date_birth`, so the `DATE_MISSING` category may be undercounted.

## Value

A data frame with one row per `timeliness` category for the specified
`geo_level` (and `dose`, if `vaccines` is specified), with the following
columns:

- `timeliness`: the category of each record, one of:

  - `TIMELY`: administered within the timeliness window.

  - `UNTIMELY_EARLY`: administered before the timeliness window, i.e.
    before `age_schedule_low`.

  - `UNTIMELY_LATE`: administered after the timeliness window, i.e.
    after `age_schedule_high`.

  - `DATE_MISSING`: missing `date_birth` or `date_vax`.

- `n`: number of records in that category.

- `total`: total number of records.

- `rate`: percentage of records in that category (`n / total * 100`).
