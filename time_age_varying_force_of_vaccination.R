library(rstan)
# Setup
A <- 2
T <- 5
delta_t <- 1.0

# Simulated time-varying lambda
lambda_true <- matrix(c(0.8, 0.6, 0.9, 1.2, 0.7,   # age group 1
                        0.4, 0.5, 0.6, 0.3, 0.4),  # age group 2
                      nrow = A, byrow = TRUE)

N <- matrix(sample(800:1000, A * T, replace = TRUE), nrow = A)
p <- 1 - exp(-lambda_true * delta_t)
V <- matrix(rbinom(A * T, N, p), nrow = A)

# Stan data
stan_data <- list(A = A, T = T, N = N, V = V, delta_t = delta_t)

# Fit Stan model

time_age_vary_mod <- stan_model(
  file = "inst/stan/time_varying_force_of_vaccination.stan",     # Make sure this file is in your working directory
  model_name = "time_age_vary_mod"
)

fit <- sampling(
  time_age_vary_mod,
  data   = stan_data,
  iter   = 500,
  warmup = 100,
  chains = 2,
  seed   = 123,
  #verbose = TRUE
)


# Posterior summaries
print(fit, pars = "lambda", probs = c(0.025, 0.5, 0.975))
param_names <- fit@model_pars
cat("Stan parameters:\n", paste(param_names, collapse = ", "), "\n")

plot(fit,
     pars    = param_names,
     plotfun = "trace")

stan_dens(fit, pars="lambda", separate_chains = T)


# 7) Forest plot with 80% credible intervals
stan_plot(fit,
          pars         = param_names,
          ci_level     = 0.80,
          show_density = TRUE)


# Formating to change vector matrix to dataframe for true values

fv <- as.data.frame(lambda_true) %>%
  mutate(i = row_number()) %>%
  pivot_longer(cols = starts_with("V"), names_to = "j", values_to = "value") %>%
  mutate(
    j = as.integer(sub("V", "", j)),               # extract column number
    param = paste0("lambda[", i, ",", j, "]")      # construct label
  ) %>%
  select(param, value) %>%
  mutate(time = as.integer(gsub(".*,(\\d+)\\]", "\\1",param)), 
         age_group = as.integer(gsub("lambda\\[(\\d+),\\d+\\]", "\\1",param)))


# add new variables for time and age group
sim_1 <- summary(fit, pars = "lambda")$summary %>%
  as.data.frame() %>% 
  mutate(time = as.integer(gsub(".*,(\\d+)\\]", "\\1",rownames(.))), 
         age_group = as.integer(gsub("lambda\\[(\\d+),\\d+\\]", "\\1",rownames(.)))) %>%
   inner_join(fv)


# Plot fit of forces of vaccination by age group and time
ggplot(sim_1, aes(x = time, color=factor(age_group))) +
  geom_line(aes(y = value), color = "black", linetype = "dashed") +
  geom_point(aes(y = `50%`), size = 2) +
  geom_errorbar(aes(ymin = `2.5%`, ymax = `97.5%`), width = 0.2) +
  facet_grid(~age_group)+
  labs(
    title = "Posterior Estimates of Force of Vaccination",
    y = "Force of Vaccination",
    x = "Time",
    color='Age group'
  ) +
  theme_minimal()
