# Package index

## d18O body water model

Estimate oxygen-18 enrichment of animal body water from oxygen inputs
and outputs.

- [`species_function()`](https://katherine-slenker.github.io/oxyproxy/reference/species_function.md)
  : Calculates water and oxygen fluxes as affected by species
  physiology.
- [`food_function()`](https://katherine-slenker.github.io/oxyproxy/reference/food_function.md)
  : Calculates water and oxygen fluxes as affected by species diet
- [`environment_function()`](https://katherine-slenker.github.io/oxyproxy/reference/environment_function.md)
  : Calculates water and oxygen fluxes as affected by environmental
  conditions
- [`input_function()`](https://katherine-slenker.github.io/oxyproxy/reference/input_function.md)
  : Calculates all variables of oxygen input from physiology, diet, and
  environment.
- [`outputs_function()`](https://katherine-slenker.github.io/oxyproxy/reference/outputs_function.md)
  : Calculates all variables of oxygen input from physiology and diet.
- [`d18_obw_function()`](https://katherine-slenker.github.io/oxyproxy/reference/d18_obw_function.md)
  : Calculate estimate of oxygen-18 enrichment of animal bodywater based
  on flux of oxygen input and outputs.
- [`oxy_proxy_function()`](https://katherine-slenker.github.io/oxyproxy/reference/oxy_proxy_function.md)
  : Plots estimates of oxygen-18 enrichment of animal bodywater based on
  flux of oxygen input and outputs against variables input by user.

## Relative humidity estimation

Invert the model to estimate relative humidity from a measured d18O
enamel carbonate value.

- [`d18O_enamel()`](https://katherine-slenker.github.io/oxyproxy/reference/d18O_enamel.md)
  : Convert values of oxygen-18 enrichment found within samples of the
  carbonate (CO3) component of animal tooth enamel to analogous values
  representing isotopic enrichment of animal body water.
- [`rh_estimation_environment_function()`](https://katherine-slenker.github.io/oxyproxy/reference/rh_estimation_environment_function.md)
  : Calculates water and oxygen fluxes as affected by environmental
  conditions.
- [`inverse_input_function()`](https://katherine-slenker.github.io/oxyproxy/reference/inverse_input_function.md)
  : Calculate all variables of oxygen input from physiology, diet, and
  environment.
- [`rh_function()`](https://katherine-slenker.github.io/oxyproxy/reference/rh_function.md)
  : Calculates estimates of relative humidity and variables that are
  dependent on values of relative humidity that are needed to calculate
  oxygen-18 enrichment of animal body water.
- [`humidity_oxy_proxy()`](https://katherine-slenker.github.io/oxyproxy/reference/humidity_oxy_proxy.md)
  : Plots estimated values of relative humidity converted from
  measurements of d18Oenamel-carbonate.
