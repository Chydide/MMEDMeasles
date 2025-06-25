library(dplyr)

#source("measles_stan.R")

# Example of running the model ----
data <- list(
  n_observations = 5,
  total_population = 100,
  vaccinated = c(20, 30, 20, 0, 0)
)
fit <- measles_stan(data, chains=1, iter = 20, refresh = 5)
fit

# Get the force of vaccinations
force_of_vaccinations <- extract(fit, pars = "force_of_vaccination")[[1]][5,]
force_of_vaccinations

# Fake data -----
# Generate fake data from the model by setting run_estimation = 0
data2 <- list(
  n_observations = 3,
  total_population = 100,
  vaccinated = c(20, 30, 40),
  run_estimation = 0
)
sim_out <- measles_stan(data = data2, chains=5, iter = 20, refresh = 5)

# Get the generated fake data
fake_data_matrix  <- sim_out %>% 
  as.data.frame %>% 
  select(contains("vaccinated_sim"))

# View statistics on the fake vaccinated data for different "draws" (i.e. different
# parameters (force_of_vaccination))
summary_tbl <- apply(fake_data_matrix[1:5,], 1, summary)
View(summary_tbl)

# Get a vector of the simulated vaccination data
draw <- 5
vaccinated_sim <- extract(sim_out, pars = "vaccinated_sim")[[1]][draw,]
vaccinated_sim

# TODO: Plot

# Get the inferred force_of_vaccination[] parameters.
true_force_of_vaccinations <- extract(sim_out, pars = "force_of_vaccination")[[1]][draw,]
true_force_of_vaccinations

# Infer the force_of_vaccination parameters from the model using the simulated data
recapture_fit <- measles_stan(data = list(n_observations = 3,
                                          total_population = 100,
                                          # Note we now use vaccinated_sim
                                          vaccinated = vaccinated_sim, 
                                          # Note we not switch on run_estimation
                                          run_estimation = 1))

# TODO: what should we check for after running this?
recapture_fit

recaptured_force_of_vaccinations <- extract(recapture_fit, pars = "force_of_vaccination")[[1]][draw,]
recaptured_force_of_vaccinations
true_force_of_vaccinations

# Check by how much the inferred parameters differ
true_force_of_vaccinations - recaptured_force_of_vaccinations
# (Less than 0.1 when I last ran it)
