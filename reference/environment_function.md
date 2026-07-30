# Calculates water and oxygen fluxes as affected by environmental conditions

Given values air temperature, oxygen-18 enrichment of surface waters,
and relative humidity, computes values for mean annual temperature
(MAT); water vapor in the lungs; water vapor in the atmosphere;
oxygen-18 enrichment of inhaled air (dairH2O), leaf water, and
cellulose; and the difference in oxygen-18 enrichment between air and
source water (dairH2OSW), oxygen in food and surface waters (dfoodO2SW),
water in food and surface waters (dfoodH2Osw). These calculations assume
that the oxygen-18 enrichment of stem water is equivalent to that of
surface waters.

## Usage

``` r
environment_function(
  air_temperature = numeric(0),
  relative_humidity = numeric(0),
  d18O_surface_water = numeric(0)
)
```

## Arguments

- air_temperature:

  Numeric. Air temperature ( deg C) of environment. Must be provided; 0
  and negative values are valid.

- relative_humidity:

  Numeric. Relative humidity of environment. Must be between 0 and 1.

- d18O_surface_water:

  Numeric. d18O values of local surface water (per mil VSMOW). Must be
  provided.

## Value

A data frame with all combinations of input values and 12 columns:

- airtemp - Air temperature ( deg C)

- MAT - Mean annual temperature ( deg K)

- Humidity - Relative humidity (proportion, 0-1)

- WVinLungs - Water vapor taken in lungs via respiration (mol)

- WV - Atmospheric water vapor (mol)

- d18Osw - d18O enrichment of surface water (per mil)

- dairH2O - d18O enirchment of inhaled air (per mil)

- dairH2OSW - Difference between air and surface water d18O enrichment
  (per mil)

- d18OleafH2O - d18O enrichment of leaf water (per mil)

- d18Oleafcellulose - d18O enrichment of leaf cellulose (per mil)

- dfoodO2SW - d18O enrichment of food oxygen relative to surface water
  (per mil)

- dfoodH2Osw - d18O enrichment of food water relative to surface water
  (per mil)

## Examples

``` r
# Example usage with vector inputs
environment_function(
  air_temperature = c(10, 20),
  relative_humidity = c(0.5, 0.75),
  d18O_surface_water = c(-2, -5)
)
#>   airtemp MAT Humidity WVinLungs       WV d18Osw   dairH2O  dairH2OSW
#> 1      10 283     0.50  3.291017 1.645508     -2 -12.46907 -10.469070
#> 2      20 293     0.50  6.128160 3.064080     -2 -11.57060  -9.570604
#> 3      10 283     0.50  3.291017 1.645508     -5 -15.46907 -10.469070
#> 4      20 293     0.50  6.128160 3.064080     -5 -14.57060  -9.570604
#> 5      10 283     0.75  4.936525 2.468262     -2 -12.46907 -10.469070
#> 6      20 293     0.75  9.192240 4.596120     -2 -11.57060  -9.570604
#> 7      10 283     0.75  4.936525 2.468262     -5 -15.46907 -10.469070
#> 8      20 293     0.75  9.192240 4.596120     -5 -14.57060  -9.570604
#>   d18OleafH2O d18Oleafcellulose dfoodO2SW dfoodH2Osw
#> 1   11.234535          38.23453  40.23453   6.617267
#> 2   10.785302          37.78530  39.78530   6.392651
#> 3    8.234535          35.23453  40.23453   6.617267
#> 4    7.785302          34.78530  39.78530   6.392651
#> 5    4.617267          31.61727  33.61727   3.308634
#> 6    4.392651          31.39265  33.39265   3.196325
#> 7    1.617267          28.61727  33.61727   3.308634
#> 8    1.392651          28.39265  33.39265   3.196325
```
