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

#' Compute the daily (pdf) and cumulative (cdf) distribution of vaccinations from daily counts.
#'
#' NOTE: data must already be grouped according to the disaggregation levels required,
#'       it must also contain the number of records vaccinated on each day (n) and it should
#'       be sorted by day within each group (for cumulative sum to work)
#'
#' @import dplyr
#'
#' @keywords internal
#' @noRd
.vt_compute_distribution <- function(data) {

  distributions <- data %>%
    mutate(
      total = sum(n),
      pdf = n / total * 100,
      cum_n = cumsum(n),
      cdf = cum_n / total * 100,
      # records not yet vaccinated at the start of each day
      n_at_risk = total - lag(cum_n, default = 0)
    )

  return(distributions)
}

#' Prepare the data shared by vt_cdf_plot and vt_pdf_plot.
#'
#' Filters by within_ADM1, checks the areas in highlight, combines all areas into a single
#' distribution, and computes the percentile labels, default max_days, subtitle and caption.
#'
#' NOTE: Does not validate its inputs. Callers must validate data, percentile, highlight,
#'       within_ADM1 and max_days before calling it.
#'
#' @import dplyr
#'
#' @keywords internal
#' @noRd
.vt_distribution_plot_data <- function(data, percentile, highlight, within_ADM1, max_days) {

  # detect geo level
  ADM_detected <- .detect_geo_level(data)
  subnational_detected <- ADM_detected > 0
  geo_col <- if(subnational_detected) paste0("ADM", ADM_detected) else NULL

  # detect if data is disaggregated by dose
  dose_detected <- "dose" %in% names(data)
  dose_col <- if(dose_detected) "dose" else character(0)

  group_cols <- intersect(c("dose", "ADM1", "ADM2"), names(data))

  # prepare data for plot
  prepare_data <- data %>%
    filter(if(!is.null(within_ADM1)) {ADM1 %in% within_ADM1} else {TRUE})

  # check that the areas to highlight exist
  if(!is.null(highlight)) {
    if(!subnational_detected) {
      stop("Error: highlight is only available when data is disaggregated by ADM1 or ADM2.")
    }
    missing_areas <- setdiff(highlight, prepare_data[[geo_col]])
    if(length(missing_areas) > 0) {
      stop(paste0("Error: The following areas in highlight are not in data: ", paste(missing_areas, collapse = ", "), "."))
    }
  }

  # Combine all areas in the data and calculate some summary numbers
  combined_totals <- prepare_data %>%
    distinct(across(all_of(group_cols)), total, n_early, n_missing) %>%
    group_by(across(all_of(dose_col))) %>%
    summarise(total = sum(total), n_early = sum(n_early), n_missing = sum(n_missing), .groups = "drop")

  # Sum together all areas in the data and get the combined distribution
  combined_data <- prepare_data %>%
    group_by(across(all_of(c(dose_col, "day")))) %>%
    summarise(n = sum(n), window_end = first(window_end), .groups = "drop") %>%
    group_by(across(all_of(dose_col))) %>%
    .vt_compute_distribution() %>%
    ungroup()

  # adds the excluded records, so combined_data has the same structure as the output of vt_distribution
  excluded_cols <- combined_totals %>% select(all_of(dose_col), n_early, n_missing)
  if(dose_detected) {
    combined_data <- combined_data %>% left_join(excluded_cols, by = "dose")
  } else {
    combined_data <- combined_data %>% bind_cols(excluded_cols)
  }

  # Series drawn in color: all areas combined + the highlighted areas
  combined_label <- if(subnational_detected) "All areas combined" else "ADM0"
  series_levels <- c(combined_label, highlight)
  series_colors <- setNames(
    c("#2E9FDF", "#E66100", "#5D3A9B", "#1B9E77", "#D41159", "#8C510A")[seq_along(series_levels)],
    series_levels
  )

  highlight_data <- NULL
  if(!is.null(highlight)) {
    highlight_data <- prepare_data %>%
      filter(!!sym(geo_col) %in% highlight)
  }

  # a function that returns the number of days needed for each colored series to reach a percentile
  series_percentile <- function(p) {
    bind_rows(
      vt_percentile(combined_data, p) %>% mutate(series = combined_label),
      if(!is.null(highlight_data)) vt_percentile(highlight_data, p) %>% mutate(series = !!sym(geo_col))
    ) %>%
      mutate(series = factor(series, levels = series_levels))
  }

  # By default, shows up to the day where 95% is vaccinated in every colored series,
  # so a few very late (or wrongly dated) records do not stretch the x-axis
  if(is.null(max_days)) {
    max_days <- max(series_percentile(95)$day)
    message(paste0("Showing up to day ", max_days, " (95th percentile). Use max_days to change it."))
  }

  # distribution of each colored series
  series_data <- bind_rows(
    combined_data %>% mutate(series = combined_label),
    if(!is.null(highlight_data)) highlight_data %>% mutate(series = !!sym(geo_col))
  ) %>%
    mutate(series = factor(series, levels = series_levels))

  # distribution of each geographic area, drawn as grey lines for context
  area_data <- NULL
  if(subnational_detected) {
    area_data <- prepare_data %>%
      mutate(series = !!sym(geo_col))
  }

  # last timely day of each dose, for the shaded area (not possible when doses are pooled)
  window_data <- NULL
  if(dose_detected) {
    window_data <- combined_data %>%
      distinct(dose, window_end)
  }

  # number of excluded records for the plot's caption
  excluded <- combined_totals %>%
    # summarise again in case combined_totals was grouped by dose
    summarise(total = sum(total), n_early = sum(n_early), n_missing = sum(n_missing))
  pct_early <- excluded$n_early / (excluded$total + excluded$n_early) * 100
  caption <- paste0(
    "Vaccinated before the timeliness window (excluded): ", excluded$n_early,
    " (", round(pct_early, 1), "%).\n",
    "Number of records with at least one date missing (excluded): ", excluded$n_missing
  )

  # subtitle explaining the grey lines and pooling (the shaded area is explained in the legend)
  subtitle_parts <- c(
    if(!dose_detected) "All doses pooled together",
    if(subnational_detected) paste0("Grey lines: each ", geo_col, " area")
  )
  subtitle <- if(length(subtitle_parts) > 0) paste(subtitle_parts, collapse = ". ") else NULL

  # return a list of several objects used by the vt_pdf_plot and vt_cdf_plot functions
  return(list(
    subnational_detected = subnational_detected,
    dose_detected = dose_detected,
    dose_col = dose_col,
    series_data = series_data,
    combined_label = combined_label,
    series_colors = series_colors,
    area_data = area_data,
    window_data = window_data,
    percentile_data = if(!is.null(percentile)) series_percentile(percentile) else NULL,
    max_days = max_days,
    subtitle = subtitle,
    caption = caption
  ))
}
