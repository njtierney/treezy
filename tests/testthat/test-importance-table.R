context("importance_table works")

library(rpart)
library(treezy)
fit_rpart <- rpart(Kyphosis ~ ., data = kyphosis)

test_that("importance_table has the right names",{
expect_named(importance_table(fit_rpart), c("variable","importance"))
})

fit_lm <- lm(Age ~ ., data = kyphosis)

test_that("importance_table fails when using a linear model",{
    expect_error(importance_table(fit_lm))
})
