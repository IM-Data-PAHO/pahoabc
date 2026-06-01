# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `dcc_rate()` — computes CONSISTENT / INCONSISTENT / DATE_MISSING rates between two date variables, disaggregated by geographic level (ADM0/ADM1/ADM2).
- `dcc_barplot()` — stacked bar chart of consistency rates; accepts `date_1_name` and `date_2_name` parameters for subtitle labelling.
- `dcc_inconsistent()` — returns a record-level table of all INCONSISTENT and DATE_MISSING entries with the day difference between the two dates.
- `dcc_inconsistent_plot()` — histogram of absolute day differences for inconsistent records; bins are fully customizable via the `day_groups` parameter (list of `c(lower, upper)` pairs), defaulting to 10-day bins from 0 to 100 with a 100+ catch-all.
- English vignette `date_consistency_comparison_en.Rmd` documenting the full `dcc_` workflow.
