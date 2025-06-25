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
  out <- rstan::sampling(stanmodels$measles, data = data, ...)
  return(out)
}
