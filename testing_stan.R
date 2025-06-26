library(rstan)
library(tidyverse)

# 1) rstan options: reuse compiled code, parallel cores
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# 2) Simulated inputs
n  <- 5
fv <- c(0.2, 0.29, 0.31, 0.42, 0.3)
#fv=rep(.5, 5)
pop <- c(1000, 967, 904, 890, 823)
vaccinated <- rbinom(n, size = pop, prob = fv)
total_population <- sum(pop)

data_list <- list(
  n_observations   = n,
  total_population = total_population,
  vaccinated       = vaccinated,
  run_estimation   = 1
)

# 3) Compile Stan model into 'measles_mod'
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

measles_mod <- stan_model(
  file = "measles.stan",
  model_name = "measles_mod_v1"
)

fit <- sampling(
  measles_mod,
  data   = data_list,
  iter   = 500,
  warmup = 300,
  chains = 2
)

# 5) Print summary and list parameters
print(fit)
param_names <- fit@model_pars
print(param_names)
cat("Stan parameters:\n", paste(param_names, collapse = ", "), "\n")

# 6) Plot all parameters (trace + density)
plot(fit,
     pars    = param_names,
     plotfun = "trace")    # use "hist", "dens", or "interval" as desired

# 7) (Optional) Forest‐style intervals
rstan::stan_plot(fit,
                 pars         = param_names,
                 ci_level     = 0.80,
                 show_density = TRUE)

sim_1 <- summary(fit,pars = "force_of_vaccination")$summary %>%
  as.data.frame() %>%
  mutate(time = 1:5, true_fv = -log(1-fv))

ggplot(sim_1, aes(x= time)) +
  geom_line(aes(y = true_fv))+
  geom_point(aes(y =  `50%`))+
  geom_errorbar(aes(ymin = `2.5%`, ymax = `97.5%`))

