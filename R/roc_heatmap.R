#' (R)esidence (Oc)currence Heatmap
#'
#' This function generates a heatmap displaying the proportion of doses administered
#' by place of occurrence, for each place of residence.
#'
#' @param data The output from the `pahoabc::roc_distribution` function.
#'
#' @return A ggplot object representing the heatmap.
#'
#' @import stringr
#' @import dplyr
#' @import ggplot2
#'
#' @export
roc_heatmap <- function(data) {
  # check if ADM1 or ADM2
  is_adm2 <- any(stringr::str_detect(names(data), "ADM2"))

  # construct the column names according to the geographic level
  geo_level <- ifelse(is_adm2, "2", "1")
  residence_col <- paste0("ADM", geo_level, "_residence")
  occurrence_col <- paste0("ADM", geo_level, "_occurrence")

  # make proportions from 0 to 100
  prepare_data <- data %>% mutate(proportion = round(proportion * 100))

  # do plot
  p <- ggplot(
    prepare_data,
    aes(
      x = !!sym(residence_col),
      y = !!sym(occurrence_col),
      fill = proportion
      )
    ) +
    labs(
      title = "Proportion of doses administered by place of occurrence",
      x = "Residence",
      y = "Occurrence"
    ) +
    geom_tile(color = "gray") +
    geom_text(
      aes(label = paste0(proportion, "%")),
      size = 4,
      color = "white"
    ) +
    scale_fill_gradient(
      low = "#91bfdb",
      high = "#173052",
      limits = c(0, 100)
    ) +
    theme_classic() +
    theme(legend.position = "none")

  return(p)
}
