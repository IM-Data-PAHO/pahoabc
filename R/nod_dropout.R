#' (No)minal (D)ropout Rate
#'
#' @param data.EIR A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param vaccine_init Initial vaccine to use in nominal dropout calculation.
#' @param vaccine_end Final vaccine to use in nominal dropout calculation.
#' @param geo_level The geographic level to aggregate results by. Must be "ADM0", "ADM1" or "ADM2". If not specified, the default is "ADM0".
#' @param birth_cohorts Birth cohorts to calculate for. As a vector of years.
#'
#' @return A data frame with the calculated coverage for the administrative level selected. Includes the nominal dropout rate, numerator, denominator and completeness rate. based on the administrative level, birth cohorts and vaccines selected.
#'
#' @import tidyr
#' @import dplyr
#' @import lubridate
#'
#' @export
#'
#'
nod_dropout <- function(data.EIR, vaccine_init, vaccine_end, geo_level = "ADM0", birth_cohorts = NULL) {

  .validate_character(vaccine_init, "vaccine_init", exp_len = 1)
  .validate_character(vaccine_end, "vaccine_end", exp_len = 1)
  .validate_geo_level(geo_level)
  .validate_numeric(birth_cohorts, "birth_cohorts", min_len = 1)
  .validate_vaccines(c(vaccine_init, vaccine_end), data.EIR, "data.EIR")
  .validate_date(data.EIR$date_birth, "date_birth")

  # Checks if the birth_cohorts variable is used
  if (!is.null(birth_cohorts)) {
    data.EIR <- data.EIR %>%
      filter(year(date_birth) %in% birth_cohorts)
  }

  # Groups based on the admin level used
  if(geo_level == "ADM0") {
    data.EIR <- data.EIR %>%
      select(ID, dose, date_vax)
  } else if (geo_level == "ADM1") {
    data.EIR <- data.EIR %>%
    select(ID, dose, date_vax, ADM1_residence)
  } else if (geo_level == "ADM2"){
    data.EIR <- data.EIR %>%
      select(ID, dose, date_vax, ADM1_residence, ADM2_residence)
  }

  # Validates for duplicates in data, warning message only
  .validate_duplicates(data.EIR, vaccine_init, vaccine_end)

  data.EIR <- data.EIR %>%
    filter(dose == vaccine_init | dose == vaccine_end) %>%
    mutate(dose = ifelse(dose == vaccine_init, "vaccine_init", "vaccine_end"))

  data.EIR <- data.EIR %>%
    mutate(dose = factor(dose, levels = c("vaccine_init","vaccine_end"))) %>%
    arrange(dose) %>%
    pivot_wider(names_from = dose, values_from = date_vax, values_fn = {function(x){return(TRUE)}}) %>%
    filter(!is.na(vaccine_init)) %>%
    mutate(dropout = case_when(
      is.na(vaccine_end) ~ "dropout",
      TRUE ~ "complete"
    ))


  if(geo_level == "ADM0") {
    dropout_rate_nominal <- data.EIR %>%
      group_by(dropout) %>%
      summarise(num = n()) %>%
      mutate(denom = sum(num),
             percent = num / denom * 100)
  } else if (geo_level == "ADM1") {
    dropout_rate_nominal <- data.EIR %>%
      group_by(ADM1_residence, dropout) %>%
      summarise(num = n()) %>%
      mutate(denom = sum(num),
             percent = num / denom * 100)
  } else if (geo_level == "ADM2"){
    dropout_rate_nominal <- data.EIR %>%
      group_by(ADM1_residence, ADM2_residence, dropout) %>%
      summarise(num = n()) %>%
      mutate(denom = sum(num),
             percent = num / denom * 100)
  }

  dropout_rate_nominal <- dropout_rate_nominal %>%
    rename(indicator = dropout)

  return(dropout_rate_nominal)
}
