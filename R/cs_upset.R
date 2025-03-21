#' (C)omplete (S)chedule Coverage Upset Plot
#'
#' Generates an UpSet plot showing the number of individuals who received various combinations of vaccine doses defined in a vaccination schedule, for a given birth cohort.
#' Individuals with a complete schedule are highlighted.
#'
#' @param data.EIR A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param data.pop A data frame with population denominators. Only works at ADM0. Must follow structure in \code{pahoabc.pop.ADM0}.
#' @param data.schedule A data frame defining the vaccination schedule. See \code{pahoabc.schedule} for expected structure.
#' @param birth_cohort Numeric. A single birth year for which to calculate and visualize coverage.
#'
#' @return A ComplexUpset plot.
#'
#' @import dplyr
#' @import tidyr
#' @import lubridate
#' @import ComplexUpset
#' @import ggplot2
#'
#' @export
cs_upset <- function(data.EIR, data.pop, data.schedule, birth_cohort) {

  # TODO: Fix set size for 2023

  .validate_birth_cohorts(birth_cohort)
  .validate_data.pop(data.pop, "ADM0")

  # get the doses in schedule
  doses_in_schedule <- data.schedule %>%
    pull(dose) %>%
    unique()

  # get population for birth cohorts
  denominator <- data.pop %>%
    filter(age == 0, year == birth_cohort) %>%
    pull(population) %>%
    sum()

  # get children with complete schedule
  line_list <- data.EIR %>%
    mutate(year = year(date_birth)) %>%
    select(-ends_with("occurrence"), -date_vax) %>%
    mutate(vaccinated = TRUE) %>%
    pivot_wider(
      names_from = "dose",
      values_from = "vaccinated",
      values_fn = ~ first(.x),
      values_fill = FALSE
    ) %>%
    mutate(complete_schedule = if_all(c(-ID, -date_birth, -ends_with("residence")), ~ .x)) %>%
    filter(year == birth_cohort)

  # get max set size
  max_set_size <- line_list %>%
    select(all_of(doses_in_schedule)) %>%
    summarise(across(everything(), ~ sum(.), .names = "count_{.col}")) %>%
    max()

  # do plot
  p <-
    upset(
      line_list,
      doses_in_schedule,
      base_annotations = list(
        # specify coverage for each category
        'Intersection size' = intersection_size(
          text_mapping = aes(
            label = paste0(
              round(
                !!get_size_mode('exclusive_intersection') / denominator * 100
              ),
              '%'
            )
          )
        ) +
          ylab("Number of doses")
      ),
      set_sizes = (
        upset_set_size() +
          geom_text(
            aes(label = paste0(round(after_stat(count) / denominator * 100), "%")),
            hjust = 1.1, stat = 'count'
          ) +
          expand_limits(y = max_set_size * 1.1) +
          ylab("Number of doses")
      ),
      matrix = (
        intersection_matrix(
          geom = geom_point(
            size = 5
          )
        )
      ),
      # only keep those that contribute to at least 5% of the total population
      min_size = denominator * 0.05,
      # highlight complete schedules
      queries = list(upset_query(intersect = doses_in_schedule, fill = "#fc8d59", color = "#fc8d59"))
    )

  return(p)
}
