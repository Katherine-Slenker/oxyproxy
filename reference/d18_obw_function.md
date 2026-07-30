# Calculate estimate of oxygen-18 enrichment of animal bodywater based on flux of oxygen input and outputs.

This function combines the Species, Inputs, and Outputs functions to
generate estimates of oxygen-18 enrichment of animal bodywater,
enamel-phosphate, and enamel-carbonate.

## Usage

``` r
d18_obw_function(outputs = 0)
```

## Arguments

- outputs:

  Data frame of oxygen output data, as returned by
  [`outputs_function()`](https://katherine-slenker.github.io/oxyproxy/reference/outputs_function.md).
  Must carry the columns listed below.

  MolesO2Air

  :   Numeric. Moles of oxygen from air

  d18Oairtakenup

  :   Numeric.

  WV

  :   Numeric. Water vapor in the atmosphere.

  dairH2OSW

  :   Numeric.

  dfoodO2SW

  :   Numeric.

  dryOinflux

  :   Numeric. Dry oxygen influx

  dfoodH2Osw

  :   Numeric.

  WaterinFood

  :   Numeric.

  DrinkingWater

  :   Numeric.

  WVCO2

  :   Numeric.

  WVNose

  :   Numeric.

  WVMouth

  :   Numeric.

  WVSkin

  :   Numeric.

  WVSweat

  :   Numeric.

  WVUrine

  :   Numeric.

  WVFecal

  :   Numeric.

  Urea

  :   Numeric.

  d18Osw

  :   Numeric.

## Value

Data frame with estimated d18Obw, d18Oenamel-phosphate, and
d18Oenamel-carbonate.

## Examples

``` r
# One row of oxygen fluxes, as outputs_function() would return
herbivore_data <- data.frame(
  MolesO2Air = 0.42, d18Oairtakenup = 12, WV = 3, dairH2OSW = 2,
  dfoodO2SW = 10, dryOinflux = 0.08, dfoodH2Osw = 5, WaterinFood = 1,
  DrinkingWater = 2, WVCO2 = 0.1, WVNose = 0.3, WVMouth = 0.5,
  WVSkin = 1.5, WVSweat = 0, WVUrine = 1.6, WVFecal = 0.4,
  Urea = 0.2, d18Osw = -8
)

d18_obw_function(outputs = herbivore_data)
#>      d18Obw d18Ophos d18Ocarb
#> 1 0.1173913  17.5699  26.0699
#>   MolesO2Air d18Oairtakenup WV dairH2OSW dfoodO2SW dryOinflux dfoodH2Osw
#> 1       0.42             12  3         2        10       0.08          5
#>   WaterinFood DrinkingWater WVCO2 WVNose WVMouth WVSkin WVSweat WVUrine WVFecal
#> 1           1             2   0.1    0.3     0.5    1.5       0     1.6     0.4
#>   Urea d18Osw    d18Obw d18Ophos d18Ocarb
#> 1  0.2     -8 0.1173913  17.5699  26.0699
```
