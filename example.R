#source("measles_stan.R")

data <- list(
  n_observations = 2,
  n_cohorts = 2,
  age = array(c(c(1, 2), c(2, 3)), dim=c(2, 2)),
  vaccine_status = array(c(c(10, 20), c(70, 100)), dim=c(2, 2)),
  sample_size = array(c(c(100, 200), c(100, 200)), dim=c(2, 2)),
  population_size = array(c(c(1000, 1000), c(900, 800)), dim=c(2, 2))
)
data <- list(
  n_observations = 1,
  n_cohorts = 2,
  age = array(c(c(0, 0)), dim=c(2, 1)),
  vaccine_status = array(c(c(0, 0)), dim=c(2, 1)),
  sample_size = array(c(c(100, 200)), dim=c(2, 1)),
  population_size = array(c(c(1000, 1000)), dim=c(2, 1))
)
measles_stan(data, chains=1, iter = 20, refresh = 5)

out <- rstan::sampling(
  stanmodels$measles,
  data = list(
    n_observations = 2,
    n_cohorts = 2,
    age = array(, dim=c(2, 2)),
    vaccine_status = array(c(c(10, 20), c(70, 100)), dim=c(2, 2)),
    sample_size = array(c(c(100, 200), c(100, 200)), dim=c(2, 2)),
    population_size = array(c(c(1000, 1000), c(900, 800)), dim=c(2, 2))
  ),
  iter=1,
  chains=1,
  algorithm="Fixed_param"
)
