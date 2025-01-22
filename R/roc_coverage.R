#' (R)esidence (Oc)currence Coverage
#'
#' This function calculates vaccine coverage by both residence and occurrence at a specified geographic level
#' (ADM1 or ADM2) for a given year and set of vaccines.
#'
#' @param data.EIR A data frame containing electronic immunization registry data.
#' @param data.schedule A data frame with the vaccination schedule, including target age for each dose.
#' @param data.pop A data frame with population data by geographic level, year, and age group.
#' @param year_analysis An integer specifying the year for which the coverage calculation is being done.
#' @param vaccines A character vector specifying the doses to include in the analysis.
#' @param geo_level A character string indicating the geographic level. Must be either "ADM1" or "ADM2". This must match the geographic level in \code{data.pop}.
#'
#' @return A data frame with calculated coverage by both residence and occurrence.
#'
#' @import dplyr
#'
#' @export
roc_coverage <- function(data.EIR, data.schedule, data.pop, year_analysis, vaccines, geo_level) {

  # calculate coverage by residence and by occurrence
  coverage_residence <- calculate_coverage_by("residence", data.EIR, data.schedule, data.pop, year_analysis, vaccines, geo_level)
  coverage_occurrence <- calculate_coverage_by("occurrence", data.EIR, data.schedule, data.pop, year_analysis, vaccines, geo_level)

  # bind the results
  coverage <- bind_rows(coverage_residence, coverage_occurrence)

  return(coverage)
}
