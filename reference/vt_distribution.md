# (V)accination (T)imeliness Distribution

This function calculates the probabilistic version of the vaccination
timeliness analysis: the distribution of vaccinations by number of days
elapsed since the start of the timeliness window (`age_schedule_low`),
for each `dose` and further disaggregating by geographic level, using
data from the electronic immunization registry (EIR). Doses are never
pooled together, since each dose has its own timeliness window. It
returns, for each day, the empirical probability density (`pdf`), i.e.
the percentage of records vaccinated on that day, and the empirical
cumulative distribution (`cdf`), i.e. the percentage of records
vaccinated up to that day.

## Usage

``` r
vt_distribution(
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
  See `immunABC.EIR` for expected structure.

- data.schedule:

  Data frame. A data frame defining the vaccination schedule. See
  `immunABC.schedule` for expected structure.

- geo_level:

  Character. The geographic level to aggregate results by. Must be
  "ADM0", "ADM1" or "ADM2". If not specified, the default is "ADM0".

- vaccines:

  Character (optional). A character vector specifying the doses to
  include in the analysis. If `NULL` (default), all doses in
  `data.schedule` are included.

- birth_cohorts:

  Numeric (optional). A vector specifying the birth cohort(s) for which
  the distribution should be calculated. If `NULL` (default), all
  available cohorts are pooled together. Note that the most recent
  cohorts may not have had time to receive late vaccinations, which
  biases the distribution towards faster vaccination; consider excluding
  cohorts with incomplete follow-up. Specifying cohorts also excludes
  records with no `date_birth`, so `n_missing` may be undercounted.

## Value

A data frame with one row per `dose` (and geographic area, if any) and
day since the start of the timeliness window, with the following
columns:

- `dose`: the dose.

- `day`: days since the start of the timeliness window
  (`age_schedule_low`).

- `age`: age at vaccination in days (`day + age_schedule_low`).

- `n`: number of records vaccinated on that day.

- `pdf`: percentage of records vaccinated on that day.

- `cum_n`: cumulative number of records vaccinated up to that day.

- `cdf`: cumulative percentage of records vaccinated up to that day.

- `n_at_risk`: number of records not yet vaccinated at the start of that
  day (population "at risk").

- `total`: number of vaccinations in the EIR for that `dose` and
  geographic area, excluding `n_early` and `n_missing`.

- `n_early`: number of records vaccinated before the timeliness window,
  excluded from `total`.

- `n_missing`: number of records with a missing date, excluded from
  `total`.

- `window_end`: last timely day
  (`age_schedule_high - age_schedule_low`).

- `age_schedule_low`: age in days for the lower limit of the timeliness
  window for that `dose`, comes from `data.schedule`.

## Details

Day 0 corresponds to `age_schedule_low`, so records vaccinated before
the timeliness window (`n_early`) are excluded from the distribution and
from its denominator (`total`), as are records with a missing date
(`n_missing`). Because of this, the `cdf` at `window_end` is not equal
to the `TIMELY` rate from `vt_rate`, which keeps early records in its
denominator. Also note that, since only vaccinated records are analyzed,
the `cdf` always reaches 100%, which overestimates the probability of
vaccination of the whole target population.
