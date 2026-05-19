#' (D)ate (C)onsistency (C)omparison Rate
#' 
#' This function calculates the consistency comparison rate between two date variables, further disagreggating by geographic level, using data from the electronic immunization registry (EIR).
#'
#' @param data.EIR Data frame. A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param date_1 Character. The name of a DATE formatted variable present in the EIR. This variable is the date we are checking for consistency.
#' @param date_2 Character. The name of a DATE formatted variable present in the EIR. This variable is the date we are checking consistency against. Represents a date chronologically earlier than date_1.
#' @param geo_level Character. The geographic level to aggregate results by. Must be "ADM0", "ADM1" or "ADM2". If not specified, the default is "ADM0". 
#' 
#' @return A data frame containing the consistency rate, and inconsistency rate (inverse roportion) in percentages for the specified \code{geo_level}.
#' 
#' @import dplyr
#' @import lubridate
#' @import janitor
#' 
#' @export
dcc_rate <- function(data.EIR, date_1, date_2, geo_level = "ADM0") {

  # validations 
  .validate_data.EIR(data.EIR, indicator = "dcc")
  .validate_geo_level(geo_level)
  .validate_date(data.EIR[[date_1]], date_1)
  .validate_date(data.EIR[[date_2]], date_2)

  #Prepare EIR
  data.EIR = data.EIR %>% 
    rename(ADM1 = ADM1_residence, ADM2 =ADM2_residence)

  # Selects group columns for geo_level
  group_cols <- if (geo_level == "ADM1") {
      "ADM1"
    } else if (geo_level == "ADM2") {
      c("ADM1", "ADM2")
    } else {
      character(0)
    }
  geo_level = "ADM1"
  # Calculates the dcc_rate
  dcc_rate <- data.EIR %>%
    # Detects inconsistencies, also counts missing dates
    mutate(consistency = case_when(.data[[date_2]] >= .data[[date_1]] ~  "INCONSISTENT",
                                  is.na(.data[[date_2]]) | is.na(.data[[date_1]]) ~ "DATE_MISSING",
                                  TRUE ~ "CONSISTENT")) %>%
    # Groups by geo_level depending on choice of variables
    group_by(across(all_of(group_cols))) %>%
    #Counts consistency
    count(consistency) %>%
    # Totals and rates across groups (grouping preserved by count)
    mutate(
      total = sum(n),
      rate  = n / total * 100
    )

  #Returns summary table
  return(dcc_rate)  
}