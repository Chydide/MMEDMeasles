#source("measles_stan.R")

data <- list(
  n_observations = 2,
  n_cohorts = 2,
  age = c(c(1, 2), c(2, 3)),
  vaccine_status = c(c(20, 10), c(20, 10)),
  sample_size = c(c(100, 100), c(100, 100)),
  population_size = c(c(200, 200), c(200, 200))
)
measles_stan(data, chains=1, iter = 20, refresh = 5)
