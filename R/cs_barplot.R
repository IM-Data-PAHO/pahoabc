#' (C)omplete (S)chedule Coverage Bar Plot
#'
#' Generates a bar plot of complete schedule vaccination coverage, grouped by geographic area and colored by birth cohort.
#'
#' @param data Data frame. The output from the \code{pahoabc::cs_coverage} function.
#' @param geo_level The same geographic level provided in \code{pahoabc::cs_coverage}. Must be "ADM0", "ADM1" or "ADM2".
#' @param birth_cohorts Numeric (optional). A vector specifying the birth cohort(s) for which coverage should be plotted. If \code{NULL} (default), all years are plotted.
#' @param within_ADM1 Character (optional). When analyzing data at the "ADM2" level, this optional parameter lets you specify a particular "ADM1" to filter. Default is \code{NULL}, which means no filtering by "ADM1".
#'
#' @return A ggplot object representing the bar plot.
#'
#' @import dplyr
#' @import ggplot2
#'
#' @export
cs_barplot <- function(data, geo_level, birth_cohorts = NULL, within_ADM1 = NULL) {

  .validate_geo_level(geo_level)
  .validate_birth_cohorts(birth_cohorts)
  .validate_within_ADM1(within_ADM1)

  # determine aesthetic for x axis
  if(geo_level != "ADM0") {
    x_aes <- paste0(geo_level, "_residence")
  } else {
    x_aes <- NULL
  }

  # prepare data for plot
  prepare_data <- data
  if(!is.null(birth_cohorts)) {
    prepare_data <- prepare_data %>% filter(year %in% birth_cohorts)
  }
  prepare_data <- prepare_data %>%
    mutate(year = factor(year)) %>%
    filter(if(!is.null(within_ADM1)) {ADM1_residence == within_ADM1} else {TRUE})

  # do plot
  if(geo_level == "ADM0") {
    p <- ggplot(prepare_data, aes(x = geo_level, y = coverage, fill = year))
  } else {
    p <- ggplot(prepare_data, aes(x = reorder(!!sym(x_aes), -coverage), y = coverage, fill = year))
  }

  p <- p + geom_col(position = "dodge") +
    labs(
      title = "Complete Schedule Coverage",
      x = "Geographic Area",
      y = "Coverage (%)"
    ) +
    scale_y_continuous(limits = c(0, 100)) +
    scale_fill_brewer(palette = "Pastel1") +
    theme_classic() +
    theme(
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
      legend.title = element_blank(),
      panel.border = element_rect(fill = NA)
    )

  return(p)
}
