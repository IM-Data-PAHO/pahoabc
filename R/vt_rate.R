#' (V)accination (T)imeliness Rate
#'
#' This function calculates the vaccination timeliness rate by comparing the age at vaccination (\code{date_vax - date_birth}) with the timeliness window defined in the vaccination schedule (\code{age_schedule_low}, \code{age_schedule_high}), further disaggregating by geographic level, using data from the electronic immunization registry (EIR).
#'
#' @param data.EIR Data frame. A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param data.schedule Data frame. A data frame defining the vaccination schedule. See \code{pahoabc.schedule} for expected structure.
#' @param geo_level Character. The geographic level to aggregate results by. Must be "ADM0", "ADM1" or "ADM2". If not specified, the default is "ADM0".
#' @param vaccines Character (optional). A character vector specifying the doses to include in the analysis, disaggregating results by \code{dose}. If \code{NULL} (default), all doses in \code{data.schedule} are included and pooled together (no \code{dose} column in the output).
#' @param birth_cohorts Numeric (optional). A vector specifying the birth cohort(s) for which the rate should be calculated. If \code{NULL} (default), all available cohorts are used.
#'
#' @return A data frame with one row per \code{timeliness} category for the specified \code{geo_level}. Records are classified as \code{TIMELY} (administered within the timeliness window), \code{UNTIMELY} (administered outside it) or \code{DATE_MISSING} (missing \code{date_birth} or \code{date_vax}). Includes the number of records for each category (\code{n}), a corresponding \code{rate}, and a \code{total}.
#'
#' @import dplyr
#' @import lubridate
#'
#' @export
vt_rate <- function(data.EIR, data.schedule, geo_level = "ADM0", vaccines = NULL, birth_cohorts = NULL) {

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

  # Calculates the vt_rate
  vt_rate <- .vt_classify(data.EIR, data.schedule, vaccines, birth_cohorts) %>%
    # Groups by geo_level and dose (depending on choice of variables)
    group_by(across(all_of(group_cols))) %>%
    # Counts timeliness
    count(timeliness) %>%
    # Totals and rates across groups
    mutate(
      total = sum(n),
      rate  = n / total * 100
    )

  # Returns summary table
  return(vt_rate)
}
