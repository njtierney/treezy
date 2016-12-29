#' rss
#'
#' Calculate the RSS of a decision tree model.
#'
#' @param x A fitted rpart, gbm, or randomForest model
#' @param ... extra arguments
#' @return The Residuals Sums of Squares (RSS)  for the models `rpart`, `gbm.step`, and `randomForest`.
#'
#' @note when using the `caret` package, be sure to select `model$finalModel` when entering it into the `rss` function. Also note that the RSS only makes sense for continuous outcomes.
#'
#' @examples
#' \dontrun{
#' library(rpart)
#'
#' fit.rpart <- rpart(Kyphosis ~ Age + Number + Start, data = kyphosis)
#'
#' rss(fit.rpart)
#'}
#' @export

# Constructor function --------------------------------------------------------

rss <- function(x, ...) UseMethod("rss")

# Classification and Regression Tree -------------------------------------------
#' @export
rss.rpart <- function(x, ...){

  sum((stats::residuals(x)^2))

}

# Boosted Regression Tree ------------------------------------------------------
#' @export
rss.gbm <- function(x, ...){

  sum(x$residuals^2)

}

# Random Forest ----------------------------------------------------------------
#' @export
rss.randomForest <- function(x, ...){

  res <- x$y - x$predicted

  sum(res^2)

} # end function
