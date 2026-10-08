#' Detect the smallest admin level in a data frame.
#'
#' @keywords internal
#' @noRd
.detect_geo_level <- function(data) {

  columns_in_data <- names(data)
  ADM_detected <- 0

  # remove _residence or _ocurrence suffixes
  columns_in_data <- str_remove(columns_in_data, "_residence")
  columns_in_data <- str_remove(columns_in_data, "_ocurrence")

  if(any(c("ADM1", "ADM2") %in% columns_in_data)) {
    if("ADM2" %in% columns_in_data) {
      ADM_detected <- 2
      message("ADM2 detected.")
    } else {
      ADM_detected <- 1
      message("ADM1 detected.")
    }
  } else{
    ADM_detected <- 0
    message("ADM0 detected.")
  }

  return(ADM_detected)

}

#' Correct residence per ID to the residence of the most recent vaccination record.
#'
#' @import dplyr
#'
#' @keywords internal
#' @noRd
.fix_residence <- function(data.EIR) {

  residence_cols <- intersect(c("ADM1_residence", "ADM2_residence"), names(data.EIR))
  latest_cols <- paste0(residence_cols, "_latest")

  latest_residence <- data.EIR %>%
    group_by(ID) %>%
    slice_max(date_vax, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    select(all_of(c("ID", residence_cols))) %>%
    rename_with(~ latest_cols, all_of(residence_cols))

  data.EIR <- data.EIR %>%
    left_join(latest_residence, by = "ID")

  changed <- rep(FALSE, nrow(data.EIR))
  for(i in seq_along(residence_cols)) {
    changed <- changed | (data.EIR[[residence_cols[i]]] != data.EIR[[latest_cols[i]]])
    data.EIR[[residence_cols[i]]] <- data.EIR[[latest_cols[i]]]
  }

  n_modified <- sum(changed)
  message(paste0(n_modified, " record(s) had residence updated to the most recent vaccination residence."))

  data.EIR <- data.EIR %>%
    select(-all_of(latest_cols))

  return(data.EIR)
}

#' Convert the vaccination schedule from days to years. Automatically rounds down to lowest whole year.
#'
#' @keywords internal
#' @noRd
.schedule_to_years <- function(data.schedule) {

  # convert age column from days to years
  converted <- data.schedule %>% mutate(age_schedule = floor(age_schedule / 365))

  return(converted)
}

#' Classify each EIR record as TIMELY, UNTIMELY or DATE_MISSING according to the timeliness window in data.schedule, and compute its days_outside_range.
#'
#' NOTE: Does not validate its inputs (it only warns about negative ages at vaccination). Callers must validate data.EIR, data.schedule, vaccines and birth_cohorts before calling it.
#'
#' @import dplyr
#' @import lubridate
#'
#' @keywords internal
#' @noRd
.vt_classify <- function(data.EIR, data.schedule, vaccines = NULL, birth_cohorts = NULL) {

  # Checks if the birth_cohorts variable is used
  if(!is.null(birth_cohorts)) {
    data.EIR <- data.EIR %>%
      filter(year(date_birth) %in% birth_cohorts)
  }

  # determine doses to evaluate
  doses_to_use <- data.schedule %>%
    pull(dose) %>%
    unique()
  if(!is.null(vaccines)) {
    doses_to_use <- vaccines
  }

  # prepare EIR with age at vaccination
  prepare_EIR <- data.EIR %>%
    filter(dose %in% doses_to_use) %>%
    mutate(age_at_vax = as.numeric(date_vax - date_birth))

  # Warns if any records were vaccinated before birth (points to dcc_ module)
  .validate_age_at_vax(prepare_EIR)

  classified <- prepare_EIR %>%
    left_join(data.schedule, by = "dose") %>%
    # Clasify timely, untimely and date missing
    mutate(timeliness = case_when(
      is.na(date_vax) | is.na(date_birth) ~ "DATE_MISSING",
      age_at_vax < age_schedule_low | age_at_vax > age_schedule_high ~ "UNTIMELY",
      TRUE ~ "TIMELY"
    )) %>%
    # Days outside the timeliness window: negative if before age_schedule_low,
    # positive if after age_schedule_high, NA for TIMELY and DATE_MISSING records
    mutate(days_outside_range = case_when(
      age_at_vax < age_schedule_low ~ age_at_vax - age_schedule_low,
      age_at_vax > age_schedule_high ~ age_at_vax - age_schedule_high
    ))

  return(classified)
}
