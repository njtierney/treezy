#' importance_plot
#'
#' \code{importance_plot} make a graph of variable importance
#'
#' takes an `rpart` or `gbm.step` fitted object and makes a plot of variable importance
#'
#' @param x is an rpart or gbm.step object
#'
#' @return a ggplot plot of the variable importance
#'
#' @examples
#'
#'  # an rpart object
#'  library(rpart)
#'  library(neato)
#' fit.rpart <- rpart(Kyphosis ~ Age + Number + Start, data = kyphosis)
#'
#' importance_plot(fit.rpart)
#'
#' # you can even use piping
#'
#' fit.rpart %>% importance_plot
#'
#'  # a randomForest object
#'
#'  set.seed(131)
#'   ozone.rf <- randomForest(Ozone ~ ., data=airquality, mtry=3,
#'                            importance=TRUE, na.action=na.omit)
#'   print(ozone.rf)
#'   ## Show "importance" of variables: higher value mean more important:
#'   importance(ozone.rf)
#'
#'   ## use importance_table
#'
#'   importance_table(ozone.rf)
#'
#'   # now plot it
#'
#'   importance_plot(ozone.rf)
#'
#' @export
#'
importance_plot <- function(x) UseMethod("importance_plot")

#' @export
importance_plot.default <- function(x){

  x %>%
    importance_table %>%
    ggplot2::ggplot(data = .,
                    ggplot2::aes(x = importance,
# make sure the plot is ordered by most important
                                 y = reorder(variable,
                                             importance))) +
    # ggplot2::geom_point() +
    ggalt::geom_lollipop(horizontal = TRUE,
                         point.size = 2) +
    ggplot2::labs(x = "Importance Score",
                  y = "Variables")

} # end function

#' @export
importance_plot.randomForest <- function(x){

# get names of columns (which changes according to the type of RF model)
# new_cols <-
# importance_table(x) %>%
#     colnames %>%
#     grep("variable",
#          x = .,
#          invert = TRUE,
#          value=TRUE)

# importance_table(x) %>%
#     tidyr::gather_(data = .,
#                    key_col = "importance_metric",
#                    value_col = "importance",
#                    gather_cols = new_cols) %>%
    importance_table.randomForest(x = x,
                                  importance_metric = TRUE) %>%
    ggplot(data = .,
           aes(x = importance,
               y = reorder(variable,
                           importance))) +
      # ggplot2::geom_point() +
      ggalt::geom_lollipop(horizontal = TRUE,
                           point.size = 2) +
    ggplot2::facet_wrap(~ importance_metric,
                        scales = "free_x") +
      ggplot2::theme(axis.text.x = element_text(angle = 45)) +
      ggplot2::labs(x = "Importance Score",
                    y = "Variables")

} # end function

