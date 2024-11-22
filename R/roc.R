#' (R)esidence (O)ccurrence (C)overage
#'
#' This function calculates vaccine coverage by both residence and occurrence at a specified geographic level
#' (ADM1 or ADM2) for a given year and set of vaccines.
#'
#' @param data.EIR A data frame containing electronic immunization registry data.
#' @param data.schedule A data frame with the vaccination schedule, including target age for each dose.
#' @param data.pop A data frame with population data by geographic level, year, and age group.
#' @param year_analysis The year for which the coverage calculation is being done.
#' @param vaccines A character vector specifying the doses to include in the analysis.
#' @param geo_level A character string indicating the geographic level: "ADM1" or "ADM2".
#' @return A data frame with calculated coverage by both residence and occurrence, including columns for
#'         year, dose, geographic levels (ADM1 and ADM2 if applicable), doses applied, population, coverage, and coverage type.
#' @examples
#' # Example usage:
#' # coverage <- roc(data.EIR, data.schedule, data.pop, 2023, c("DTP1", "DTP3"), "ADM2")
#' @export
roc <- function(data.EIR, data.schedule, data.pop, year_analysis, vaccines, geo_level) {

  # calculate coverage by residence and by occurrence
  coverage_residence <- calculate_coverage_by("residence", data.EIR, data.schedule, data.pop, year_analysis, vaccines, geo_level)
  coverage_occurrence <- calculate_coverage_by("occurrence", data.EIR, data.schedule, data.pop, year_analysis, vaccines, geo_level)

  # bind the results
  coverage <- bind_rows(coverage_residence, coverage_occurrence)

  return(coverage)
}
