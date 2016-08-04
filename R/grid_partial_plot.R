#' grid_partial_plot
#'
#' \code{grid_partial_plot} plots partial dependence plots from gbm.step models in ggplot
#'
#' @description grid_partial_plot does basically the same job as gg_partial_plot but it has the capacity to plot factors alongside continuous variables. It does this by using gridExtra::grid.arrange. There is probably a more elegant/general solution out there but this worked so I'm sticking with it for now.
#'
#' @param x a gbm.step object
#' @param vars a character vector of the variables you want to plot
#' @param factors a character vector of those variables which are factors
#'
#' @export

grid_partial_plot <- function(x, ...) UseMethod("grid_partial_plot")

grid_partial_plot.default <- function(x,
                                      vars,
                                      factors){

  df_box <- list("vector", length(vars))

  for (i in (1:length(vars))){

    df_box[[i]] <- get_partial_dependence(x,
                                          vars[[i]])

  }

  df <- bind_rows(df_box)
  df_box

  # for those data frames in df_box that have seg_s and smok in it
  re_fac <- which(vars %in% factors)

  for(i in (re_fac)){

    df_box[[i]]$value <- as.factor(df_box[[i]]$value)

  }

  # glimpse(df_box[[3]])

  df_box_mean <- list("vector", length(vars))

  for(i in (1:length(vars))){

    df_box_mean[[i]] <-
      df_box[[i]] %>%
      group_by(variable) %>%
      summarise(mean = mean(fitted_function))

  }

  grid_partial_plots <- list("vector", length(vars))

  for(i in (1:length(vars))){

    # get the name of the variable
    var_lab <- df_box[[i]]$variable[1]

    # for those that are factors, draw point plot
    if(i %in% re_fac){

      grid_partial_plots[[i]] <-
        ggplot(data = df_box[[i]],
               aes(x = value,
                   y = fitted_function)) +
        geom_point() +
        geom_hline(data = df_box_mean[[i]],
                   aes(yintercept = mean),
                   colour = "red",
                   linetype = "dashed",
                   alpha = 0.75) +
        labs(x = paste("Variable Values for", var_lab),
             y = paste("Predicted", x$gbm.call$response.name))

      # otherwise, they are continuous, and make it a geom_line()
    } else {

      grid_partial_plots[[i]] <-
        ggplot(data = df_box[[i]],
               aes(x = value,
                   y = fitted_function)) +
        geom_line() +
        geom_hline(data = df_box_mean[[i]],
                   aes(yintercept = mean),
                   colour = "red",
                   linetype = "dashed",
                   alpha = 0.75) +
        labs(x = paste("Variable Values for", var_lab),
             y = paste("Predicted", x$gbm.call$response.name))
    } # end else

  } # close loop

  # now create the overall plot using grid.arrange from gridExtra

  n <- length(grid_partial_plots)

  nCol <- floor(sqrt(n))

  do.call("grid.arrange", c(grid_partial_plots, ncol=nCol))


} # end of function

grid_partial_plot.train <- function(x,
                                    vars,
                                    factors){




} # end function
