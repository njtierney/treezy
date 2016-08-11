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
#' @examples
#'
#' # using gbm.step from the dismo package
#'
#' library(gbm)
#' library(dismo)
#'
#' # load data
#'
#' data(Anguilla_train)
#' anguilla_train <- Anguilla_train[1:200,]
#'
#' # fit model
#' angaus_tc_5_lr_01 <- gbm.step(data = anguilla_train,
#'                               gbm.x = 3:14,
#'                               gbm.y = 2,
#'                               family = "bernoulli",
#'                               tree.complexity = 5,
#'                               learning.rate = 0.01,
#'                               bag.fraction = 0.5)
#'
#' gg_partial_plot(angaus.tc5.lr01,
#'                    var = c("SegSumT",
#'                            "SegTSeas"))
#'
#' @export

gg_partial_plot <- function(x,
                            vars){

  df_box <- list("vector", length(vars))

  for (i in (1:length(vars))){

  df_box[[i]] <- partial_dependence(x, vars[[i]])

  }

  df <- dplyr::bind_rows(df_box)

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

