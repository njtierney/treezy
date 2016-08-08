#' gg_partial_plot
#'
#' @description Uses the "partial_dependence" function to plot partial dependencefor BRT models. Future work will be into finding a way to generalize these methods to rpart and randomForest models, as an S3 method. This code is bespoke at the moment, and isn't designed as a flexible way to create plots, so I would recommend that people who want to plot their own partial plots just use `partial_dependence` and go from there.
#'
#' @param x The GBM model to be used
#'
#' @param vars The variables used in the GBM model, this is a character vector
#'
#' @return a faceted ggplot plot of the variables
#'
#' @note code can then be customised to add in extra "boundaries", as it were
#' geom_hline(aes(yintercept = 3.729),
#'             colour = "orange") +
#'             geom_hline(aes(yintercept = 12.675),
#'             colour = "green")

#'
#' @export

gg_partial_plot <- function(x,
                            vars){

  df_box <- list("vector", length(vars))

  for (i in (1:length(vars))){

  df_box[[i]] <- partial_dependence(x, vars[[i]])

  }

  df <- bind_rows(df_box)

  # make another

  df_mean <-
    df %>%
    group_by(variable) %>%
    summarise(mean = mean(fitted_function))

  ggplot(data = df,
         aes(x = value,
             y = fitted_function)) +
    geom_line() +
    facet_wrap(~variable,
               ncol = 2,
               scales = "free_x") +
    geom_hline(data = df_mean,
               aes(yintercept = mean),
               colour = "red",
               linetype = "dashed",
               alpha = 0.75) +
    labs(x = "Variable Values",
         y = "Model Predicted Values")

} # end function

