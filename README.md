# oxyproxy

<!-- badges: start -->
[![R-CMD-check](https://github.com/Katherine-Slenker/oxyproxy/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Katherine-Slenker/oxyproxy/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/Katherine-Slenker/oxyproxy/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/Katherine-Slenker/oxyproxy/actions/workflows/test-coverage.yaml)
[![pkgdown](https://github.com/Katherine-Slenker/oxyproxy/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/Katherine-Slenker/oxyproxy/actions/workflows/pkgdown.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

# OxyProxy

Predicts the oxygen-18 enrichment (δ¹⁸O) of an animal's **body water** and **tooth enamel** using an oxygen mass-balance model. The model tracks every oxygen input and output for an animal, scaled by species-specific traits and local environmental conditions.

OxyProxy can also run the model in reverse: given a measured δ¹⁸O of tooth enamel carbonate, it estimates the **relative humidity** the animal lived in.

## Overview

An animal's body water δ¹⁸O depends on where its oxygen comes from, where it goes, and how much each flux is fractionated along the way. OxyProxy sums those fluxes to give a steady-state body water value, then converts it to a predicted tooth enamel value.

The predictions can be used to:

- interpret δ¹⁸O measured in modern or fossil tooth enamel
- reconstruct past relative humidity from tooth enamel
- compare expected values across species with different physiologies
- explore how temperature, humidity, diet, and source water change animal δ¹⁸O

## Model components

### Oxygen inputs
| Flux | Description |
|------|-------------|
| Atmospheric O₂ | Inhaled oxygen used in respiration |
| Air water vapor | Water vapor taken in during breathing |
| Food (bound oxygen) | Oxygen in food carbohydrates, proteins, and lipids |
| Food (free water) | Water held in food (e.g., leaf water) |
| Drinking water | Surface water drunk directly |

### Oxygen outputs
| Flux | Description |
|------|-------------|
| Exhaled CO₂ | Oxygen lost as respiratory CO₂ |
| Urea | Oxygen lost in nitrogenous waste |
| Fecal water | Water lost in feces |
| Urine | Water lost in urine |
| Respiratory water vapor | Water lost through breathing |
| Transcutaneous water vapor | Water lost through the skin |
| Sweat | Water lost through sweating |

### Species-specific parameters
| Parameter | Description |
|-----------|-------------|
| Body mass | Scales metabolic rate and water turnover |
| Water economy index (WEI) | Water turnover relative to energy use; reflects how well an animal conserves water |
| Diet | Digestibility and carbohydrate, protein, fat, and free water content of food |
| Sweating | Whether the species loses water by sweating |

### Environmental parameters
| Parameter | Description |
|-----------|-------------|
| Air temperature | Affects fractionation factors and evaporative losses |
| δ¹⁸O of surface water | Isotopic value of local drinking water |
| Relative humidity | Controls the isotopic value of air water vapor and leaf water enrichment |

## Installation

OxyProxy is an R package. Install it from GitHub with the `remotes` package:

```r
# install.packages("remotes")
remotes::install_github("Katherine-Slenker/oxyproxy")
library(oxyproxy)
```

## Usage

OxyProxy has two main functions.

### 1. Predict body water and tooth enamel δ¹⁸O: `OxyProxy()`

Most arguments accept either a single value or a vector (for example, from `seq()`). Vectors let you model a range of conditions in one run.

```r
example <- OxyProxy(
  model_bodymass = 85,
  model_WaterEconomyIndex = seq(0.05, 0.3, 0.05),
  model_Digestibility_of_food = 0.624,
  model_Carbohydrate_Content = 0.72,
  model_Protein_Content = 0.15,
  model_Fat_Content = 0.13,
  model_Free_Water_Content_Food = seq(0.6, 0.7, 0.01),
  model_air_temperature = seq(0, 10, 1),
  model_Relative_Humidity = seq(0, 1, 0.1),
  model_d18O_surfacewater = -10,
  sweating_species = FALSE,
  PlotRange = TRUE,
  changeConstant = FALSE
)
```

### 2. Estimate relative humidity from tooth enamel: `RH_Estimation_OxyProxy()`

Give a measured δ¹⁸O of tooth enamel carbonate along with the animal and environmental parameters, and the function estimates relative humidity.

```r
example <- RH_Estimation_OxyProxy(
  sampled_d18Ocarbonate = 18.7,
  model_air_temperature = 6.7,
  model_d18O_Surfacewater = -14.7,
  model_Digestibility_of_food = 0.592,
  model_Carbohydrate_Content = 0.82,
  model_Protein_Content = 0.11,
  model_Fat_Content = 0.07,
  model_Free_Water_Content_Food = 0.5,
  model_Body_mass = 600,
  model_WaterEconomyIndex = seq(0.5, 0.55, 0.01),
  changeConstant = FALSE,
  sweating_species = FALSE
)
```

### Arguments

| Argument | Description |
|----------|-------------|
| `model_bodymass` / `model_Body_mass` | Body mass of the animal (kg) |
| `model_WaterEconomyIndex` | Water economy index |
| `model_Digestibility_of_food` | Fraction of food that is digestible (0–1) |
| `model_Carbohydrate_Content` | Fraction of digestible food that is carbohydrate (0–1) |
| `model_Protein_Content` | Fraction of digestible food that is protein (0–1) |
| `model_Fat_Content` | Fraction of digestible food that is fat (0–1) |
| `model_Free_Water_Content_Food` | Fraction of food mass that is free water (0–1) |
| `model_air_temperature` | Air temperature (°C) |
| `model_Relative_Humidity` | Relative humidity (0–1) |
| `model_d18O_surfacewater` / `model_d18O_Surfacewater` | δ¹⁸O of local surface water (‰ VSMOW) |
| `sampled_d18Ocarbonate` | Measured δ¹⁸O of tooth enamel carbonate |
| `sweating_species` | `TRUE` if the species sweats, `FALSE` if not |
| `PlotRange` | `TRUE` to plot the range of model results |
| `changeConstant` | `TRUE` to change the model's default constants |

Carbohydrate, protein, and fat content should add up to 1.

See each function's help page (`?OxyProxy`, `?RH_Estimation_OxyProxy`) for full details.

## Outputs

- **`OxyProxy()`**: predicted body water δ¹⁸O and tooth enamel δ¹⁸O for each combination of inputs, with an optional plot of the range
- **`RH_Estimation_OxyProxy()`**: estimated relative humidity that matches the measured tooth enamel value

## Assumptions and limitations

- Assumes body water is at isotopic steady state.
- Leaf water and food water enrichment are estimated from humidity and temperature, not measured directly.

## Background

This approach builds on established oxygen isotope mass-balance models for animals, including:

- Bryant, J. D. & Froelich, P. N. (1995). A model of oxygen isotope fractionation in body water of large mammals. *Geochimica et Cosmochimica Acta*, 59, 4523–4537.
- Kohn, M. J. (1996). Predicting animal δ¹⁸O: Accounting for diet and physiological adaptation. *Geochimica et Cosmochimica Acta*, 60, 4811–4829.

## Citation

If you use OxyProxy in your research, please cite:

```
Slenker, K., Gibert Bret, C., Clementz, M., Barley, R., Mattison, Q., & McGuire, J. (2026). OxyProxy: An oxygen isotope mass-balance model for animal body water and tooth enamel. GitHub repository. https://github.com/Katherine-Slenker/oxyproxy.
```

## License

This package is released under the MIT License. See LICENSE for details

## Contact

Katherine Slenker, via [GitHub](https://github.com/Katherine-Slenker)
