#' (C)omplete (S)chedule Coverage
#'
#' This function calculates complete vaccination coverage for a given birth cohort and geographic level using electronic immunization registry (EIR) data, a vaccination schedule, and population denominators.
#' The function determines which individuals have received all scheduled doses up to a specified age and calculates the proportion of fully vaccinated children by year and geographic subdivision.
#'
#' @param data.EIR A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param data.pop A data frame with population denominators. See \code{pahoabc.pop.ADM0}, \code{pahoabc.pop.ADM1} or \code{pahoabc.pop.ADM2} for structure examples.
#' @param data.schedule A data frame defining the vaccination schedule. See \code{pahoabc.schedule} for expected structure.
#' @param max_age Numeric (optional). The maximum age up to which vaccination completeness is assessed. If \code{NA} (default), all doses in \code{data.schedule} are considered.
#' @param birth_cohorts Numeric (optional). A vector specifying the birth cohort(s) for which coverage should be calculated. If \code{NA} (default), coverage is calculated for all available years.
#' @param geo_level Character (optional). The geographic level to aggregate results by. Must be "ADM1", "ADM2", or \code{NA}. \code{data.pop} must contain the columns to match.
#'
#' @return A data frame containing:
#' \itemize{
#'   \item \code{year}: The birth cohort year.
#'   \item Geographic subdivision columns (if applicable).
#'   \item \code{numerator}: The number of children with a complete vaccination schedule for the given cohort and geographic level.
#'   \item \code{population}: The population denominator for the given cohort and geographic level.
#'   \item \code{coverage}: The calculated vaccination coverage as a percentage, rounded to two decimals.
#' }
#'
#' @import dplyr
#' @import tidyr
#' @import lubridate
#'
#' @export
cs_coverage <- function(data.EIR, data.pop, data.schedule, max_age = NA, birth_cohorts = NA, geo_level = NA) {

  # TODO: Change NA to NULL

  # check geo_level is correctly specified
  if (!(geo_level %in% c("ADM1", "ADM2")) & !is.na(geo_level)) {
    stop("Error: The geo_level parameter should be 'ADM1', 'ADM2', or NA.")
  } else {
    if (!is.data.frame(data.pop)) {
      stop("Error: data.pop should be a data frame.")
    }

    # Check columns in data.pop based on geo_level
    has_ADM1 <- "ADM1" %in% names(data.pop)
    has_ADM2 <- "ADM2" %in% names(data.pop)

    if (is.na(geo_level) & (has_ADM1 | has_ADM2)) {
      stop("Error: data.pop should not contain ADM1 or ADM2 when geo_level is NA. It should only contain population by year and age.")
    } else if (identical(geo_level, "ADM1") & (!has_ADM1 | has_ADM2)) {
      stop("Error: When geo_level is ADM1, data.pop must contain ADM1 but not ADM2.")
    } else if (identical(geo_level, "ADM2") & (!has_ADM1 | !has_ADM2)) {
      stop("Error: When geo_level is ADM2, data.pop must contain both ADM1 and ADM2.")
    }
  }

  # check birth cohort is correctly specified
  if(!is.na(birth_cohorts) & !is.numeric(birth_cohorts)) {
    stop("Error: birth_cohorts should be numeric when specified.")
  }

  # check max age is correctly specified
  if(!is.na(max_age) & !is.numeric(max_age)) {
    stop("Error: max_age should be numeric when specified.")
  }

  # determine vaccines to evaluate according to schedule and max_age
  if(!is.na(max_age)) {
    prepare_schedule <- data.schedule %>%
      filter(age_schedule <= max_age)
  } else {
    prepare_schedule <- data.schedule
  }

  doses_in_schedule <- prepare_schedule %>%
    pull(dose) %>%
    unique()

  # filter for birth cohort and vaccines
  prepare_EIR <- data.EIR %>%
    mutate(year = year(date_birth)) %>%
    filter(dose %in% doses_in_schedule) %>%
    filter(if(!is.na(birth_cohorts)) { year %in% birth_cohorts } else { TRUE })

  # get children with complete schedule
  line_list <- prepare_EIR %>%
    select(-ends_with("occurrence"), -date_vax) %>%
    mutate(vaccinated = TRUE) %>%
    pivot_wider(
      names_from = "dose",
      values_from = "vaccinated",
      values_fn = list(vaccinated = ~ first(.x)),
      values_fill = FALSE
    ) %>%
    mutate(complete_schedule = if_all(c(-ID, -date_birth, -ends_with("residence")), ~ .x))

  # get population for birth cohorts
  denominator <- data.pop %>%
    filter(age == 0) %>%
    select(-age)

  # get years for which we will calculate coverage
  if(is.na(birth_cohorts)) {
    years_in_numerator <- line_list %>% pull(year) %>% unique()
    years_in_denominator <- denominator %>% pull(year) %>% unique()
    years_to_calculate <- intersect(years_in_numerator, years_in_denominator)
  } else {
    years_to_calculate <- birth_cohorts
  }

  # determine grouping column(s)
  if(!is.na(geo_level)) {
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

  return(coverage)

}
