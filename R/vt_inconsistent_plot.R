#' (V)accination (T)imeliness Inconsistent Records Plot
#'
#' Generates a diverging lollipop plot of untimely records by the absolute value of days outside the timeliness window, binned into customizable intervals with a final open-ended category. The same magnitude bins are shared by both directions on the x axis: records vaccinated too early (before \code{age_schedule_low}) are plotted below zero, and records vaccinated too late (after \code{age_schedule_high}) are plotted above zero.
#'
#' @param data.EIR Data frame. A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param data.schedule Data frame. A data frame defining the vaccination schedule. See \code{pahoabc.schedule} for expected structure.
#' @param vaccines Character (optional). A character vector specifying the doses to include in the analysis, faceting the plot by \code{dose}. If \code{NULL} (default), all doses in \code{data.schedule} are included and pooled together (no facet).
#' @param day_groups List of numeric vectors of length 2. Each element is a \code{c(lower, upper)} pair defining a magnitude bin, shared by both the "before" and "after" direction. Bins must start at 0 and be contiguous (each bin starts where the previous one ends). The last bin is extended to \code{Inf}. Default is 10-day bins from 0 to 100.
#'
#' @return A ggplot object representing the diverging lollipop plot.
#'
#' @import dplyr
#' @import ggplot2
#'
#' @export
vt_inconsistent_plot <- function(
    data.EIR,
    data.schedule,
    vaccines = NULL,
    day_groups = list(
      c(0, 10), c(10, 20), c(20, 30), c(30, 40), c(40, 50),
      c(50, 60), c(60, 70), c(70, 80), c(80, 90), c(90, 100)
    )
) {

  # validations
  .validate_data.schedule(data.schedule)
  .validate_data.EIR(data.EIR, data.schedule)
  .validate_date(data.EIR$date_birth, "date_birth")
  .validate_date(data.EIR$date_vax, "date_vax")
  .validate_vaccines(vaccines, data.EIR, "data.EIR")
  .validate_vaccines(vaccines, data.schedule, "data.schedule")
  .validate_day_groups(day_groups)

  plot_data <- .vt_classify(data.EIR, data.schedule, vaccines)

  n_missing <- sum(plot_data$timeliness == "DATE_MISSING")

  # builds a magnitude label for a c(lower, upper) bin
  .label_bin <- function(g, is_last) {
    if(is_last) {
      return(paste0(g[1], "+"))
    }
    paste0(g[1], " to ", g[2] - 1)
  }

  # number of bins
  n_groups <- length(day_groups)
  # one label per bin, e.g. "0 to 9"; the last bin gets an open-ended label, e.g. "90+"
  magnitude_labels <- mapply(.label_bin, day_groups, seq_len(n_groups) == n_groups)

  # cut points: the lower value of each bin, plus Inf so the last bin has no upper limit
  breaks <- c(sapply(day_groups, function(g) g[1]), Inf)

  # facet by dose only when vaccines is specified
  dose_group <- if(!is.null(vaccines)) "dose" else character(0)

  # Calculates day difference outside the timeliness window, bins it by magnitude, and counts records
  plot_counts <- plot_data %>%
    # keeps only untimely records
    filter(timeliness == "UNTIMELY") %>%
    # adds direction and bin labelling
    mutate(
      direction = ifelse(days_outside_range < 0, "BEFORE", "AFTER"),
      delta_abs = abs(days_outside_range),
      bin_label = cut(delta_abs, breaks = breaks, labels = magnitude_labels, right = FALSE, include.lowest = TRUE)
    ) %>%
    # counts records per direction and bin (and dose, if vaccines is specified)
    count(direction, bin_label, across(all_of(dose_group))) %>%
    # Show the counts as negative when administered before the eligibility window, positive when after
    mutate(n_signed = ifelse(direction == "BEFORE", -n, n))

  # do plot
  p <- ggplot(plot_counts, aes(x = bin_label, y = n_signed, color = direction)) +
    geom_segment(aes(x = bin_label, xend = bin_label, y = 0, yend = n_signed), linewidth = 1) +
    geom_point(size = 3) +
    geom_hline(yintercept = 0, color = "black") +
    labs(
      title = "Untimely records by day difference outside the timeliness window",
      subtitle = "Below zero: vaccinated before age_schedule_low. Above zero: vaccinated after age_schedule_high.",
      x = "Days outside timeliness window (magnitude)",
      y = "Number of records",
      caption = paste0("Number of records with at least one date missing: ", n_missing)
    ) +
    scale_color_manual(values = c("BEFORE" = "#9cdbf4", "AFTER" = "#fabf7b")) +
    theme_classic() +
    theme(
      axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
      panel.border = element_rect(fill = NA),
      legend.title = element_blank()
    )

  # facets by dose when vaccines is specified (also for a single dose, so its name is shown)
  if(!is.null(vaccines)) {
    p <- p + facet_wrap(~dose)
  }

  return(p)
}
