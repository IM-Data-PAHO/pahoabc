# (E)ligibility (C)onsistency (C)omparison Inconsistent Records

This function returns a record-level table of all ineligible and "date
missing" vaccination records, including the number of days outside the
scheduled age window defined in the vaccination schedule
(`age_schedule_low`, `age_schedule_high`).

## Usage

``` r
ecc_inconsistent(data.EIR, data.schedule, vaccines = NULL)
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
  include in the analysis. If `NULL` (default), all doses in
  `data.schedule` are included.

## Value

A data frame containing the ineligible and date-missing records, with
`ID`, `dose`, `date_birth`, `date_vax`, age at vaccination in days, the
scheduled age window (`age_schedule_low`, `age_schedule_high`), and
`days_outside_range`: the number of days outside that window, negative
if vaccinated before `age_schedule_low`, positive if after
`age_schedule_high` (`NA` when a date is missing).
