#' (C)omplete (S)chedule Coverage Bar Plot
#'
#' Generates a bar plot of complete schedule vaccination coverage, grouped by geographic area and colored by birth cohort.
#'
#' @param data The output from the \code{pahoabc::cs_coverage} function.
#' @param birth_cohorts Numeric (optional). A vector specifying the birth cohort(s) for which coverage should be plotted. If \code{NULL} (default), all years are plotted.
#'
#' @return A ggplot object representing the bar plot.
#'
#' @import dplyr
#' @import ggplot2
#'
#' @export
cs_barplot <- function(data, birth_cohorts = NULL) {

  # TODO: check birth cohort is correctly specified
  # TODO: Order plot

  # determine aesthetic for x axis
  if(any(c("ADM1_residence", "ADM2_residence") %in% names(data))) {
    is_adm2 <- "ADM2_residence" %in% names(data)
    x_aes <- ifelse(is_adm2, "ADM2_residence", "ADM1_residence")
  } else {
    x_aes <- NA
  }

  # prepare data for plot
  prepare_data <- data
  if(!is.null(birth_cohorts)) {
    prepare_data <- prepare_data %>% filter(year %in% birth_cohorts)
  }
  prepare_data <- prepare_data %>% mutate(year = factor(year))

  # do plot
  if(is.na(x_aes)) {
    p <- ggplot(prepare_data, aes(x = "ADM0", y = coverage, fill = year))
  } else {
    p <- ggplot(prepare_data, aes(x = !!sym(x_aes), y = coverage, fill = year))
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
