# PAHOABC Vaccination Schedule

A dataset containing the vaccination schedule for each vaccine dose.
Each row specifies the target population for a given dose.

## Usage

``` r
pahoabc.schedule
```

## Format

A data frame with X rows and 4 variables:

- dose:

  The name of the vaccine dose.

- age_schedule:

  The age of the target population for that dose (in days).

- age_schedule_low:

  The lower limit to consider that dose valid when applied (in days).

- age_schedule_high:

  The upper limit to consider that dose valid when applied (in days).

## Source

pahoabc
