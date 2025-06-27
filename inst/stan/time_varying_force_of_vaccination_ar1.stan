// file: time_varying_force_of_vaccination_ar1.stan
data {
  int<lower=1> A;              // number of age groups (2 here)
  int<lower=1> T;              // number of time points
  int<lower=0> N[A, T];        // number at risk
  int<lower=0> V[A, T];        // number vaccinated
  real<lower=0> delta_t;       // time interval (e.g. 1.0 for annual)
}

parameters {
  vector[T] log_lambda_raw[A];         // latent innovations (standardized)
  real<lower=-1, upper=1> phi;         // AR(1) coefficient (shared across age groups)
  real<lower=0> sigma;                 // AR(1) innovation std dev (shared)
}

transformed parameters {
  matrix<lower=0>[A, T] lambda;
  matrix[A, T] log_lambda;

  for (a in 1:A) {
    log_lambda[a, 1] = log_lambda_raw[a][1] * sigma / sqrt(1 - phi^2);  // stationary prior
    for (t in 2:T) {
      log_lambda[a, t] = phi * log_lambda[a, t-1] + sigma * log_lambda_raw[a][t];
    }
    for (t in 1:T) {
      lambda[a, t] = exp(log_lambda[a, t]);
    }
  }
}

model {
  // AR(1) latent innovations
  for (a in 1:A)
    log_lambda_raw[a] ~ normal(0, 1);

  // Likelihood
  for (a in 1:A)
    for (t in 1:T)
      V[a, t] ~ binomial(N[a, t], 1 - exp(-lambda[a, t] * delta_t));
}

generated quantities {
  int V_sim[A, T];
  for (a in 1:A) {
    for (t in 1:T) {
      real p = 1 - exp(-lambda[a, t] * delta_t);
      V_sim[a, t] = binomial_rng(N[a, t], p);
    }
  }
}