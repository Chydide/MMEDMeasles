// file: time_varying_force_of_vaccination.stan
data {
  int<lower=1> A;              // number of age groups (2 here)
  int<lower=1> T;              // number of time points
  int<lower=0> N[A, T];        // number at risk
  int<lower=0> V[A, T];        // number vaccinated
  real<lower=0> delta_t;       // time interval (e.g. 1.0 for annual)
}

parameters {
  matrix<lower=0>[A, T] lambda;  // time-varying FoV
}

model {
  // Prior: weakly informative for lambda
  for (a in 1:A) 
    for (t in 1:T) 
      lambda[a, t] ~ exponential(1);

  // Likelihood
  for (a in 1:A)
    for (t in 1:T)
      V[a, t] ~ binomial(N[a, t], 1 - exp(-lambda[a, t] * delta_t));
}

generated quantities {
  int V_sim[A, T];  // synthetic vaccination counts
  for (a in 1:A) {
    for (t in 1:T) {
      real p = 1 - exp(-lambda[a, t] * delta_t);
      V_sim[a, t] = binomial_rng(N[a, t], p);
    }
  }
}



