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
  array[n_cohorts, n_observations] int age;
  array[n_cohorts, n_observations] int vaccine_status;
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
  array[n_observations, n_cohorts] int delta_p_plus;
  array[n_observations, n_cohorts] int p_plus;
  array[n_observations, n_cohorts] int v_plus;
  
  for (c in 1:n_cohorts) {
    delta_p_plus[1][c] ~ binomial(population_size[1][c], 1 - exp(-lambda[c]));
    v_plus[1][c] ~ hypergeometric(sample_size[1][c], vaccine_status[1][c], population_size[1][c] - vaccine_status[1][c]);
  }
  
  for (t in 2:n_observations) {
    for (c in 1:n_cohorts) {
      delta_p_plus[t][c] ~ binomial(population_size[t-1][c] - delta_p_plus[t-1][c], 1 - exp(-lambda[c]));
      v_plus[t][c] ~ hypergeometric(sample_size[t][c], vaccine_status[t-1][c] + delta_p_plus[t][c], population_size[t][c] - vaccine_status[t][c]);
    }
  }
 
}

