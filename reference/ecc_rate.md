# (E)ligibility (C)onsistency (C)omparison Rate

This function calculates the rate of eligibility consistency between the
age at vaccination (`date_vax - date_birth`) and the expected age window
defined in the vaccination schedule (`age_schedule_low`,
`age_schedule_high`), further disaggregating by geographic level, using
data from the electronic immunization registry (EIR).

## Usage

``` r
ecc_rate(data.EIR, data.schedule, geo_level = "ADM0", vaccines = NULL)
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

## Value

A data frame containing the eligibility rate (doses administered within
the scheduled age window) and ineligibility rate (inverse proportion,
including missing dates) in percentages for the specified `geo_level`.
