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
3. Run `pkgbuild::compile_dll()`.
4. Run `use('devtools')`.
5. Run `load_all()` and test your changes.
6. `install.packages("../MMEDMeasles", repos = NULL, type = "source")`
7. [Document](https://r-pkgs.org/man.html) your changes.
8. Run `devtools::document()` to update the Roxygen documentation.
9. If a Stan model isn't being reloaded, try `rm src/MMEDMeasles.so src/RcppExports.o src/stanExports_lm.o` and then rerunning the commands above.


## 🧪 Compartments
| Compartment| Description|
|------------|------------|
|S	         | Susceptible      |
|I	         |Infectious        |
|R	         |Recovered (immune)|
|V1	         |Vaccinated with 1st dose|
|V2	         |Vaccinated with 2nd dose|
|VSIA	       |Received SIA (Supplementary Immunization Activity)|



## 🦠 SIR Model with Routine + SIA Vaccination

        +-----------+
        |           |
        |    S      |
        | (Suscept.)|
        |           |
        +-----------+
         |   |   |
         |   |   |
         |   |   +-------------------------+
         |   |                             |
         |   v                             v
         |  V1                            VSIA
         | (1st dose)             (SIA: from S directly)
         |   |   \                             ^
         |   |    \                            |
         v   v     \                           |
         I   V2      --> VSIA                  |
     (Infectious) (2nd dose)        <---------+
         |    |                               |
         v    +----------------------------> VSIA
         R                                  (SIA: from V1 & V2)
   (Recovered)

Transitions:
S  → I      : Infection  
S  → V1     : Routine 1st dose  
S  → VSIA   : SIA from susceptible  
I  → R      : Recovery  
V1 → V2     : Routine 2nd dose  
V1 → VSIA   : SIA reaches V1  
V2 → VSIA   : SIA reaches V2



## 📘 Step-by-Step: Model Equations
Let’s define:

β: transmission rate

γ: recovery rate

v1: 1st dose routine vaccination rate

v2: 2nd dose routine vaccination rate

s_sia: SIA rate targeting S

v1_sia: SIA rate targeting V1

v2_sia: SIA rate targeting V2

Let N = S + I + R + V1 + V2 + VSIA be the total population.


## 🧮 ODE System

dS     = -β * S * I / N - v1 * S - s_sia * S

dI     =  β * S * I / N - γ * I

dR     =  γ * I

dV1    =  v1 * S - v2 * V1 - v1_sia * V1

dV2    =  v2 * V1 - v2_sia * V2

dVSIA  =  s_sia * S + v1_sia * V1 + v2_sia * V2
