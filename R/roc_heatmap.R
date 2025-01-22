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

  # preparations for plot
  prepare_data <- data %>%
    # make proportions from 0 to 100
    mutate(proportion = round(proportion * 100)) %>%
    # compute text color dynamically: dark text on light background, light text on dark background
    mutate(text_color = ifelse(proportion > 50, "white", "black"))

  # reorder occurrence column: "OTHER" at the end always
  if(is_adm2) {
    occurrence_levels <- prepare_data[[occurrence_col]] %>%
      unique() %>%
      sort() %>%
      setdiff("OTHER") %>%  # Remove "OTHER" from sorted list
      c(., "OTHER")  # Prepend "OTHER" to the end

    prepare_data[[occurrence_col]] <- factor(prepare_data[[occurrence_col]], levels = occurrence_levels)
  }

  # do plot
  p <- ggplot(
    prepare_data,
    aes(
      x = !!sym(residence_col),
      y = !!sym(occurrence_col),
      fill = proportion,
      color = proportion
      )
    ) +
    labs(
      title = "Proportion of doses administered by place of occurrence",
      x = "Residence",
      y = "Occurrence"
    ) +
    geom_tile(color = "gray") +
    geom_text(
      aes(label = paste0(proportion, "%"), colour = text_color),
      size = 4
    ) +
    scale_fill_gradient(
      low = "white",
      high = "#173052",
      limits = c(0, 100)
    ) +
    scale_colour_identity() +
    theme_classic() +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 90, hjust = 1)
    )

  return(p)
}
