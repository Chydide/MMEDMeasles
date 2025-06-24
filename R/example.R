data <- data.frame (
  age = c(1, 2, 3),
  vaccine_status = c(20, 10, 30),
  sample_size = c(100, 100, 100),
  population_size = c(200, 200, 200)
)
measles_stan(data)