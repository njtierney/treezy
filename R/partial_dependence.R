#' partial_dependence
#'
#' @description : Some code that returns the partial dependence values for a given set of variables for a gbm.step model. In the future this function will work for other decision trees
#'
#' @param x a gbm.step object
#' @param var a set of variables you want to retrieve partial dependence for
#' @param ... extra arguments you might want to pass downstream

#'
#' @note This requires the loading of the `gbm.step` function. Hopefully sometime soom I can just write this in vanilla R myself. Future extensions will allow for this function to work for `rpart`, `gbm`, `gbm.step`, and `randomForest`.
#'
#'
#' @export
partial_dependence <- function(x, var, ...) UseMethod("partial_dependence")

#' Default method for partial dependence
#'
#' @param x a decision tree object
#' @param var a set of variables you want to retrieve partial dependence for
#' @param ... extra arguments you might want to pass downstream
#' @export

partial_dependence.default <- function(x, var, ...){

  # grab the name sof the variables in the dataframe used in the model, and give their vector columns position to `i`
  ### x = ###angaus.tc5.lr01
  ### var = ###"SegSumT"
  i <- which(x$var.names == var)

  # get the matrix out of the `plot.gbm`
  response_matrix <- gbm::plot.gbm(x,
                                   i.var = i,
                                   n.trees = x$n.trees,
                                   return.grid = TRUE)

  # make a dataframe, which contains the observed calues, and the fitted function values, and then adds another column containing the variable name.
  df <- data.frame(value = as.numeric(response_matrix[ , 1]),
                   fitted_function = response_matrix[ , 2])
    df$variable <- x$var.names[i]

  return(df)

  } # end of thingy

#' Partian dependence method for caret::train objects
#'
#' @param x an object of class train
#' @param var a set of variables you want to retrieve partial dependence for
#' @param ... extra arguments you might want to pass downstream
#'
#' @return a dataframe of partial dependence
#' @export
#'
partial_dependence.train <- function(x, var, ...){

  # grab the name sof the variables in the dataframe used in the model, and give their vector columns position to `i`

  i <- which(x$finalModel$var.names == var)

  # get the matrix out of the `plot.gbm`
  response_matrix <- gbm::plot.gbm(x,
                                   i.var = i,
                                   n.trees = x$n.trees,
                                   return.grid = TRUE)

  # make a dataframe, which contains the observed calues, and the fitted function values, and then adds another column containing the variable name.
  df <- data.frame(value = as.numeric(response_matrix[ , 1]),
                   fitted_function = response_matrix[ , 2]) %>%
    dplyr::mutate(variable = x$var.names[i])

  return(df)

} # end of thingy
