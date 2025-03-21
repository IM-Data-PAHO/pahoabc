#' Validate geo_level.
#'
#' @keywords internal
#' @noRd
.validate_geo_level <- function(geo_level) {
  if (!(geo_level %in% c("ADM0", "ADM1", "ADM2"))) {
    stop("Error: The geo_level parameter should be 'ADM0', 'ADM1', or 'ADM2'.")
  }
}

#' Validate data.pop according to geo_level.
#'
#' @keywords internal
#' @noRd
.validate_data.pop <- function(data.pop, geo_level) {
  if(!is.data.frame(data.pop)) {
    stop("Error: data.pop should be a data frame.")
  }

  # Check columns in data.pop based on geo_level
  has_ADM1 <- "ADM1" %in% names(data.pop)
  has_ADM2 <- "ADM2" %in% names(data.pop)

  if(geo_level == "ADM0" & (has_ADM1 | has_ADM2)) {
    stop("Error: data.pop should not contain ADM1 or ADM2 when geo_level is ADM0.")
  } else if (geo_level == "ADM1" & (!has_ADM1 | has_ADM2)) {
    stop("Error: data.pop should only contain ADM1 when geo_level is ADM1.")
  } else if (geo_level == "ADM2" & (!has_ADM1 | !has_ADM2)) {
    stop("Error: data.pop should contain both ADM1 and ADM2 when geo_level is ADM2.")
  }
}

#' Validate max_age.
#'
#' @keywords internal
#' @noRd
.validate_max_age <- function(max_age) {
  if(!is.null(max_age) & !is.numeric(max_age)) {
    stop("Error: max_age should be numeric (or NULL when not in use).")
  }
}

#' Validate birth_cohorts.
#'
#' @keywords internal
#' @noRd
.validate_birth_cohorts <- function(birth_cohorts) {
  if(!is.null(birth_cohorts) & !is.numeric(birth_cohorts)) {
    stop("Error: birth_cohorts should be numeric (or NULL when not in use).")
  }
}

#' Validate within_ADM1.
#'
#' @keywords internal
#' @noRd
.validate_within_ADM1 <- function(within_ADM1) {
  if(!is.null(within_ADM1) & !is.character(within_ADM1)) {
    stop("Error: within_ADM1 must be a character (or NULL when not in use).")
  } else if(length(within_ADM1) > 1) {
    stop("Error: within_ADM1 must have length 1.")
  }
}
