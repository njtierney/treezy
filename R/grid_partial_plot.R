#' grid_partial_plot
#'
#' grid_partial_plot plots partial dependence plots from gbm.step models in ggplot
#'
#' @description grid_partial_plot does basically the same job as gg_partial_plot but it has the capacity to plot factors alongside continuous variables. It does this by using gridExtra::grid.arrange. This might not be the most elegant or general solution, but it does work.
#'
#' @param x a gbm object
#' @param vars a character vector of the variables you want to plot
#' @param factors a character vector of those variables which are factors
#' @param ... additional options that you might want to send to gridExtra
#'
#' @export

# constructor function ---------------------------------------------------------

grid_partial_plot <- function(x, vars, factors, ...) UseMethod("grid_partial_plot")

# default method ---------------------------------------------------------------

#' default method for grid_partial_plot
#'
#'
#' @export
#'
grid_partial_plot.default <- function(x,
                                      vars,
                                      factors){

##### make a list to hold the partial dependence information -------------------
    df_box <- list("vector", length(vars))

###### go through and calculate the partial dependence for each variable
    for (i in (1:length(vars))){

        df_box[[i]] <- partial_dependence(x, vars[[i]])

        } # end for loop

##### bind the lists together
    df <- bind_rows(df_box)

##### ID which variables are factors in df_box that have seg_s and smok in it
    re_fac <- which(vars %in% factors)

##### coerce variables that are factors to factors -----------------------------

    for(i in (re_fac)){

        df_box[[i]]$value <- as.factor(df_box[[i]]$value)

        } # end loop

  # glimpse(df_box[[3]])

##### calculate the mean prediction for each variable --------------------------

    # make a list to hold the data of the mean prediction for each variable
    df_box_mean <- list("vector", length(vars))

    # calculate the mean predicted value for each variable
    for(i in (1:length(vars))){

        df_box_mean[[i]] <-
            df_box[[i]] %>%
            dplyr::group_by(variable) %>%
            dplyr::summarise(mean = mean(fitted_function))

        } # end of for loop

##### draw and store the partial predictive plots ------------------------------

    # make a list to hold the partial predictive plots
    grid_partial_plots <- list("vector", length(vars))

    # draw each plot
    for(i in (1:length(vars))){

        # get the name of the variable
        var_lab <- df_box[[i]]$variable[1]

    ##### draw a plot with geom_point for factor variables ---------------------
        if(i %in% re_fac){

            grid_partial_plots[[i]] <-
                ggplot2::ggplot(data = df_box[[i]],
                       ggplot2::aes(x = value,
                                    y = fitted_function)) +
                ggplot2::geom_point() +
                # add a horizontal line to show the mean predicted value
                ggplot2::geom_hline(data = df_box_mean[[i]],
                           ggplot2::aes(yintercept = mean),
                           colour = "red",
                           linetype = "dashed",
                           alpha = 0.75) +
                # add labels for each variable
                ggplot2::labs(x = paste("Variable Values for", var_lab),
                              y = paste("Predicted", x$gbm.call$response.name))

############# draw a plot with geom_line for continuous variables --------------

            } else {

                grid_partial_plots[[i]] <-
                    ggplot2::ggplot(data = df_box[[i]],
                           ggplot2::aes(x = value,
                                        y = fitted_function)) +
                    ggplot2::geom_line() +
                    # add the mean predicted value
                    ggplot2::geom_hline(data = df_box_mean[[i]],
                                        ggplot2::aes(yintercept = mean),
                                        colour = "red",
                                        linetype = "dashed",
                                        alpha = 0.75) +
                    # add the labels for each variable
                    ggplot2::labs(x = paste("Variable Values for", var_lab),
                                  y = paste("Predicted", x$gbm.call$response.name))
                } # end else

  } # close the plotting loop

### create overall plot using gridExtra::grid.arrange --------------------------

    n <- length(grid_partial_plots)

    nCol <- floor(sqrt(n))

    do.call("grid.arrange", c(grid_partial_plots, ncol=nCol))

} # end of function

# S3 method for caret's "train" class ------------------------------------------

# grid_partial_plot.train <- function(x,
#                                     vars,
#                                     factors){
#
#
#
#
# } # end function
