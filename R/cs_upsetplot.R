#' (C)omplete (S)chedule Coverage Upset Plot
#'
#' Generates an UpSet plot showing the number of individuals who received various combinations of vaccine doses defined in a vaccination schedule, for a given birth cohort.
#' Individuals with a complete schedule are highlighted.
#'
#' @param data.EIR A data frame containing individual vaccination records. See \code{pahoabc.EIR} for expected structure.
#' @param data.schedule A data frame defining the vaccination schedule. See \code{pahoabc.schedule} for expected structure.
#' @param birth_cohort Numeric. A single birth year for which to calculate and visualize coverage.
#' @param denominator The denominator to use. If \code{NULL} (default), then the number of unique IDs in \code{data.EIR} is used.
#' @param min_size The minimum number of doses (as a percentage of the \code{denominator}) a group has to have in order to be shown in the plot. Default is 1 percent.
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
cs_upsetplot <- function(data.EIR, data.schedule, birth_cohort, denominator = NULL, min_size = 1) {

  .validate_data.schedule(data.schedule)
  .validate_numeric(birth_cohort, "birth_cohort", exp_len = 1)
  .validate_numeric(denominator, "denominator", exp_len = 1)
  .validate_numeric(min_size, "min_size", exp_len = 1)

  # get the doses in schedule
  doses_in_schedule <- data.schedule %>%
    pull(dose) %>%
    unique()

  # get children with complete schedule
  # NOTE: This could be done easier with pivot_wider, but it runs faster
  #       this way.
  # Step 1: Generate data frame with one row per child, with dose_list
  #         showing a comma-separated string of the doses the child has
  line_list <- data.EIR %>%
    mutate(year = year(date_birth)) %>%
    filter(year == birth_cohort) %>%
    group_by(ID) %>%
    summarise(
      dose_list = paste0(sort(unique(dose)), collapse = ","),
      complete_schedule = all(doses_in_schedule %in% dose),
      .groups = "drop"
    )

  # Step 2: Create empty columns and fill them if the child has the vaccine
  #         in dose_list
  line_list[doses_in_schedule] <- FALSE
  for (dose in doses_in_schedule) {
    # NOTE: Use \\b to detect word boundaries
    line_list[[dose]] <- str_detect(line_list$dose_list, paste0("\\b", dose, "\\b"))
  }

  # check if anyone has a complete schedule to know if we have to highlight
  # the CS bar in the upset plot
  if(any(line_list$complete_schedule)) {
    highlight_query <- list(upset_query(intersect = doses_in_schedule, fill = "#fc8d59", color = "#fc8d59"))
  } else {
    highlight_query <- list() # an empty query
    warning("Warning: No individuals in data.EIR with complete schedule according to data.schedule.")
  }

  # get denominator
  if(is.null(denominator)) {
    denominator <- line_list %>% nrow()
  }

  # get max set size
  max_set_size <- line_list %>%
    select(all_of(doses_in_schedule)) %>%
    summarise(across(everything(), ~ sum(.), .names = "count_{.col}")) %>%
    max()

  # do plot
  p <-
    upset(
      data = line_list,
      intersect = doses_in_schedule,
      # modify labels on vertical bars
      base_annotations = list(
        # specify coverage for each category
        'Intersection size' = intersection_size(
          text_mapping = aes(
            label = paste0(
              round(
                !!get_size_mode('exclusive_intersection') / denominator * 100,
                1
              ),
              '%'
            )
          )
        ) +
          ylab("Number of people")
      ),
      # modify labels on horizontal bars
      set_sizes = (
        upset_set_size() +
          geom_text(
            aes(label = paste0(round(after_stat(count) / denominator * 100), "%")),
            hjust = 1.1, stat = 'count'
          ) +
          expand_limits(y = max_set_size * 1.1) +
          ylab("Number of doses")
      ),
      # name of combination matrix axis
      name = "Dose combinations",
      # modify points in combination matrix
      matrix = (
        intersection_matrix(
          geom = geom_point(
            size = 5
          )
        )
      ),
      # keep only some groups
      min_size = denominator * min_size / 100,
      # highlight complete schedules (if applicable)
      queries = highlight_query,
      # keep all doses in schedule even if there are no matches
      keep_empty_groups = TRUE
    )

  return(p)
}
