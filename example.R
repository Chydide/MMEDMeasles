#source("measles_stan.R")

data <- list(
  n_observations = 2,
  total_population = 100,
  vaccinated = c(20, 30)
)
fit <- measles_stan(data, chains=1, iter = 20, refresh = 5)
fit
