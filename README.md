# MMEDMeasles

R package for a Stan model to model measles. 
Originally created for the [MMED](https://www.ici3d.org/MMED/schedule/) 2025 workshop.

## Installation

1. Install the `devtools` R package:
```
install.packages("devtools")
```
2. Import the `devtools` package:
```
use("devtools")
```
3. Install this package:
```
install_github("Chydide/MMEDMeasles")
```

## Contributing

1. Install the following R packages using `install.packages("<package name>")`:
    - `rstan`,
    - `devtools`.
2. Make changes.
3. Run `use('devtools')`.
4. Run `load_all()` and test your changes.
5. `install.packages("../MMEDMeasles", repos = NULL, type = "source")`
6. [Document](https://r-pkgs.org/man.html) your changes.
7. Run `devtools::document()` to update the Roxygen documentation.
