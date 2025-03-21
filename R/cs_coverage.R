#' (C)omplete (S)chedule Coverage
#'
#' This function calculates complete vaccination coverage for a given birth cohort and geographic level using electronic immunization registry (EIR) data, a vaccination schedule, and population denominators.
#' The function determines which individuals have received all scheduled doses up to a specified age and calculates the proportion of fully vaccinated children by year and geographic subdivision.
#'
#' @param data.EIR A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param data.pop A data frame with population denominators. See \code{pahoabc.pop.ADM0}, \code{pahoabc.pop.ADM1} or \code{pahoabc.pop.ADM2} for structure examples.
#' @param data.schedule A data frame defining the vaccination schedule. See \code{pahoabc.schedule} for expected structure.
#' @param geo_level The geographic level to aggregate results by. Must be "ADM0", "ADM1" or "ADM2". \code{data.pop} must contain the columns to match.
#' @param max_age Numeric (optional). The maximum age up to which vaccination completeness is assessed. If \code{NULL} (default), all doses in \code{data.schedule} are considered.
#' @param birth_cohorts Numeric (optional). A vector specifying the birth cohort(s) for which coverage should be calculated. If \code{NULL} (default), coverage is calculated for all available years.
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
#' @import tidyr
#' @import lubridate
#'
#' @export
cs_coverage <- function(data.EIR, data.pop, data.schedule, geo_level, max_age = NULL, birth_cohorts = NULL) {

  .validate_geo_level(geo_level)
  .validate_data.pop(data.pop, geo_level)
  .validate_birth_cohorts(birth_cohorts)
  .validate_max_age(max_age)

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
    prepare_EIR <- prepare_EIR %>%
      filter(year %in% birth_cohorts)
  }

  # get children with complete schedule
  line_list <- prepare_EIR %>%
    select(-ends_with("occurrence"), -date_vax) %>%
    mutate(vaccinated = TRUE) %>%
    pivot_wider(
      names_from = "dose",
      values_from = "vaccinated",
      values_fn = ~ first(.x),
      values_fill = FALSE
    ) %>%
    mutate(complete_schedule = if_all(c(-ID, -date_birth, -ends_with("residence")), ~ .x))

  # get population for birth cohorts
  denominator <- data.pop %>%
    filter(age == 0) %>%
    select(-age)

  # get years for which we will calculate coverage
  if(is.null(birth_cohorts)) {
    years_in_numerator <- line_list %>% pull(year) %>% unique()
    years_in_denominator <- denominator %>% pull(year) %>% unique()
    years_to_calculate <- intersect(years_in_numerator, years_in_denominator)
  } else {
    years_to_calculate <- birth_cohorts
  }

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

  # get number of children with complete schedule for the defined groups
  numerator <- line_list %>%
    group_by(across(all_of(groups))) %>%
    summarise(numerator = sum(complete_schedule), .groups = "drop")

  # calculate coverage
  coverage <- numerator %>%
    filter(year %in% years_to_calculate) %>%
    left_join(denominator, by = named_groups) %>%
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
