#' Models model
#'
#' @export
#' @param data Data. TODO: add format.
#' @param ... Arguments passed to `rstan::sampling` (e.g. iter, chains).
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
measles_stan <- function(
    data,
    ...)
{
  standata <- list(
    n_observations = length(data), 
    n_cohorts = length(data[1]),
  )
  out <- rstan::sampling(stanmodels$lm, data = standata, ...)
  return(out)
}
