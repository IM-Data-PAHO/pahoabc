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
#' @return A data frame containing the complete schedule coverage by birth cohort for the specified \code{geo_level}.
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
  basic_groups <- c("year")
  if(geo_level != "ADM0") {
    # groups for ADM1
    groups <- c(basic_groups, "ADM1")

    # groups for ADM2
    if(geo_level == "ADM2") {
      groups <- c(groups, geo_level)
    }
  } else {
    groups <- basic_groups
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
    select(
      ID,
      starts_with("date"),
      ADM1 = ADM1_residence,
      ADM2 = ADM2_residence,
      dose
    ) %>%
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
    left_join(denominator, by = groups) %>%
    mutate(coverage = round(numerator / population * 100, 2))

  return(coverage)

}
