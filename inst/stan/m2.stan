data {
  int<lower=0> n_observations;
  array[n_observations] int total_population;
  array[n_observations] int vaccinated;
  int<lower = 0, upper = 1> run_estimation;
}

parameters {
  vector<lower=0, upper =1>[n_observations] vaccine_coverage;
}

transformed parameters {
  vector[n_observations] force_of_vaccination;
  force_of_vaccination = -log(1-vaccine_coverage);
}

model {
  vaccine_coverage ~ beta(1, 1);
  vaccinated ~ binomial(total_population, vaccine_coverage);
}


