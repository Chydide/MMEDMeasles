// The input data.
data {
  int<lower=0> n_observations;
  int<lower=0> total_population; # P for short
  array[n_observations] int vaccinated;
  
  int<lower = 0, upper = 1> run_estimation; // a switch to evaluate the likelihood
}

// The parameters accepted by the model.
parameters {
  vector[n_observations] force_of_vaccination;
}

// The model to be estimated.
model {
  int population_left = total_population;
  
  if(run_estimation==1) {
    for (i in 1:n_observations) {
      vaccinated[i] ~ binomial(population_left, 1 - exp(-force_of_vaccination[i]));
      population_left = population_left - vaccinated[i]; 
    }
  }
}

generated quantities {
  array[n_observations] int vaccinated_sim;
  int population_left = total_population;
  
  for (i in 1:n_observations) {
    vaccinated_sim[i] = binomial_rng(population_left, 1 - exp(-force_of_vaccination[i]));
    population_left = population_left - vaccinated[i]; 
  }
}
