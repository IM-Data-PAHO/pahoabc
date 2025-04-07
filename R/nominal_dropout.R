#' Nominal dropout rate
#'
#' @param data Nominal data frame
#' @param vac_init Initial vaccine to use in nominal dropout calculation
#' @param vac_end Final vaccine to use in nominal dropout calculation
#' @param geo_level Administrative level to group by for calculation, can be "ADM1" or "ADM2". If no geo_level is specified the default is NA which represents ADM0
#' @param birth_cohort Birth cohort to calculate for.
#'
#' @return A data frame with the calculated coverage for the administrative level used to calculate. Includes the nominal dropout rate, numerator, denominator and adherence rate. based on the administrative level, birth cohort and vaccines selected
#'
#' @import tidyr
#' @import dplyr
#' @import lubridate
#'
#' @export
nominal_dropout <- function(data = pahoabc.EIR, vac_init, vac_end, geo_level = NA , birth_cohort=NA){

  if (!vac_init %in% data$dose){
    stop(paste0("Error: specified vac_init: '", vac_init, "' is not present in the dataset provided."))
  } else if (!vac_end %in% data$dose) {
    stop(paste0("Error: specified vac_end: '", vac_end, "' is not present in the dataset provided."))
  }


  if (!is.na(birth_cohort)) {
    data <- data %>%
      filter(year(date_birth) == birth_cohort)
  }

  if(is.na(geo_level)) {
    data <- data %>%
      select(ID, dose, date_vax)
  }else if (geo_level == "ADM1") {
    data <- data %>%
    select(ID, dose, date_vax, ADM1_residence)
  }else if (geo_level == "ADM2"){
    data <- data %>%
      select(ID, dose, date_vax, ADM1_residence, ADM2_residence)
  }else{
    stop("Error: The geo_level parameter is declared and the value is not ADM1 or ADM2.")
  }


  data <- data %>%
    filter(dose == vac_init | dose == vac_end) %>%
    mutate(dose = ifelse(dose == vac_init, "vac_init", "vac_end"))

  data_unique_rows <- data %>%
    distinct(ID, dose) %>%
    nrow()
  data_rows <- data %>%
    nrow()

  if(data_unique_rows != data_rows) {
    warning("Data contains duplicate rows where ID and dose are duplicated. We recommend you verify for duplicates before running the process to increase accuracy. ")
  }

  data<- data %>%
    mutate(dose = factor(dose, levels = c("vac_init","vac_end"))) %>%
    arrange(dose) %>%
    pivot_wider(names_from = dose, values_from = date_vax, values_fn = {function(x){return(TRUE)}}) %>%
    filter(!is.na(vac_init)) %>%
    mutate(dropout = case_when(
      is.na(vac_end) ~ "dropout",
      TRUE ~ "adherence"
    ))


  if(is.na(geo_level)) {
    dropout_rate_nominal <- data %>%
      group_by(dropout) %>%
      summarise(num = n()) %>%
      mutate(denom = sum(num),
             percent = num / denom * 100)
  }else if (geo_level == "ADM1") {
    dropout_rate_nominal <- data %>%
      group_by(ADM1_residence, dropout) %>%
      summarise(num = n()) %>%
      mutate(denom = sum(num),
             percent = num / denom * 100)
  }else if (geo_level == "ADM2"){
    dropout_rate_nominal <- data %>%
      group_by(ADM1_residence, ADM2_residence, dropout) %>%
      summarise(num = n()) %>%
      mutate(denom = sum(num),
             percent = num / denom * 100)
  }else{
    stop("Error: The geo_level parameter is declared and the value is not ADM1 or ADM2.")
  }

return(dropout_rate_nominal)

}
