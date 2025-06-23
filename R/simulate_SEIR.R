#' Create SEIR model.
#' 
#' @export
#' @param pop Population.
simulate_SEIR <- function(pop = 1e6, R0 = 15, vaccine_coverage = 0.9, 
                          SIA_day = 60, SIA_coverage = 0.7, 
                          gamma = 1/7, sigma = 1/10, days = 180) {
  library(deSolve)
  
  beta <- R0 * gamma
  init <- c(S = pop * (1 - vaccine_coverage), E = 0, I = 10, R = pop * vaccine_coverage)
  
  SEIR <- function(t, state, parms) {
    with(as.list(state), {
      if (round(t) == SIA_day) {
        S <- S * (1 - SIA_coverage)
        R <- R + S * SIA_coverage
      }
      dS <- -beta * S * I / pop
      dE <- beta * S * I / pop - sigma * E
      dI <- sigma * E - gamma * I
      dR <- gamma * I
      list(c(dS, dE, dI, dR))
    })
  }
  
  out <- ode(y = init, times = 0:days, func = SEIR, parms = NULL)
  as.data.frame(out)
}

#' Add together two numbers
#' 
#' @export
#' @param x A number.
#' @param y A number.
#' @returns A numeric vector.
#' @examples
#' add(1, 1)
#' add(10, 1)
add <- function(x, y) {
  x + y
}