#' PAHOABC Vaccination Schedule
#'
#' A dataset containing the vaccination schedule for each vaccine dose. Each row specifies the target population for a given dose.
#'
#' @format A data frame with X rows and 4 variables:
#' \describe{
#'   \item{dose}{The name of the vaccine dose.}
#'   \item{age_schedule}{The age of the target population for that dose (in days).}
#'   \item{age_schedule_low}{The lower limit to consider that dose valid when applied (in days).}
#'   \item{age_schedule_high}{The upper limit to consider that dose valid when applied (in days).}
#' }
#' @source pahoabc
"pahoabc.schedule"
