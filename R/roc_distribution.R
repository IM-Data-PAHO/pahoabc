#' (R)esidence (Oc)currence Dose Distribution
#'
#' This function calculates the distribution of vaccinations by place of residence
#' and place of occurrence, and outputs a data frame with frequencies and proportions
#' of vaccinations for each combination. It is designed to handle both ADM1- and ADM2-level
#' geographic levels.
#'
#' @param data.EIR A data frame containing electronic immunization registry data.
#' @param vaccine A character string specifying the vaccine dose to analyze (e.g., "DTP1").
#' @param birth_cohort An integer specifying the birth cohort to analyze.
#' @param geo_level A character string specifying the geographic level to analyze. Must be either `ADM1` or `ADM2`.
#' @param include_self_matches A logical specifying whether to include those cases where the place of residence matches the place of vaccination (occurrence). Default is \code{FALSE}.
#' @param within_ADM1 A character string specifying the "ADM1" region of interest when \code{geo_level} is "ADM2". If \code{geo_level} is "ADM2", this parameter is required.
#'
#' @return A data frame with proportions of doses applied by place of occurrence, for each place of residence.
#'
#' @import dplyr
#'
#' @export
roc_distribution <- function(data.EIR, vaccine, birth_cohort, geo_level, include_self_matches = FALSE, within_ADM1 = NULL) {

  .validate_character(vaccine, "vaccine", exp_len = 1)
  .validate_vaccines(vaccine, data.EIR, "data.EIR")
  .validate_numeric(birth_cohort, "birth_cohort", exp_len = 1)
  .validate_geo_level(geo_level, ADM_to_check = c("ADM1", "ADM2"))
  .validate_logical(include_self_matches, "include_self_matches")
  .validate_character(within_ADM1, "within_ADM1", exp_len = 1)

  # check if within_ADM1 is specified if ADM2 selected
  if(geo_level == "ADM2" & is.null(within_ADM1)) {
    stop("Error: The within_ADM1 parameter must be specified when geo_level is ADM2.")
  }

  # select the data of interest
  prepare_EIR <- data.EIR %>%
    # select a dose
    filter(dose == vaccine) %>%
    # select a birth cohort
    filter(year(date_birth) == birth_cohort) %>%
    # filter for ADM1_residence if necessary
    filter(if(geo_level == "ADM2") {ADM1_residence == within_ADM1} else {TRUE})

  # change name of ADM2_occurrence for all that do not belong to within_ADM1
  if(geo_level == "ADM2") {
    prepare_EIR <- prepare_EIR %>%
      mutate(ADM2_occurrence = ifelse(
        ADM1_occurrence == within_ADM1,
        ADM2_occurrence,
        "OTHER"
      ))
  }

  # columns to select
  residence_col <- paste0(geo_level, "_residence")
  occurrence_col <- paste0(geo_level, "_occurrence")

  # get all unique places of residence and occurrence
  all_residences <- unique(prepare_EIR[[residence_col]])
  all_occurrences <- unique(prepare_EIR[[occurrence_col]])

  # create a complete list of all possible combinations
  complete_combinations <- expand.grid(
    residence = all_residences,
    occurrence = all_occurrences,
    stringsAsFactors = FALSE
  )

  # rename columns dynamically to match geo_level
  colnames(complete_combinations) <- c(residence_col, occurrence_col)

  # remove combinations where both columns are equal
  # NOTE: only when include_self_matches is false
  if(!include_self_matches) {
    complete_combinations <- filter(
      complete_combinations,
      !!sym(residence_col) != !!sym(occurrence_col)
    )
  }

  # create a table with all the places of residence and occurrence
  frequencies <- prepare_EIR %>%
    # select only the columns of place of residence and occurrence
    select(!!sym(residence_col), !!sym(occurrence_col)) %>%
    # remove those cases where both columns are equal
    # NOTE: only when include_self_matches is false
    filter(if(!include_self_matches) {!!sym(residence_col) != !!sym(occurrence_col)} else {TRUE}) %>%
    # calculate the frequency of each unique pair
    count(!!sym(residence_col), !!sym(occurrence_col), name = "frequency")

  # calculate the proportion of vaccinations for each place of residence
  proportions <- complete_combinations %>%
    # make sure to have all possible places of residence and occurrence
    left_join(., frequencies, by = c(residence_col, occurrence_col)) %>%
    # add frequencies for those cases where there wasn't a match
    mutate(frequency = replace_na(frequency, 0)) %>%
    # calculate the proportion for each place of residence
    group_by(!!sym(residence_col)) %>%
    mutate(proportion = if(sum(frequency) > 0) {frequency / sum(frequency)} else {0}) %>%
    ungroup()

  # print it nicely
  proportions <- proportions %>% arrange(!!sym(residence_col))

  return(proportions)
}
