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
#' @param within_ADM1 A character string specifying the `ADM1` region of interest when `geo_level` is `ADM2`. If `geo_level` is `ADM2`, this parameter is required.
#'
#' @return A data frame with proportions of doses applied by place of occurrence, for each place of residence.
#'
#' @import dplyr
#'
#' @export
roc_distribution <- function(data.EIR, vaccine, birth_cohort, geo_level, within_ADM1 = NA) {

  # check geo_level is correctly specified
  if(!(geo_level %in% c("ADM1", "ADM2"))) {
    stop("Error: The geo_level parameter should be ADM1 or ADM2.")
  }

  # check if within_ADM1 is specified if ADM2 selected
  if(geo_level == "ADM2" && is.na(within_ADM1)) {
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
  complete_combinations <- filter(
    complete_combinations,
    !!sym(residence_col) != !!sym(occurrence_col)
  )

  # create a table with all the places of residence and occurrence
  frequencies <- prepare_EIR %>%
    # select only the columns of place of residence and occurrence
    select(!!sym(residence_col), !!sym(occurrence_col)) %>%
    # remove those cases where both columns are equal
    filter(!!sym(residence_col) != !!sym(occurrence_col)) %>%
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
    mutate(proportion = frequency / sum(frequency)) %>%
    ungroup()

  return(proportions)
}
