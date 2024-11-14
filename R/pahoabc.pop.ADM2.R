#' PAHOABC Aggregated Population Data by ADM1 and ADM2
#'
#' A dataset containing aggregated population information by both the first (ADM1) and second (ADM2) geographic administrative levels.
#' Each row provides the population of children aged 0 and 1 years for a given year, administrative region, and subregion.
#'
#' @format A data frame with X rows and 5 variables:
#' \describe{
#'   \item{ADM1}{The name of the first geographic administrative level.}
#'   \item{ADM2}{The name of the second geographic administrative level within each ADM1.}
#'   \item{year}{The year of the population data.}
#'   \item{age}{The age (in years) of the population for that year, ADM1 and ADM2.}
#'   \item{population}{The population for that year, ADM1 and ADM2.}
#' }
#' @source pahoabc
"pahoabc.pop.ADM2"
