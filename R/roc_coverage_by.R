#' (R)esidence or (Oc)currence Coverage
#'
#' Calculates vaccine coverage by either residence or occurrence at a specified geographic level, for a set of years and vaccines.
#'
#' @param coverage_type A character string specifying the type of analysis: either "residence" or "occurrence".
#' @param data.EIR A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param data.schedule A data frame defining the vaccination schedule. See \code{pahoabc.schedule} for expected structure.
#' @param data.pop A data frame with population denominators. See \code{pahoabc.pop.ADMX} for structure examples.
#' @param geo_level The geographic level to aggregate results by. Must be "ADM0", "ADM1" or "ADM2". \code{data.pop} must contain the columns to match.
#' @param years Numeric (optional). The years for which the coverage calculation is done. If \code{NULL} (default), all vaccination years in \code{data.EIR} are included.
#' @param vaccines Character (optional). A character vector specifying the doses to include in the analysis. If \code{NULL} (default), all vaccines in \code{data.EIR} are included.
#'
#' @return A data frame with calculated coverage for the specified analysis type, year, vaccines, and geographic level.
#'
#' @import dplyr
#' @import lubridate
#'
#' @export
roc_coverage_by <- function(coverage_type, data.EIR, data.schedule, data.pop, geo_level, years = NULL, vaccines = NULL) {

  .validate_coverage_type(coverage_type)
  .validate_data.schedule(data.schedule)
  .validate_geo_level(geo_level)
  .validate_data.pop(data.pop, geo_level)
  .validate_numeric(years, "years")
  .validate_character(vaccines, "vaccines")
  .validate_vaccines(vaccines, data.schedule, "data.schedule")
  .validate_vaccines(vaccines, data.EIR, "data.EIR")

  # prepare EIR
  prepare_EIR <- data.EIR %>%
    select(ID, starts_with("date"), ends_with(coverage_type), dose) %>%
    rename(
      ADM1 = !!sym(paste0("ADM1_", coverage_type)),
      ADM2 = !!sym(paste0("ADM2_", coverage_type))
    ) %>%
    # add vaccination schedule per vaccine
    left_join(., data.schedule, by = c("dose")) %>%
    rename(age = age_schedule)

  # calculate applied doses
  # first pass through some filters
  applied_doses <- prepare_EIR %>%
    # TODO: add filter for those vaccinated only at a valid age (vaccine-dependent)
    # get year for each vaccination event
    mutate(year = year(date_vax))

  # filters if specified by user
  if(!is.null(years)) {
    applied_doses <- applied_doses %>% filter(year %in% years)
  }
  if(!is.null(vaccines)) {
    applied_doses <- applied_doses %>% filter(dose %in% vaccines)
  }

  # determine grouping column(s)
  basic_groups <- c("year", "age")
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

  # sum applied doses for each dose, year and geographic level
  applied_doses <- applied_doses %>%
    group_by(dose, across(all_of(groups))) %>%
    summarise(doses_applied = n(), .groups = "drop")

  # final calculations
  result <- applied_doses %>%
    # add population
    left_join(., data.pop, by = groups) %>%
    # calculate coverage
    mutate(coverage = doses_applied / population * 100) %>%
    # add coverage type column
    mutate(coverage_type = coverage_type)

  # standardize columns for output
  standard_columns <- c(
    "year", "dose", "ADM0", "ADM1", "ADM2", "doses_applied",
    "population", "coverage", "coverage_type"
  )
  missing_cols <- setdiff(standard_columns, names(result)) # find missing
  result[missing_cols] <- NA # add missing columns
  result <- result[standard_columns] # reorder

  return(result)
}
