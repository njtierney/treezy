#' rss
#'
#' @description A function that gives returns the RSS of a decision tree model.
#'
#'
#' @return The Residuals Sums of Squares (RSS)  for the models `rpart`, `gbm.step`, and `randomForest`.
#'
#' @note when using the `caret` package, be sure to select `model$finalModel` when entering it into the `rss` function. Also note that the RSS only works for continuous variables.
#'
#' @examples
#'
#' library(rpart)
#'
#' fit.rpart <- rpart(Kyphosis ~ Age + Number + Start, data = kyphosis)
#'
#' rss(fit.rpart)
#'
#' @param x A fitted rpart, gbm, or rf model
#' @export

#=======================#
# Constructor functions #
#=======================#

rss <- function(x){

  UseMethod("rss", x)

}

#=====================================#
#' Classification and Regression Tree #
#=====================================#
#' @param x A fitted rpart model
#' @export
rss.rpart <- function(x){

  sum((residuals(x)^2))

}

#==========================#
#' Boosted Regression Tree #
#==========================#
#' @param x A fitted gbm.step model
#' @export
rss.gbm <- function(x){

  sum(x$residuals^2)

}
#================#
#' Random Forest #
#================#
#' @param x A fitted randomForest model
#' @export
rss.randomForest <- function(x){

  res <- x$y - x$predicted

  sum(res^2)

} # end function
