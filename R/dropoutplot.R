#' Nominal dropout rate
#'
#' @param nominal_dropout_data Dataframe formatted from the result of the nominal_dropout function
#' @param vertical Boolean that shows the plot vertical or horizontal, default is F which corresponds to horizontal. True corresponds to vertical.
#' @param order Organizes the bars based on three options: "alpha", "desc" or "asc", default is "alpha"
#' @return A ggplot simple barplot for the administrative level used to calculate the nominal dropout. Includes the nominal dropout rate, numerator, denominator and adherence rate. based on the administrative level, birth cohort and vaccines selected
#'
#'
#' @import dplyr
#' @import lubridate
#' @import tidyr
#' @import ggplot2
#' @export
#'

dropoutplot <- function(nominal_dropout_data, vertical=F, order = "alpha"){
  # This function produces a dropout plot so we filter the adherence data
  nominal_dropout_data <- nominal_dropout_data %>%
    filter(dropout == "dropout")

  # Selects the name of the x axis depending on the level of disgregation in data
  if("ADM2_residence" %in% colnames(nominal_dropout_data)){
    x_var <- "ADM2_residence"
  } else if ("ADM1_residence" %in% colnames(nominal_dropout_data)){
    x_var <- "ADM1_residence"
  } else {
    x_var <- "dropout"
    nominal_dropout_data <- nominal_dropout_data %>%
      mutate(dropout = ifelse(dropout == "dropout", "country", dropout))
  }
  # Converts xvar into a symbol
  x_var <- sym(x_var)

  # Organizes the plot based on alpha asc or desc
  if(order == "alpha") {
    order_vector <- nominal_dropout_data %>%
      arrange(!!x_var) %>%
      pull(!!x_var)
  } else if(order == "asc"){
    order_vector <- nominal_dropout_data %>%
      arrange(percent) %>%
      pull(!!x_var)
  } else if(order == "desc"){
    order_vector <- nominal_dropout_data %>%
      arrange(desc(percent)) %>%
      pull(!!x_var)
  }

  #completes the order in the df
  nominal_dropout_data <- nominal_dropout_data %>%
    mutate(x_label = factor(!!x_var, levels=order_vector))

  "Sets title for x axis and y axis"
  plot_title <- ifelse(x_var == "dropout", "Dropout plot, country", paste0("Dropout plot by ", x_var, ", country"))
  plot_x <- ifelse(x_var == "dropout", "", x_var)

  #Does simple plot
  dropoutplot <- ggplot(data =  nominal_dropout_data, aes(x=x_label, y = percent))+
    geom_bar(stat="identity", position="dodge")+
    labs(title=plot_title, y="Dropout rate (%)", x= plot_x)

  # rotates coordinates if vertical option selected
  if(vertical == T){
    dropoutplot <- dropoutplot+
      coord_flip()
  }

  # Returns the dropout bar plot (simple)
  return(dropoutplot)
}

