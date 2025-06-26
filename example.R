library(dplyr)
library(tidyverse)

#source("measles_stan.R")

# Example of running the model ----
vaccinated = c(20, 30, 20, 0, 0)
data <- list(
  n_observations = 5,
  total_population = 100,
  vaccinated = vaccinated
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
vaccinated_sim <- rstan::extract(sim_out, pars = "vaccinated_sim")[[1]][draw,]
vaccinated_sim

# Plot original vaccination data vs sampled data
plot_data1 = data.frame(n = seq(1:length(vaccinated)), vaccinated = vaccinated)
ggplot(plot_data1, aes(x=n, y=vaccinated)) + geom_point()

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

# Check fit
recapture_fit

# Get the force of vaccinations for a single draw
draw <- 5
recaptured_force_of_vaccinations <- rstan::extract(recapture_fit, pars = "force_of_vaccination")[[1]][draw,]
recaptured_force_of_vaccinations
true_force_of_vaccinations

# Check by how much the inferred parameters differ
true_force_of_vaccinations - recaptured_force_of_vaccinations
# (Less than 0.1 when I last ran it)

# Plot original force of vaccination vs estimated force of vaccination.
plot_data2 = data.frame(n = seq(1:length(true_force_of_vaccinations)), true_force_of_vaccinations = true_force_of_vaccinations)
ggplot(plot_data2, aes(x=n, y=true_force_of_vaccinations)) + geom_point()

recaptured_force_of_vaccinations_matrix  <- recapture_fit %>% 
  as.data.frame %>% 
  select(contains("force_of_vaccination"))
recaptured_force_of_vaccinations_matrix

df1 <- as.data.frame(recaptured_force_of_vaccinations_matrix) |> mutate(n = row_number())
df2 <- (
  pivot_longer(df1, !n, names_to="num", values_to="value") 
  |> mutate(group_num = as.integer(str_extract(num, "\\d+")))
  |> mutate(original_or_recaptured="Recaptured")
  |> select(group_num, value, original_or_recaptured)
)

df3 = (
  data.frame(n = seq(1:length(true_force_of_vaccinations)), true_force_of_vaccinations = true_force_of_vaccinations)
  |> mutate(original_or_recaptured="Original")
  |> mutate(group_num = n)
  |> mutate(value = true_force_of_vaccinations)
  |> select(group_num, value, original_or_recaptured)
)
df_combined <- rbind(df2, df3)
true_data_plot <- (
  ggplot(df_combined, aes(x=group_num, y=value, color=original_or_recaptured)) + 
  geom_point() +
  scale_color_manual(values = c("Original" = "red", "Recaptured" = "grey"))
)
true_data_plot

recaptured_data_plot <- ggplot(df2, aes(x=group_num, y=value)) + geom_point()
