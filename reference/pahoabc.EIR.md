# PAHOABC Electronic Immunization Registry (EIR)

A dataset containing nominal vaccination events from an immunization
information system. Each row represents a vaccination act for a specific
person, along with relevant geographic and demographic information.

## Usage

``` r
pahoabc.EIR
```

## Format

A data frame with X rows and 8 variables:

- ID:

  A unique identifier for each person.

- date_birth:

  The person's birth date.

- date_vax:

  The date of vaccination.

- ADM1_residence:

  The first geographic administrative level of the person's residence.

- ADM2_residence:

  The second geographic administrative level of the person's residence.

- ADM1_occurrence:

  The first geographic administrative level where the vaccination
  occurred.

- ADM2_occurrence:

  The second geographic administrative level where the vaccination
  occurred.

- dose:

  The dose received during the vaccination event.

## Source

pahoabc
