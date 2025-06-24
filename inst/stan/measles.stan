//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data.
data {
  int<lower=0> S;
  vector[S] t;
  vector[S] age;
  vector[S] V;
  vector[S] N;
  vector[S] P;
}

// The parameters accepted by the model.
parameters {
  real lambda;
}

// The model to be estimated.
model {
  // TODO
}

