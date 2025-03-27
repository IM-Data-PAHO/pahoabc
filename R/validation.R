#' Validate numeric values.
#'
#' @keywords internal
#' @noRd
.validate_numeric <- function(value, value_name, value_length = NULL) {
  if(!is.null(value) & !is.numeric(value)) {
    stop(paste0("Error: ", value_name, " should be numeric (or NULL when not in use)."))

    if(!is.null(value_length)) {
      if(length(value) != value_length) {
        stop(paste0("Error: ", value_name, " should be of length ", value_length, "."))
      }
    }
  }
}

#' Validate character values.
#'
#' @keywords internal
#' @noRd
.validate_character <- function(value, value_name, value_length = NULL) {
  if(!is.null(value) & !is.character(value)) {
    stop(paste0("Error: ", value_name, " should be a character (or NULL when not in use)."))

    if(!is.null(value_length)) {
      if(length(value) != value_length) {
        stop(paste0("Error: ", value_name, " should be of length ", value_length, "."))
      }
    }
  }
}

#' Validate geo_level.
#'
#' @keywords internal
#' @noRd
.validate_geo_level <- function(geo_level) {
  .validate_character(geo_level, 1, "geo_level")

  if (!(geo_level %in% c("ADM0", "ADM1", "ADM2"))) {
    stop("Error: The geo_level parameter should be 'ADM0', 'ADM1', or 'ADM2'.")
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

  if(!all(c("dose", "age_schedule") %in% names(data.schedule))) {
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

  # TODO: This could be declared as a package variable so we dont
  #       have to repeat it here.
  names_in_roc_coverage <- c(
    "year", "dose", "ADM0", "ADM1", "ADM2", "doses_applied",
    "population", "coverage", "coverage_type"
  )

  if(!all(names_in_roc_coverage %in% names(data))) {
    stop("Error: data should be the output from roc_coverage.")
  }
}
