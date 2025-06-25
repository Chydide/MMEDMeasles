#source("measles_stan.R")

data <- list(
  n_observations = 3,
  total_population = 100,
  vaccinated = c(20, 30, 40)
)
fit <- measles_stan(data, chains=1, iter = 20, refresh = 5)
fit

data <- list(
  n_observations = 3,
  total_population = 100
)
fit <- measles_stan(data, chains=1, iter = 20, refresh = 5, algorithm="Fixed_param")
fit