#' Calculate Vaccine Coverage by Residence or Occurrence
#'
#' Internal helper function that calculates vaccine coverage by either residence or occurrence
#' at a specified geographic level (ADM1 or ADM2) for a given year and set of vaccines.
#'
#' @param coverage_type A character string specifying the type of analysis: either "residence" or "occurrence".
#' @param data.EIR A data frame containing electronic immunization registry data.
#' @param data.schedule A data frame with the vaccination schedule, including target age for each dose.
#' @param data.pop A data frame with population data by geographic level, year, and age group.
#' @param year_analysis The year for which the coverage calculation is being done.
#' @param vaccines A character vector specifying the doses to include in the analysis.
#' @param geo_level A character string indicating the geographic level: "ADM1" or "ADM2". This must match the geographic level in \code{data.pop}.
#' @return A data frame with calculated coverage for the specified analysis type, year, vaccines, and geographic level.
#' @keywords internal
#' @import dplyr
#' @import lubridate
calculate_coverage_by <- function(coverage_type, data.EIR, data.schedule, data.pop, year_analysis, vaccines, geo_level) {

  .validate_geo_level(geo_level)
  .validate_data.pop(data.pop, geo_level)

  # standardize EIR
  standard_EIR <- data.EIR %>%
    select(ID, starts_with("date"), ends_with(coverage_type), dose) %>%
    rename(
      ADM1 = !!sym(paste0("ADM1_", coverage_type)),
      ADM2 = !!sym(paste0("ADM2_", coverage_type))
    )

  # add the schedule to the EIR
  EIR_with_schedule <- standard_EIR %>%
    left_join(., data.schedule, by = c("dose")) %>%
    rename(age = age_schedule)

  # calculate applied doses
  # first pass through some filters
  applied_doses <- EIR_with_schedule %>%
    # TODO: add filter for those vaccinated only at a valid age (vaccine-dependent)
    # filter for year of analysis
    mutate(year = year(date_vax)) %>%
    filter(year == year_analysis) %>%
    # filter for vaccines of interest
    filter(dose %in% vaccines)

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
