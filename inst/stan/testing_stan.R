library(rstan)
library(tidyverse)
#library(rstudioapi)  # for setting working directory in RStudio

# Set working directory to folder containing this script (RStudio only)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# 1) rstan options: reuse compiled code, multiple cores
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# 2) Simulate inputs matching Stan model logic
n  <- 5
fv <- c(0.2, 0.29, 0.31, 0.42, 0.3)  # true force of vaccination (per time point)
pop <- c(1000, 1056, 1122, 1234, 1267)  # total population at each time (used for info)

# Simulate vaccinated counts consistent with model's population_left logic
population_left <- pop[1]
vaccinated <- numeric(n)

for (i in 1:n) {
  prob <- 1 - exp(-fv[i])
  vaccinated[i] <- rbinom(1, size = population_left, prob = prob)
  population_left <- population_left - vaccinated[i]
}

# Create data list for Stan
data_list <- list(
  n_observations   = n,
  total_population = pop,
  vaccinated       = vaccinated,
  run_estimation   = 1
)

# 3) Compile the Stan model
measles_mod <- stan_model(
  file = "measles.stan",     # Make sure this file is in your working directory
  model_name = "measles_mod"
)

# 4) Fit the model
fit <- sampling(
  measles_mod,
  data   = data_list,
  iter   = 500,
  warmup = 100,
  chains = 2,
  seed   = 123,
  #verbose = TRUE
)

# 5) Print summary and parameter names
print(fit)
param_names <- fit@model_pars
cat("Stan parameters:\n", paste(param_names, collapse = ", "), "\n")

# 6) Trace plots
plot(fit,
     pars    = param_names,
     plotfun = "trace")

stan_dens(fit, pars="force_of_vaccination", separate_chains = T)

# 7) Forest plot with 80% credible intervals
stan_plot(fit,
          pars         = param_names,
          ci_level     = 0.80,
          show_density = TRUE)

# 8) Extract posterior summary of force_of_vaccination
sim_1 <- summary(fit, pars = "force_of_vaccination")$summary %>%
  as.data.frame() %>%
  mutate(time = 1:n, true_fv = fv)

# 9) Plot true vs estimated force_of_vaccination
ggplot(sim_1, aes(x = time)) +
  geom_line(aes(y = true_fv), color = "red", linetype = "dashed") +
  geom_point(aes(y = `50%`), size = 2) +
  geom_errorbar(aes(ymin = `2.5%`, ymax = `97.5%`), width = 0.2) +
  labs(
    title = "Posterior Estimates of Force of Vaccination",
    y = "Force of Vaccination",
    x = "Time"
  ) +
  theme_minimal()
