# Calculates all variables of oxygen input from physiology and diet.

This function combines the Species, Food, and Inputs functions to
calculate oxygen outputs such as dry fecal mass, water loss from feces,
water vapor losses through feces,sweat, respiration (CO2), and panting,
and losses through metabolic functions, like urea production.

## Usage

``` r
outputs_function(inputs = 0, sweating_species = FALSE)
```

## Arguments

- inputs:

  A data frame containing the following required columns:

  FoodMassIngested

  :   Numeric. Mass of food consumed (kg)

  Digestibility

  :   Numeric. Fraction of food digested (0-1)

  TotalH2OTurnover

  :   Numeric. Total daily water turnover (moles H2O)

  H2OOral

  :   Numeric. Oral water loss (moles H2O)

  H2ONasal

  :   Numeric. Nasal water loss (moles H2O)

  TranscutaneousH2OLoss

  :   Numeric. Transcutaneous water loss (kg/((m^2)\*h)

  UrinaryH2OLoss

  :   Numeric. Urinary water loss (moles H2O)

  Oprotein

  :   Numeric. Oxygen consumption for protein metabolism

  foodproteincontent

  :   Numeric. Protein content of food (0-1)

  EEE

  :   Numeric. Energy extraction efficiency (0-1)

  MolesO2Air

  :   Numeric. Moles of oxygen from air (moles)

  dryHinflux

  :   Numeric. Dry hydrogen influx (moles H2)

  dryOinflux

  :   Numeric. Dry oxygen influx (moles O2)

- sweating_species:

  Logical. Indicates whether the species is capable of sweating. If
  TRUE, water vapor loss from sweating is calculated as 75% of water
  heat loss. If FALSE (default), sweating water vapor loss is set to
  zero.

## Value

A data frame containing all original input columns plus the following
calculated output columns:

- DryFecalOutput:

  Numeric. Dry mass of fecal output (kg)

- FecalH20Loss:

  Numeric. Water loss through feces (moles H2O)

- WVFecal:

  Numeric. Water vapor from fecal loss (moles H2O)

- WaterHeatLoss:

  Numeric. Water used for thermoregulation (moles H2O)

- Sweating:

  Numeric. Water loss through sweat (moles H2O)

- WVSweat:

  Numeric. Water vapor from sweating (moles H2O, species-dependent)

- Panting:

  Numeric. Water loss through panting (moles H2O)

- WVMouth:

  Numeric. Water vapor from oral routes (moles H2O)

- UreaProduced:

  Numeric. Urea production from protein metabolism

- WVCO2:

  Numeric. Water vapor associated with CO2 exchange

## Details

The function performs calculations in a specific sequence to handle
dependencies:

1.  Calculates dry fecal output based on food intake and digestibility

2.  Computes fecal water loss using standard conversion factors

3.  Determines water available for heat loss by subtracting all other
    losses

4.  Calculates sweating-related outputs (species-dependent)

5.  Computes respiratory water losses

6.  Determines metabolic outputs including urea production

## Note

All water-related inputs and outputs should use consistent units
(typically moles H2O). Digestibility and efficiency values should be
between 0 and 1. For non-sweating species, set sweating_species = FALSE
(default).

## Examples

``` r
# Example for a small mammal
mouse_data <- data.frame(
  FoodMassIngested = 5.2,
  Digestibility = 0.85,
  TotalH2OTurnover = 8.5,
  H2OOral = 1.2,
  H2ONasal = 0.8,
  TranscutaneousH2OLoss = 2.1,
  UrinaryH2OLoss = 3.2,
  Oprotein = 0.12,
  foodproteincontent = 0.18,
  EEE = 0.88,
  MolesO2Air = 0.42,
  dryHinflux = 0.15,
  dryOinflux = 0.08
)

# Calculate outputs for non-sweating species (default)
mouse_outputs <- outputs_function(mouse_data)
#> Using non-sweating species model (WVSweat = 0)

# Calculate outputs for a sweating species
sweating_outputs <- outputs_function(mouse_data, sweating_species = TRUE)

# Multiple animals
multi_animal_data <- data.frame(
  FoodMassIngested = c(100, 150, 200),
  Digestibility = c(0.8, 0.75, 0.85),
  TotalH2OTurnover = c(1000, 1200, 1400),
  H2OOral = c(50, 60, 70),
  H2ONasal = c(20, 25, 30),
  TranscutaneousH2OLoss = c(80, 90, 100),
  UrinaryH2OLoss = c(150, 180, 200),
  Oprotein = c(0.1, 0.12, 0.08),
  foodproteincontent = c(0.2, 0.18, 0.22),
  EEE = c(0.9, 0.85, 0.92),
  MolesO2Air = c(10, 12, 8),
  dryHinflux = c(4, 5, 3),
  dryOinflux = c(2, 2.5, 1.5)
)
multi_outputs <- outputs_function(multi_animal_data, sweating_species = FALSE)
#> Using non-sweating species model (WVSweat = 0)
```
