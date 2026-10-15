#' (V)accination (T)imeliness Distribution
#'
#' This function calculates the probabilistic version of the vaccination timeliness analysis: the distribution of vaccinations by number of days elapsed since the start of the timeliness window (\code{age_schedule_low}), further disaggregating by geographic level, using data from the electronic immunization registry (EIR). It returns, for each day, the empirical probability density (\code{pdf}), i.e. the percentage of records vaccinated on that day, and the empirical cumulative distribution (\code{cdf}), i.e. the percentage of records vaccinated up to that day.
#'
#' Day 0 corresponds to \code{age_schedule_low}, so records vaccinated before the timeliness window (\code{n_early}) are excluded from the distribution and from its denominator (\code{total}), as are records with a missing date (\code{n_missing}). Because of this, the \code{cdf} at \code{window_end} is not equal to the \code{TIMELY} rate from \code{vt_rate}, which keeps early records in its denominator. Also note that, since only vaccinated records are analyzed, the \code{cdf} always reaches 100\%, which overestimates the probability of vaccination of the whole target population.
#'
#' @param data.EIR Data frame. A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param data.schedule Data frame. A data frame defining the vaccination schedule. See \code{pahoabc.schedule} for expected structure.
#' @param geo_level Character. The geographic level to aggregate results by. Must be "ADM0", "ADM1" or "ADM2". If not specified, the default is "ADM0".
#' @param vaccines Character (optional). A character vector specifying the doses to include in the analysis, disaggregating results by \code{dose}. If \code{NULL} (default), all doses in \code{data.schedule} are included and pooled together.
#' @param birth_cohorts Numeric (optional). A vector specifying the birth cohort(s) for which the distribution should be calculated. If \code{NULL} (default), all available cohorts are pooled together. Note that the most recent cohorts may not have had time to receive late vaccinations, which biases the distribution towards faster vaccination; consider excluding cohorts with incomplete follow-up. Specifying cohorts also excludes records with no \code{date_birth}, so \code{n_missing} may be undercounted.
#'
#' @return A data frame with one row per day since the start of the timeliness window, with the following columns:
#' \itemize{
#'   \item \code{day}: days since the start of the timeliness window (\code{age_schedule_low}).
#'   \item \code{n}: number of records vaccinated on that day.
#'   \item \code{pdf}: percentage of records vaccinated on that day.
#'   \item \code{cum_n}: cumulative number of records vaccinated up to that day.
#'   \item \code{cdf}: cumulative percentage of records vaccinated up to that day.
#'   \item \code{n_at_risk}: number of records not yet vaccinated at the start of that day (population "at risk").
#'   \item \code{total}: number of vaccinations in the EIR for that \code{dose} and/or geographic area, excluding \code{n_early} and \code{n_missing}.
#'   \item \code{n_early}: number of records vaccinated before the timeliness window, excluded from \code{total}.
#'   \item \code{n_missing}: number of records with a missing date, excluded from \code{total}.
#'   \item \code{window_end}: last timely day (\code{age_schedule_high - age_schedule_low}); \code{NA} when doses are pooled.
#' }
#'
#' @import dplyr
#' @import lubridate
#'
#' @export
vt_distribution <- function(data.EIR, data.schedule, geo_level = "ADM0", vaccines = NULL, birth_cohorts = NULL) {

  # validations
  .validate_geo_level(geo_level)
  .validate_data.schedule(data.schedule)
  .validate_data.EIR(data.EIR, data.schedule)
  .validate_date(data.EIR$date_birth, "date_birth")
  .validate_date(data.EIR$date_vax, "date_vax")
  .validate_vaccines(vaccines, data.EIR, "data.EIR")
  .validate_vaccines(vaccines, data.schedule, "data.schedule")
  .validate_numeric(birth_cohorts, "birth_cohorts", min_len = 1)

  # Prepare EIR
  data.EIR <- data.EIR %>%
    rename(ADM1 = ADM1_residence, ADM2 = ADM2_residence)

  # Selects group columns: by dose only when vaccines is specified, plus geo_level
  dose_group <- if(!is.null(vaccines)) "dose" else character(0)
  group_cols <- if (geo_level == "ADM1") {
      c(dose_group, "ADM1")
    } else if (geo_level == "ADM2") {
      c(dose_group, "ADM1", "ADM2")
    } else {
      dose_group
    }

  # Calculates the distribution
  vt_distribution <- .vt_classify(data.EIR, data.schedule, vaccines, birth_cohorts) %>%
    # Days since the start of the timeliness window (day 0 = age_schedule_low)
    mutate(day = age_at_vax - age_schedule_low) %>%
    group_by(across(all_of(group_cols))) %>%
    # Counts records excluded from the analysis: missing dates and vaccinated before the window
    mutate(
      n_missing = sum(timeliness == "DATE_MISSING"),
      n_early = sum(timeliness != "DATE_MISSING" & day < 0)
    ) %>%
    filter(timeliness != "DATE_MISSING", day >= 0) %>%
    ungroup() %>%
    # Counts records vaccinated on each day
    count(across(all_of(group_cols)), day, n_missing, n_early) %>%
    group_by(across(all_of(group_cols))) %>%
    # Daily (pdf) and cumulative (cdf) percentages
    .vt_compute_distribution() %>%
    ungroup()

  # Adds the last timely day of each dose (only when disaggregating by dose)
  if(!is.null(vaccines)) {
    windows <- data.schedule %>%
      mutate(window_end = age_schedule_high - age_schedule_low) %>%
      select(dose, window_end)
    vt_distribution <- vt_distribution %>%
      left_join(windows, by = "dose")
  } else {
    vt_distribution <- vt_distribution %>%
      mutate(window_end = NA_real_)
  }

  # Final preparations
  vt_distribution <- vt_distribution %>%
    select(
      all_of(group_cols), day, n, pdf, cum_n, cdf, n_at_risk,
      total, n_early, n_missing, window_end
    ) %>%
    # guarantees output is sorted by group and day
    arrange(across(all_of(c(group_cols, "day"))))

  return(vt_distribution)
}
