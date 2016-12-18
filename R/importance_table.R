#' importance_table
#'
#' importance_table returns a data_frame of variable importance for decision trees methods rpart randomForest, and gbm.step (from the dismo package).
#'
#' @note treezy currently only works for rpart and gbm.step functions. In the
#' future more features will be added so that it works for many
#' decision trees
#'
#' @param x An rpart, randomForest, or gbm.step, or model
#' @param ... extra functions or arguments
#' @return A tibble containing the importance score made with the intention of turning it into a text table with `knitr` or `xtable`
#'
#' @examples
#'
#' # retrieve a tibble of the variable importance from a decision tree model
#' \dontrun{
#'  # rpart object
#'  library(rpart)
#' fit_rpart <- rpart(Kyphosis ~ Age + Number + Start, data = kyphosis)
#'
#' importance_table(fit_rpart)
#'
#' # you can even use piping
#'
#' fit_rpart %>% importance_table
#'
#' # gbm.step object
#'
#' library(dismo)
#' library(gbm)
#'
#' fit_gbm_step <- gbm.step(data = iris,
#'                          gbm.x = c(1:3),
#'                          gbm.y = 4,
#'                          tree.complexity = 1,
#'                          family = "gaussian",
#'                          learning.rate = 0.01,
#'                          bag.fraction = 0.5)
#'
#' importance_table(fit_gbm_step)
#'
#' # with piping
#' fit.gbm.step %>% importance_table
#'
#' Unfortunately it cannot yet run a gbm object:
#'
#'
#' gbm.fit <- gbm(Sepal.Width ~ .,
#'                distribution = "gaussian",
#'                data = iris)
#'
#' importance_table(gbm.fit)
#'
#'
#' #A randomForest object
#'     set.seed(1)
#'     data(iris)
#'     fit_rf <- randomForest(Species ~ ., iris,
#'                             proximity=TRUE,
#'                             keep.forest=FALSE)
#'
#' importance_table(fit_rf)
#'
#' }
#' @note https://github.com/dgrtwo/broom
#'
#' @export
importance_table <- function(x, ...) UseMethod("importance_table")

#' @export
importance_table.NULL <- function(x, ...) NULL

#' @export
importance_table.default <- function(x, ...) {

    stop("alas, importance_table does not know how to deal with data of class ", class(x), call. = FALSE)

  }

# rpart -----------------------------------------------------------------------

#' @export
importance_table.rpart <- function(x, ...){

    # Some trees are stumps, we need to skip those that are NULL (stumps)
    # so here we say, "If variable importance is NOT NULL, do the following"
    # Another option would be to only include those models which are not null.

    if (is.null(x$variable.importance) == FALSE) {

    x <-
      x$variable.importance %>%
      data.frame(variable = names(x$variable.importance),
                 importance = as.vector(x$variable.importance),
                 row.names = NULL) %>%
      dplyr::select(variable,
                    importance) %>%
      dplyr::as_data_frame()

    } else {

      # if rpart_frame just contains a decision stump, make NULL datasets.

      x <- data.frame(variable = NULL,
                      importance = NULL,
                      row.names = NULL) %>%
        dplyr::as_data_frame()
    } # end else

  # no need to modify the class of the object.
    # res <- x
    # class(res) <- c("imp_tbl", class(res))
    # return(res)
  return(x)

}

# gbm -------------------------------------------------------------------------

#' @export
importance_table.gbm <- function(x, ...){

    x <-
      x$contributions %>%
        # make it a dataframe
        dplyr::as_data_frame() %>%
        # rename the variables
        dplyr::rename(variable = var,
                      importance = rel.inf) %>%
        dplyr::as_data_frame()

    # no need to return this info
    # res <- x
    # class(res) <- c("imp_tbl", class(res))
    # return(res)
    return(x)
}

# random forests --------------------------------------------------------------

#' @note you can pass importance_metric = FALSE or TRUE, if you want to show the importance metrics
#' @export
importance_table.randomForest <- function(x, importance_metric = FALSE, ...){


      # get the names of the variables used
      variable <- randomForest::importance(x) %>%
        row.names %>%
        data.frame(variable = .)

      pt1 <- randomForest::importance(x) %>%
        as.data.frame(row.names = F) %>%
        dplyr::as_data_frame()

      imp_tbl <- dplyr::bind_cols(variable,
                                  pt1) %>%
          dplyr::as_data_frame()

      # don't rearrange / gather
      if (importance_metric == FALSE) {

          return(imp_tbl)

          # gather to get different info
      } else if(importance_metric == TRUE){

          new_cols <- imp_tbl %>%
              colnames %>%
              grep("variable",
                   x = .,
                   invert = TRUE,
                   value=TRUE)

          aug_imp_tbl <-
          tidyr::gather_(data = imp_tbl,
                         key_col = "importance_metric",
                         value_col = "importance",
                         gather_cols = new_cols)

          return(aug_imp_tbl)

      }




}


# caret -----------------------------------------------------------------------

#' @export

importance_table.train <- function(x, ...){

  x <- caret::varImp(x)$importance %>%
    data.frame(variable = row.names(.),
               importance = .,
               row.names = NULL) %>%
    dplyr::rename(importance = Overall) %>%
    dplyr::as_data_frame()

  # no need to return this info
  # res <- x
  # class(res) <- c("imp_tbl", class(res))
  # return(res)
  return(x)

}


# future code for gbm objects, not gbm.step...
## new method for gbm to get importance value for .gbm methods (not gbm.step)
#
# view_importance <- function(x){
#
#   relative.influence(x) %>%
#     as.data.frame %>%
#     data.frame(importance = .[,1],
#                variable = row.names(.),
#                row.names = NULL) %>%
#     select(variable,
#            importance) %>%
#     arrange(-importance)
#
