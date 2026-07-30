# Calculates water and oxygen fluxes as affected by environmental conditions.

Given values air temperature and oxygen-18 enrichment of surface waters,
and computes values for mean annual temperature (MAT), oxygen-18
enrichment of inhaled air (dairH2O), and the difference in oxygen-18
enrichment between air and source water (dairH2OSW).

## Usage

``` r
rh_estimation_environment_function(
  air_temperature = numeric(0),
  d18O_surface_water = numeric(0)
)
```

## Arguments

- air_temperature:

  Numeric. Air temperature ( deg C) of environment. Must be provided; 0
  and negative values are valid.

- d18O_surface_water:

  Numeric. d18O values of local surface water (per mil VSMOW). Must be
  provided; 0 and negative values are valid.

## Value

A data frame with all combinations of input values and 5 columns:

- airtemp - Air temperature ( deg C)

- MAT - Mean annual temperature ( deg K)

- d18Osw - d18O enrichment of surface water (per mil)

- dairH2O - d18O enirchment of inhaled air (per mil)

- dairH2OSW - Difference between air and surface water d18O enrichment
  (per mil)

## Examples

``` r
# Example usage with vector inputs
rh_estimation_environment_function(
  air_temperature = c(10, 20),
  d18O_surface_water = c(-2, -5)
)
#>   airtemp MAT d18Osw   dairH2O  dairH2OSW
#> 1      10 283     -2 -12.46907 -10.469070
#> 2      20 293     -2 -11.57060  -9.570604
#> 3      10 283     -5 -15.46907 -10.469070
#> 4      20 293     -5 -14.57060  -9.570604
```
