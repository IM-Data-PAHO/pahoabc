#' Calculate Vaccine Coverage by Residence or Occurrence
#'
#' Internal helper function that calculates vaccine coverage by either residence or occurrence
#' at a specified geographic level (ADM1 or ADM2) for a given year and set of vaccines.
#'
#' @param analysis_type A character string specifying the type of analysis: either "residence" or "occurrence".
#' @param data.EIR A data frame containing electronic immunization registry data.
#' @param data.schedule A data frame with the vaccination schedule, including target age for each dose.
#' @param data.pop A data frame with population data by geographic level, year, and age group.
#' @param year_analysis The year for which the coverage calculation is being done.
#' @param vaccines A character vector specifying the doses to include in the analysis.
#' @param geo_level A character string indicating the geographic level: "ADM1" or "ADM2".
#' @return A data frame with calculated coverage for the specified analysis type, year, vaccines, and geographic level.
#' @keywords internal
#' @import dplyr
calculate_coverage_by <- function(analysis_type, data.EIR, data.schedule, data.pop, year_analysis, vaccines, geo_level) {

  # check geo_level is correctly specified
  if(!(geo_level %in% c("ADM1", "ADM2"))) {
    stop("Error: The geo_level parameter should be ADM1 or ADM2.")
  }

  # check if analysis_type is correctly specified
  if(!(analysis_type %in% c("residence", "occurrence"))) {
    stop("Error: The analysis_type parameter should be residence or occurrence.")
  }

  # add the schedule to the EIR
  EIR_with_schedule <- data.EIR %>%
    left_join(., data.schedule, by = c("dose"))

  # calculate applied doses
  # first pass through some filters
  applied_doses <- EIR_with_schedule %>%
    # TODO: add filter for those vaccinated only at a valid age (vaccine-dependent)
    # filter for year of analysis
    mutate(year_vax = year(date_vax)) %>%
    filter(year_vax == year_analysis) %>%
    # filter for vaccines of interest
    filter(dose %in% vaccines)

  # apply grouping depending on geographic level
  ADM1_name <- paste0("ADM1_", analysis_type)
  ADM2_name <- paste0("ADM2_", analysis_type)

  if(geo_level == "ADM1") {
    applied_doses <- applied_doses %>%
      group_by(dose, year_vax, age_schedule, !!sym(ADM1_name))
  } else if(geo_level == "ADM2") {
    applied_doses <- applied_doses %>%
      group_by(dose, year_vax, age_schedule, !!sym(ADM1_name), !!sym(ADM2_name))
  }

  # sum applied doses for each dose, year and geographic level
  applied_doses <- applied_doses %>%
    summarise(doses_applied = n()) %>%
    ungroup()

  # add population depending on geographic level
  if(geo_level == "ADM1") {
    doses_with_pop <- applied_doses %>%
      left_join(
        ., data.pop,
        by = c(
          "year_vax" = "year",
          "age_schedule" = "age",
          setNames("ADM1", ADM1_name)
        )
      )
  } else if(geo_level == "ADM2") {
    doses_with_pop <- applied_doses %>%
      left_join(
        ., data.pop,
        by = c(
          "year_vax" = "year",
          "age_schedule" = "age",
          setNames("ADM1", ADM1_name),
          setNames("ADM2", ADM2_name)
        )
      )
  }

  # calculate coverage
  result <- doses_with_pop %>%
    mutate(coverage = doses_applied / population * 100) %>%
    # add coverage type column
    mutate(coverage_type = analysis_type)

  # select columns of interest depending on geographic level
  # TODO: Improve so that we don't have to use an if-else.
  if(geo_level == "ADM1") {
    result <- result %>%
      select(
        year_vax,
        dose,
        ADM1 = !!sym(ADM1_name),
        doses_applied,
        population,
        coverage,
        coverage_type
      )
  } else if(geo_level == "ADM2") {
    result <- result %>%
      select(
        year_vax,
        dose,
        ADM1 = !!sym(ADM1_name),
        ADM2 = !!sym(ADM2_name),
        doses_applied,
        population,
        coverage,
        coverage_type
      )
  }

  return(result)
}
