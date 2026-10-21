# (V)accination (T)imeliness Inconsistent Records

This function returns a record-level table of all untimely (early or
late) and "date missing" vaccination records, including the number of
days outside the timeliness window defined in the vaccination schedule.

## Usage

``` r
vt_inconsistent(data.EIR, data.schedule, vaccines = NULL, birth_cohorts = NULL)
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
  `data.schedule` are included.

- birth_cohorts:

  Numeric (optional). A vector specifying the birth cohort(s) for which
  inconsistent records should be returned. If `NULL` (default), all
  available cohorts are used. Note that specifying cohorts excludes
  records with no `date_birth`, so the `DATE_MISSING` category may be
  undercounted.

## Value

A data frame containing the untimely and date-missing records, with the
following columns:

- `ID`: unique person identification number.

- `dose`: the dose.

- `date_birth`: date of birth.

- `date_vax`: date of vaccination.

- `age_at_vax`: age at vaccination in days.

- `age_schedule_low`, `age_schedule_high`: the timeliness window, from
  `data.schedule`.

- `days_outside_range`: the number of days outside of the timeliness
  window, negative if vaccinated before `age_schedule_low` and `NA` when
  a date is missing.

- `timeliness`: `UNTIMELY_EARLY` (before `age_schedule_low`),
  `UNTIMELY_LATE` (after `age_schedule_high`) or `DATE_MISSING`.
