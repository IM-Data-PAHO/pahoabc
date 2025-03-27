#' (C)omplete (S)chedule Coverage
#'
#' This function calculates complete vaccination coverage for a given birth cohort and geographic level using electronic immunization registry (EIR) data, a vaccination schedule, and population denominators.
#' The function determines which individuals have received all scheduled doses up to a specified age and calculates the proportion of fully vaccinated children by year and geographic subdivision.
#'
#' @param data.EIR A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param data.schedule A data frame defining the vaccination schedule. See \code{pahoabc.schedule} for expected structure.
#' @param geo_level The geographic level to aggregate results by. Must be "ADM0", "ADM1" or "ADM2". If \code{data.pop} is in use, it must contain the columns to match.
#' @param birth_cohorts Numeric (optional). A vector specifying the birth cohort(s) for which coverage should be calculated. If \code{NULL} (default), coverage is calculated for all available years.
#' @param max_age Numeric (optional). The maximum age up to which vaccination completeness is assessed. If \code{NULL} (default), all doses in \code{data.schedule} are considered.
#' @param data.pop Data frame (optional). A data frame with population denominators. See \code{pahoabc.pop.ADMX} for structure examples. If \code{NULL} (default), the denominator is taken from \code{data.EIR} for each year and \code{geo_level}.
#'
#' @return A data frame containing:
#' \itemize{
#'   \item \code{year}: The birth cohort year.
#'   \item \code{ADM0}: The ADM0 (or country) name.
#'   \item \code{ADM1_residence}: The name of the first administrative level for the given coverage.
#'   \item \code{ADM2_residence}: The name of the second administrative level for the given coverage.
#'   \item \code{numerator}: The number of children with a complete vaccination schedule for the given cohort and geographic level.
#'   \item \code{population}: The population denominator for the given cohort and geographic level.
#'   \item \code{coverage}: The calculated vaccination coverage as a percentage for the given cohort and geographic level.
#' }
#'
#' @import dplyr
#' @import lubridate
#'
#' @export
cs_coverage <- function(data.EIR, data.schedule, geo_level, birth_cohorts = NULL, max_age = NULL, data.pop = NULL) {

  .validate_data.schedule(data.schedule)
  .validate_geo_level(geo_level)
  .validate_data.pop(data.pop, geo_level)
  .validate_numeric(birth_cohorts, "birth_cohorts")
  .validate_numeric(max_age, "max_age", 1)

  # determine grouping column(s)
  if(geo_level != "ADM0") {
    residence_col <- paste0(geo_level, "_residence")

    if(geo_level == "ADM2") {
      # add ADM1 to grouping when ADM2 is selected
      groups <- c("year", "ADM1_residence", residence_col)
      named_groups <- c("year", "ADM1_residence" = "ADM1", setNames(geo_level, residence_col))
    } else {
      groups <- c("year", residence_col)
      named_groups <- c("year", setNames(geo_level, residence_col))
    }
  } else {
    groups <- c("year")
    named_groups <- groups
  }

  # determine vaccines to evaluate according to schedule and max_age
  if(!is.null(max_age)) {
    prepare_schedule <- data.schedule %>%
      filter(age_schedule <= max_age)
  } else {
    prepare_schedule <- data.schedule
  }

  doses_in_schedule <- prepare_schedule %>%
    pull(dose) %>%
    unique()

  # prepare data
  prepare_EIR <- data.EIR %>%
    mutate(year = year(date_birth)) %>%
    filter(dose %in% doses_in_schedule)

  if(!is.null(birth_cohorts)) {
    prepare_EIR <- prepare_EIR %>% filter(year %in% birth_cohorts)
  }

  # get children with complete schedule
  line_list <- prepare_EIR %>%
    mutate(year = year(date_birth)) %>%
    group_by(across(c(ID, all_of(groups)))) %>%
    summarise(
      complete_schedule = all(doses_in_schedule %in% dose),
      .groups = "drop"
    )

  # get population for birth cohorts
  if(is.null(data.pop)) {
    denominator <- line_list %>%
      group_by(across(all_of(groups))) %>%
      summarise(population = n())

  } else {
    denominator <- data.pop %>%
      filter(age == 0) %>%
      select(-age)
  }

  # get number of children with complete schedule for the defined groups
  numerator <- line_list %>%
    group_by(across(all_of(groups))) %>%
    summarise(numerator = sum(complete_schedule), .groups = "drop")

  # calculate coverage
  coverage <- numerator %>%
    left_join(
      denominator,
      # NOTE: This is just to join correctly because data.pop and data.EIR
      #       have different names for the ADMX columns.?
      by = if(is.null(data.pop)) groups else named_groups
    ) %>%
    mutate(coverage = round(numerator / population * 100, 2))

  # standardize columns for output
  standard_columns <- c(
    "year", "ADM0", "ADM1_residence", "ADM2_residence", "numerator",
    "population", "coverage"
  )
  missing_cols <- setdiff(standard_columns, names(coverage)) # find missing
  coverage[missing_cols] <- NA # add missing columns
  coverage <- coverage[standard_columns] # reorder

  return(coverage)

}
