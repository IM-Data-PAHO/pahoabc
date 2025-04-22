#' Nominal dropout rate
#'
#' @param data.EIR Nominal data dataframe.
#' @param vaccine_init Initial vaccine to use in nominal dropout calculation.
#' @param vaccine_end Final vaccine to use in nominal dropout calculation.
#' @param geo_level Administrative level to group by for calculation, can be "ADM0","ADM1" or "ADM2". If no geo_level is specified the default is "ADM0".

#' @param birth_cohorts Birth cohorts to calculate for. As a vector of years
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


nod_dropout <- function(data.EIR, vaccine_init, vaccine_end, geo_level = "ADM0", birth_cohorts=NULL){

  ##TODO apply all validations of used variables
  .validate_character(vaccine_init, "vaccine_init", min_len = 1)
  .validate_character(vaccine_end, "vaccine_end", min_len = 1)
  .validate_geo_level(geo_level)
  .validate_numeric(birth_cohorts, "birth_cohorts", min_len = 1)
  .validate_nod_vaccines(data.EIR, vaccine_init, vaccine_end)
  .validate_date(data.EIR$date_birth, "date_birth")


  # Checks if the birth_cohorts variable is used
  if (!is.null(birth_cohorts)) {
    data.EIR <- data.EIR %>%
      filter(year(date_birth) %in% birth_cohorts)
  }

  # Groups based on the admin level used
  # TODO change geolevel to have ADM0, instead of NA as baseline
  if(geo_level == "ADM0") {
    data.EIR <- data.EIR %>%
      select(ID, dose, date_vax)
  }else if (geo_level == "ADM1") {
    data.EIR <- data.EIR %>%
    select(ID, dose, date_vax, ADM1_residence)
  }else if (geo_level == "ADM2"){
    data.EIR <- data.EIR %>%
      select(ID, dose, date_vax, ADM1_residence, ADM2_residence)
  }else{
    stop("Error: The geo_level parameter is declared and the value is not ADM0, ADM1 or ADM2.")
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
  }else if (geo_level == "ADM1") {
    dropout_rate_nominal <- data.EIR %>%
      group_by(ADM1_residence, dropout) %>%
      summarise(num = n()) %>%
      mutate(denom = sum(num),
             percent = num / denom * 100)
  }else if (geo_level == "ADM2"){
    dropout_rate_nominal <- data.EIR %>%
      group_by(ADM1_residence, ADM2_residence, dropout) %>%
      summarise(num = n()) %>%
      mutate(denom = sum(num),
             percent = num / denom * 100)
  }else{
    stop("Error: The geo_level parameter is declared and the value is not ADM0, ADM1 or ADM2.")
  }

dropout_rate_nominal <- dropout_rate_nominal %>%
  rename(indicator=dropout)

return(dropout_rate_nominal)

}
