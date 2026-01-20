#' Validate numeric values.
#'
#' @keywords internal
#' @noRd
.validate_numeric <- function(value, value_name, min_len = NULL, exp_len = NULL, max_len = NULL) {
  if(!is.null(value) & !is.numeric(value)) {
    stop(paste0("Error: ", value_name, " should be numeric (or NULL when not in use)."))
  }

  if(!is.null(value)) {
    .validate_length(value, value_name, min_len, exp_len, max_len)
  }
}

#' Validate character values.
#'
#' @keywords internal
#' @noRd
.validate_character <- function(value, value_name, min_len = NULL, exp_len = NULL, max_len = NULL) {
  if(!is.null(value) & !is.character(value)) {
    stop(paste0("Error: ", value_name, " should be a character (or NULL when not in use)."))
  }

  if(!is.null(value)) {
    .validate_length(value, value_name, min_len, exp_len, max_len)
  }
}

#' Validate logical values.
#'
#' @keywords internal
#' @noRd
.validate_logical <- function(value, value_name) {
  if(!is.logical(value) | is.na(value)) {
    stop(paste0("Error: ", value_name, " should be a logical value."))
  }
}

#' Validate length of vector.
#'
#' @keywords internal
#' @noRd
.validate_length <- function(value, value_name, min_len = NULL, exp_len = NULL, max_len = NULL) {
  if(!is.null(min_len)) {
    if(length(value) < min_len) {
      stop(paste0("Error: ", value_name, " should be of at least length ", min_len, "."))
    }
  }

  if(!is.null(exp_len)) {
    if(length(value) != exp_len) {
      stop(paste0("Error: ", value_name, " should be exactly of length ", exp_len, "."))
    }
  }

  if(!is.null(max_len)) {
    if(length(value) > max_len) {
      stop(paste0("Error: ", value_name, " should be of at most length ", max_len, "."))
    }
  }
}

#' Validate geo_level.
#'
#' @keywords internal
#' @noRd
.validate_geo_level <- function(geo_level, ADM_to_check = c("ADM0", "ADM1", "ADM2")) {
  .validate_character(geo_level, "geo_level", 1)

  if(!(geo_level %in% ADM_to_check)) {
    stop(
      paste0(
        "Error: The geo_level parameter should be one of: ",
        paste0(ADM_to_check, collapse = ", "),
        "."
      )
    )
  }
}

#' Validate data.pop according to geo_level.
#'
#' @keywords internal
#' @noRd
.validate_data.pop <- function(data.pop, geo_level) {

  if(!is.null(data.pop) & !is.data.frame(data.pop)) {
    stop("Error: data.pop should be a data frame (or NULL when not in use).")
  }

  if(!is.null(data.pop)) {
    # Check columns in data.pop based on geo_level
    has_ADM1 <- "ADM1" %in% names(data.pop)
    has_ADM2 <- "ADM2" %in% names(data.pop)

    if(geo_level == "ADM0" & (has_ADM1 | has_ADM2)) {
      stop("Error: data.pop should not contain ADM1 or ADM2.")
    } else if (geo_level == "ADM1" & (!has_ADM1 | has_ADM2)) {
      stop("Error: data.pop should only contain ADM1.")
    } else if (geo_level == "ADM2" & (!has_ADM1 | !has_ADM2)) {
      stop("Error: data.pop should contain both ADM1 and ADM2.")
    }
  }
}

#' Validate coverage_type.
#'
#' @keywords internal
#' @noRd
.validate_coverage_type <- function(coverage_type) {
  .validate_character(coverage_type, "coverage_type", 1)

  if(!(coverage_type %in% c("residence", "occurrence"))) {
    stop("Error: coverage_type should be residence or occurrence.")
  }
}

#' Validate vaccines.
#'
#' @import dplyr
#'
#' @keywords internal
#' @noRd
.validate_vaccines <- function(vaccines, reference_vaccines, reference_name) {
  vaccines_in_schedule <- reference_vaccines %>% pull(dose) %>% unique()

  if(!is.null(vaccines) & !all(vaccines %in% vaccines_in_schedule)) {
    stop(paste0("Error: One or more of the specified vaccines are not in ", reference_name, "."))
  }
}

#' Validate data.schedule.
#'
#' @keywords internal
#' @noRd
.validate_data.schedule <- function(data.schedule) {
  if(!is.data.frame(data.schedule)) {
    stop("Error: data.pop should be a data frame.")
  }

  if(!all(c("dose", "age_schedule", "age_schedule_low", "age_schedule_high") %in% names(data.schedule))) {
    stop("Error: data.schedule should contain the following columns: dose, age_schedule.")
  }
}


#' Validate input data to roc_barplot.
#'
#' @keywords internal
#' @noRd
.validate_roc_barplot_data <- function(data) {
  if(!is.data.frame(data)) {
    stop("Error: data should be a data frame.")
  }

  minimum_columns <- c(
    "year", "dose", "doses_applied", "population", "coverage", "coverage_type"
  )

  if(!all(minimum_columns %in% names(data))) {
    stop("Error: data should be the output from roc_coverage.")
  }
}

#' Validate input data to cs_barplot.
#'
#' @keywords internal
#' @noRd
.validate_cs_barplot_data <- function(data) {
  if(!is.data.frame(data)) {
    stop("Error: data should be a data frame.")
  }

  minimum_columns <- c("year", "numerator", "population", "coverage")

  if(!all(minimum_columns %in% names(data))) {
    stop("Error: data should be the output from cs_coverage.")
  }

  # limit number of years so palette works in plot
  number_of_years <- data %>% pull(year) %>% unique() %>% length()

  if(number_of_years > 9) {
    stop("Error: Too many years in data. Please reduce to 9 or less.")
  }
}

#' Validate input data to roc_heatmap.
#'
#' @keywords internal
#' @noRd
.validate_roc_heatmap_data <- function(data) {
  if(!is.data.frame(data)) {
    stop("Error: data should be a data frame.")
  }

  minimum_columns <- c("frequency", "proportion")

  if(!all(minimum_columns %in% names(data))) {
    stop("Error: data should be the output from roc_distribution.")
  }
}


#' Validate EIR duplicates.
#'
#' @keywords internal
#' @noRd
#'
.validate_duplicates <- function(data.EIR, vac_init, vac_end) {
  data.EIR <- data.EIR %>%
    filter(dose == vac_init | dose == vac_end) %>%
    mutate(dose = ifelse(dose == vac_init, "vac_init", "vac_end"))

  data_unique_rows <- data.EIR %>%
    distinct(ID, dose) %>%
    nrow()
  data_rows <- data.EIR %>%
    nrow()

  if(data_unique_rows != data_rows) {
    warning("Data contains duplicate rows where ID and dose are duplicated. We recommend you verify for duplicates before running the process to increase accuracy. ")
  }
}

#' Validate Date object.
#'
#' @keywords internal
#' @noRd
.validate_date <- function(date_var, param_name = "date_var") {
  ## class check
  if (!inherits(date_var, "Date")) {
    stop(
      paste0("Error: `%s` must be of class Date (got <%s>).",
              param_name, paste(class(date_var), collapse = ", ")),
      call. = FALSE
    )
  }

  invisible(TRUE)  # silent success
}

#' Validate data.EIR structure and (optionally) schedule compatibility.
#'
#' @keywords internal
#' @noRd
.validate_data.EIR <- function(data.EIR, data.schedule = NULL) {
  if(!is.data.frame(data.EIR)) {
    stop("Error: data.EIR should be a data frame.")
  }

  required_columns <- c(
    "ID",
    "date_birth",
    "date_vax",
    "ADM1_residence",
    "ADM2_residence",
    "ADM1_occurrence",
    "ADM2_occurrence",
    "dose"
  )

  if(!all(required_columns %in% names(data.EIR))) {
    stop("Error: data.EIR should contain the following columns: ID, date_birth, date_vax, ADM1_residence, ADM2_residence, ADM1_occurrence, ADM2_occurrence, dose.")
  }

  if(!is.null(data.schedule)) {
    missing_in_schedule <- setdiff(unique(data.EIR$dose), unique(data.schedule$dose))
    if(length(missing_in_schedule) > 0) {
      warning(
        paste0(
          "Warning: The following dose(s) are present in data.EIR but missing from data.schedule: ",
          paste(missing_in_schedule, collapse = ", "),
          "."
        )
      )
    }
  }
}
