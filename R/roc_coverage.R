#' (R)esidence (Oc)currence Coverage
#'
#' This function calculates vaccine coverage by both residence and occurrence at a specified geographic level, for a set of years and vaccines.
#'
#' @param data.EIR A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param data.schedule A data frame defining the vaccination schedule. See \code{pahoabc.schedule} for expected structure.
#' @param data.pop A data frame with population denominators. See \code{pahoabc.pop.ADMX} for structure examples.
#' @param geo_level The geographic level to aggregate results by. Must be "ADM0", "ADM1" or "ADM2". \code{data.pop} must contain the columns to match.
#' @param years Numeric (optional). The years for which the coverage calculation is done. If \code{NULL} (default), all vaccination years in \code{data.EIR} are included.
#' @param vaccines Character (optional). A character vector specifying the doses to include in the analysis. If \code{NULL} (default), all vaccines in \code{data.EIR} are included.
#'
#' @return A data frame with calculated coverage by both residence and occurrence.
#'
#' @import dplyr
#'
#' @export
roc_coverage <- function(data.EIR, data.schedule, data.pop, geo_level, years = NULL, vaccines = NULL) {

  # calculate coverage by residence and by occurrence
  coverage_residence <- roc_coverage_by("residence", data.EIR, data.schedule, data.pop, geo_level, years, vaccines)
  coverage_occurrence <- roc_coverage_by("occurrence", data.EIR, data.schedule, data.pop, geo_level, years, vaccines)

  # bind the results
  coverage <- bind_rows(coverage_residence, coverage_occurrence)

  return(coverage)
}
