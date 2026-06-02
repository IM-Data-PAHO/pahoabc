# (D)ate (C)onsistency (C)omparison Inconsistent Records

This function returns a record-level table of all inconsistent and "date
missing" entries, including the day difference between the two dates.

## Usage

``` r
dcc_inconsistent(data.EIR, date_1, date_2)
```

## Arguments

- data.EIR:

  Data frame. A data frame containing individual vaccination records.
  See `pahoabc.EIR` for expected structure.

- date_1:

  Character. The name of a DATE formatted variable present in the EIR.
  This variable is the date we are checking for consistency.

- date_2:

  Character. The name of a DATE formatted variable present in the EIR.
  This variable is the date we are checking consistency against.
  Represents a date chronologically earlier than date_1.

## Value

A data frame containing the inconsistent records in the database and the
time diferential between them.
