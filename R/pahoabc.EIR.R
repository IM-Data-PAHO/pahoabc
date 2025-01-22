#' PAHOABC Electronic Immunization Registry (EIR)
#'
#' A dataset containing nominal vaccination events from an immunization information system.
#' Each row represents a vaccination act for a specific person, along with relevant geographic and demographic information.
#'
#' @format A data frame with X rows and 8 variables:
#' \describe{
#'   \item{ID}{A unique identifier for each person.}
#'   \item{date_birth}{The person's birth date.}
#'   \item{date_vax}{The date of vaccination.}
#'   \item{ADM1_residence}{The first geographic administrative level of the person's residence.}
#'   \item{ADM2_residence}{The second geographic administrative level of the person's residence.}
#'   \item{ADM1_occurrence}{The first geographic administrative level where the vaccination occurred.}
#'   \item{ADM2_occurrence}{The second geographic administrative level where the vaccination occurred.}
#'   \item{dose}{The dose received during the vaccination event.}
#' }
#' @source pahoabc
"pahoabc.EIR"
