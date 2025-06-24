#' Bayesian linear regression with Stan
#'
#' @export
#' @param x Numeric vector of input values.
#' @param y Numeric vector of output values.
#' @param ... Arguments passed to `rstan::sampling` (e.g. iter, chains).
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
lm_stan <- function(x, y, ...) {
  standata <- list(x = x, y = y, N = length(y))
  out <- rstan::sampling(stanmodels$lm, data = standata, ...)
  return(out)
}

# TODO:
# Simplest model
# t=1, age=1, V+ (number of vaccinated), N (sample size), P (population size)
# t=2, age=2, V+ (number of vaccinated), N (sample size), P (population size)

# P+: 1 - exp(- (lambda)*(delta t))
# V1+: Binomial (N1, P+/Pe)