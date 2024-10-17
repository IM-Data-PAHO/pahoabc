#' PAHOABC Aggregated Population Data by ADM1
#'
#' A dataset containing aggregated population information by the first geographic administrative level (ADM1).
#' Each row provides the population of children aged 0 and 1 years for a given year and administrative region.
#'
#' @format A data frame with X rows and 4 variables:
#' \describe{
#'   \item{ADM1}{The name of the first geographic administrative level.}
#'   \item{year}{The year of the population data.}
#'   \item{pop_0}{The population of children aged 0 years.}
#'   \item{pop_1}{The population of children aged 1 year.}
#' }
#' @source pahoabc
"pahoabc.pop.ADM1"
