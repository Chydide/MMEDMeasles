//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data.
data {
  int<lower=0> n_cohorts;
  int<lower=0> n_observations;
  matrix[n_cohorts, n_observations] t; # time
  matrix[n_cohorts, n_observations] age;
  matrix[n_cohorts, n_observations] vaccine_status;
  array[n_cohorts, n_observations] int sample_size;
  array[n_cohorts, n_observations] int population_size;
}

// The parameters accepted by the model.
parameters {
  vector[n_cohorts-1] lambda;
  vector[n_cohorts-1] alpha;
  vector[n_cohorts-1] beta;
}

// The model to be estimated.
model {
  array[n_observations, n_cohorts] int prevalence;
  
  for (c in 2:n_cohorts) {
    prevalence[1][c] ~ beta(alpha[c], beta[c]);
    prevalence[2][c] = prevalence[1][c] + (1-prevalence[1][c]) * (1-exp(-lambda[c]));
    
    vaccine_status[1][c] ~ binomial(sample_size[1][c], prevalence[1][c]);
    vaccine_status[2][c] ~ binomial(sample_size[2][c], prevalence[2][c]);
  }
 
}

