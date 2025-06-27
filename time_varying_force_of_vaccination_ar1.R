library(rstan)
library(tidyverse)

# Settings
A <- 2          # age groups
T <- 20         # time points
delta_t <- 1.0  # interval length
N <- matrix(100, A, T)  # population at risk (constant for simplicity)

# True AR(1) parameters
phi_true <- 0.8
sigma_true <- 0.3
set.seed(123)

# Simulate true log(lambda)
log_lambda <- matrix(NA, A, T)
lambda <- matrix(NA, A, T)
for (a in 1:A) {
  log_lambda[a, 1] <- rnorm(1, 0, sigma_true / sqrt(1 - phi_true^2))
  for (t in 2:T) {
    log_lambda[a, t] <- phi_true * log_lambda[a, t-1] + rnorm(1, 0, sigma_true)
  }
  lambda[a, ] <- exp(log_lambda[a, ])
}

# Simulate vaccination counts
V <- matrix(NA, A, T)
for (a in 1:A) {
  for (t in 1:T) {
    p <- 1 - exp(-lambda[a, t] * delta_t)
    V[a, t] <- rbinom(1, N[a, t], p)
  }
}

# Prepare data for Stan
stan_data <- list(
  A = A,
  T = T,
  N = N,
  V = V,
  delta_t = delta_t
)

# Compile and fit Stan model


fit <- stan(
  file = "inst/stan/time_varying_force_of_vaccination_ar1.stan",
  data = stan_data,
  chains = 4,
  iter = 2000,
  warmup = 1000,
  seed = 123,
  control = list(adapt_delta = 0.95)
)
# Extract lambda estimates
lambda_post <- rstan::extract(fit)$lambda
lambda_mean <- apply(lambda_post, c(2, 3), mean)

# Plot estimates vs. truth
df_plot <- expand.grid(age = 1:A, time = 1:T) %>%
  mutate(
    lambda_true = as.vector(lambda),
    lambda_est = as.vector(lambda_mean)
  )

ggplot(df_plot, aes(x = time)) +
  geom_line(aes(y = lambda_true, color = "True"), linewidth = 1.2) +
  geom_line(aes(y = lambda_est, color = "Estimated"), linetype = "dashed", linewidth = 1.2) +
  facet_wrap(~ age, scales = "free_y", labeller = label_both) +
  labs(
    y = "Force of Vaccination (lambda)",
    title = "Estimated vs. True Lambda over Time",
    color = "Line"
  ) +
  theme_bw()