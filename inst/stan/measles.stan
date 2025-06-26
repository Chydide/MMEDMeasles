data {
  int<lower=0> n_observations;
  array[n_observations] int total_population;
  array[n_observations] int vaccinated;
  int<lower=0, upper=1> run_estimation;
}

parameters {
  vector<lower=0, upper=1>[n_observations] force_of_vaccination;
}

model {
  force_of_vaccination ~ normal(1, 1);

  if (run_estimation == 1) {
    int population_left = total_population[1];
    for (i in 1:n_observations) {
      vaccinated[i] ~ binomial(population_left, 1 - exp(-force_of_vaccination[i]));
      population_left = population_left - vaccinated[i];
    }
  }
}

generated quantities {
  array[n_observations] int vaccinated_sim;
  int population_left = total_population[1];

  for (i in 1:n_observations) {
    vaccinated_sim[i] = binomial_rng(population_left, 1 - exp(-force_of_vaccination[i]));
    population_left = population_left - vaccinated_sim[i];
  }
}



