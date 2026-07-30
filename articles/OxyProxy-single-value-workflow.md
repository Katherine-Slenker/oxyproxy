# OxyProxy: Single-Value Workflow

## Overview

This vignette demonstrates a **single-run** workflow for predicting
oxygen isotope ratios (δ18O) using oxyproxy, both step by step through
the individual pipeline functions and via the
[`oxy_proxy_function()`](https://katherine-slenker.github.io/oxyproxy/reference/oxy_proxy_function.md)
wrapper.

## Load the package

``` r

library(oxyproxy)

# If you're developing locally and not installed:
# devtools::load_all()
```

## Step 1 — Species physiology (single value)

[`species_function()`](https://katherine-slenker.github.io/oxyproxy/reference/species_function.md)
expects `body_mass` and `water_economy_index` (plus optional
`changeConstant`).

``` r

species_out <- species_function(
  body_mass = 70, # kg
  water_economy_index = 0.40, # typical range ~0.05-0.6
  changeConstant = FALSE
)

str(species_out)
#> 'data.frame':    1 obs. of  15 variables:
#>  $ Bodymass             : num 70
#>  $ EnergyExp            : num 20006
#>  $ WEI                  : num 0.4
#>  $ TranscutaneousH2OLoss: num 24.5
#>  $ WVSkin               : num 12.2
#>  $ MolesO2Air           : num 43.2
#>  $ O2FluxLungs          : num 23047
#>  $ H2OOral              : num 34.6
#>  $ H2ONasal             : num 17.3
#>  $ WVNose               : num 8.64
#>  $ TotalH2OTurnover     : num 445
#>  $ UrinaryH2OLoss       : num 111
#>  $ WVUrine              : num 55.6
#>  $ Urea                 : num 0.2
#>  $ d18Oairtakenup       : num 14.8
```

## Step 2 — Diet composition (single value)

[`food_function()`](https://katherine-slenker.github.io/oxyproxy/reference/food_function.md)
expects: `digestibility_of_food`, `Carbohydrate_Content`,
`Protein_Content`, `Fat_Content`, and `Free_Water_Content_Food`.

``` r

food_out <- food_function(
  digestibility_of_food = 0.8,
  Carbohydrate_Content = 0.5,
  Protein_Content = 0.2,
  Fat_Content = 0.3, # NOTE: must sum with carb+protein to 1.0
  Free_Water_Content_Food = 0.7,
  changeConstant = FALSE
)

str(food_out)
#> 'data.frame':    1 obs. of  15 variables:
#>  $ Digestibility     : num 0.8
#>  $ EEE               : num 0.9
#>  $ foodcarbenergy    : num 17300
#>  $ foodcarbcontent   : num 0.5
#>  $ Ocarb             : num 15.4
#>  $ Hcarb             : num 30.9
#>  $ foodproteinenergy : num 20100
#>  $ Oprotein          : num 3
#>  $ Hprotein          : num 11
#>  $ foodfatenergy     : num 39700
#>  $ Ofat              : num 2
#>  $ Hfat              : num 60
#>  $ foodproteincontent: num 0.2
#>  $ foodfatcontent    : num 0.3
#>  $ freeH20food       : num 0.7
```

## Step 3 — Environment (single value)

[`environment_function()`](https://katherine-slenker.github.io/oxyproxy/reference/environment_function.md)
expects `air_temperature`, `relative_humidity`, and
`d18O_surface_water`.

``` r

env_out <- environment_function(
  air_temperature = 20, # Celsius
  relative_humidity = 0.60, # proportion in (0, 1]
  d18O_surface_water = -5 # per mil (‰ VSMOW)
)

env_out
#>   airtemp MAT Humidity WVinLungs       WV d18Osw  dairH2O dairH2OSW d18OleafH2O
#> 1      20 293      0.6  7.353792 3.676896     -5 -14.5706 -9.570604    5.228241
#>   d18Oleafcellulose dfoodO2SW dfoodH2Osw
#> 1          32.22824  37.22824   5.114121
```

## Step 4 — Inputs -\> Outputs -\> d18O body water

### 4A) Oxygen inputs

[`input_function()`](https://katherine-slenker.github.io/oxyproxy/reference/input_function.md)
combines species, food, and environment into oxygen input variables:

``` r

inputs_out <- input_function(
  species = species_out,
  food = food_out,
  environment = env_out
)

str(inputs_out)
#> 'data.frame':    1 obs. of  49 variables:
#>  $ Bodymass             : num 70
#>  $ EnergyExp            : num 20006
#>  $ WEI                  : num 0.4
#>  $ TranscutaneousH2OLoss: num 24.5
#>  $ WVSkin               : num 12.2
#>  $ MolesO2Air           : num 43.2
#>  $ O2FluxLungs          : num 23047
#>  $ H2OOral              : num 34.6
#>  $ H2ONasal             : num 17.3
#>  $ WVNose               : num 8.64
#>  $ TotalH2OTurnover     : num 445
#>  $ UrinaryH2OLoss       : num 111
#>  $ WVUrine              : num 55.6
#>  $ Urea                 : num 0.2
#>  $ d18Oairtakenup       : num 14.8
#>  $ Digestibility        : num 0.8
#>  $ EEE                  : num 0.9
#>  $ foodcarbenergy       : num 17300
#>  $ foodcarbcontent      : num 0.5
#>  $ Ocarb                : num 15.4
#>  $ Hcarb                : num 30.9
#>  $ foodproteinenergy    : num 20100
#>  $ Oprotein             : num 3
#>  $ Hprotein             : num 11
#>  $ foodfatenergy        : num 39700
#>  $ Ofat                 : num 2
#>  $ Hfat                 : num 60
#>  $ foodproteincontent   : num 0.2
#>  $ foodfatcontent       : num 0.3
#>  $ freeH20food          : num 0.7
#>  $ airtemp              : num 20
#>  $ MAT                  : num 293
#>  $ Humidity             : num 0.6
#>  $ WVinLungs            : num 7.35
#>  $ WV                   : num 3.68
#>  $ d18Osw               : num -5
#>  $ dairH2O              : num -14.6
#>  $ dairH2OSW            : num -9.57
#>  $ d18OleafH2O          : num 5.23
#>  $ d18Oleafcellulose    : num 32.2
#>  $ dfoodO2SW            : num 37.2
#>  $ dfoodH2Osw           : num 5.11
#>  $ FoodMassIngested     : num 1.13
#>  $ dryOinflux           : num 7.24
#>  $ dryHinflux           : num 29
#>  $ FreeH2Oinfood        : num 147
#>  $ WaterinFood          : num 73.3
#>  $ DrinkingH2OIngested  : num 262
#>  $ DrinkingWater        : num 131
```

### 4B) Oxygen outputs

[`outputs_function()`](https://katherine-slenker.github.io/oxyproxy/reference/outputs_function.md)
computes the oxygen output variables:

``` r

outputs_out <- outputs_function(
  inputs = inputs_out,
  sweating_species = FALSE
)

str(outputs_out)
#> 'data.frame':    1 obs. of  59 variables:
#>  $ Bodymass             : num 70
#>  $ EnergyExp            : num 20006
#>  $ WEI                  : num 0.4
#>  $ TranscutaneousH2OLoss: num 24.5
#>  $ WVSkin               : num 12.2
#>  $ MolesO2Air           : num 43.2
#>  $ O2FluxLungs          : num 23047
#>  $ H2OOral              : num 34.6
#>  $ H2ONasal             : num 17.3
#>  $ WVNose               : num 8.64
#>  $ TotalH2OTurnover     : num 445
#>  $ UrinaryH2OLoss       : num 111
#>  $ WVUrine              : num 55.6
#>  $ Urea                 : num 0.2
#>  $ d18Oairtakenup       : num 14.8
#>  $ Digestibility        : num 0.8
#>  $ EEE                  : num 0.9
#>  $ foodcarbenergy       : num 17300
#>  $ foodcarbcontent      : num 0.5
#>  $ Ocarb                : num 15.4
#>  $ Hcarb                : num 30.9
#>  $ foodproteinenergy    : num 20100
#>  $ Oprotein             : num 3
#>  $ Hprotein             : num 11
#>  $ foodfatenergy        : num 39700
#>  $ Ofat                 : num 2
#>  $ Hfat                 : num 60
#>  $ foodproteincontent   : num 0.2
#>  $ foodfatcontent       : num 0.3
#>  $ freeH20food          : num 0.7
#>  $ airtemp              : num 20
#>  $ MAT                  : num 293
#>  $ Humidity             : num 0.6
#>  $ WVinLungs            : num 7.35
#>  $ WV                   : num 3.68
#>  $ d18Osw               : num -5
#>  $ dairH2O              : num -14.6
#>  $ dairH2OSW            : num -9.57
#>  $ d18OleafH2O          : num 5.23
#>  $ d18Oleafcellulose    : num 32.2
#>  $ dfoodO2SW            : num 37.2
#>  $ dfoodH2Osw           : num 5.11
#>  $ FoodMassIngested     : num 1.13
#>  $ dryOinflux           : num 7.24
#>  $ dryHinflux           : num 29
#>  $ FreeH2Oinfood        : num 147
#>  $ WaterinFood          : num 73.3
#>  $ DrinkingH2OIngested  : num 262
#>  $ DrinkingWater        : num 131
#>  $ DryFecalOutput       : num 0.226
#>  $ FecalH20Loss         : num 18.8
#>  $ WVFecal              : num 9.42
#>  $ WaterHeatLoss        : num 238
#>  $ Sweating             : num 179
#>  $ WVSweat              : num 0
#>  $ Panting              : num 119
#>  $ WVMouth              : num 76.8
#>  $ UreaProduced         : num 0.488
#>  $ WVCO2                : num 35.5
```

### 4C) Final isotope estimates

[`d18_obw_function()`](https://katherine-slenker.github.io/oxyproxy/reference/d18_obw_function.md)
computes the final body water, phosphate, and carbonate isotope
estimates:

``` r

d18o_out <- d18_obw_function(outputs = outputs_out)
#>       d18Obw d18Ophos d18Ocarb
#> 1 -0.9961596 16.45635 24.95635

head(d18o_out[, c("d18Obw", "d18Ophos", "d18Ocarb")])
#>       d18Obw d18Ophos d18Ocarb
#> 1 -0.9961596 16.45635 24.95635
```

## Alternative — Call the wrapper `oxy_proxy_function()`

[`oxy_proxy_function()`](https://katherine-slenker.github.io/oxyproxy/reference/oxy_proxy_function.md)
runs the full pipeline in one call. It does **not** accept `species=`,
`food=`, `environment=`; instead it accepts a set of `model_*` scalar
inputs:

``` r

oxyproxy_out <- oxy_proxy_function(
  model_bodymass = 70,
  model_WaterEconomyIndex = 0.40,
  model_Digestibility_of_food = 0.8,
  model_Carbohydrate_Content = 0.5,
  model_Protein_Content = 0.2,
  model_Fat_Content = 0.3,
  model_Free_Water_Content_Food = 0.7,
  model_air_temperature = 20,
  model_Relative_Humidity = 0.60,
  model_d18O_surfacewater = -5,
  changeConstant = FALSE,
  sweating_species = FALSE,
  PlotRange = FALSE # avoid plots in vignette by default
)
#>       d18Obw d18Ophos d18Ocarb
#> 1 -0.9961596 16.45635 24.95635

head(oxyproxy_out[, c("d18Obw", "d18Ophos", "d18Ocarb")])
#>       d18Obw d18Ophos d18Ocarb
#> 1 -0.9961596 16.45635 24.95635
```

## Inspecting results

``` r

names(d18o_out)
#>  [1] "Bodymass"              "EnergyExp"             "WEI"                  
#>  [4] "TranscutaneousH2OLoss" "WVSkin"                "MolesO2Air"           
#>  [7] "O2FluxLungs"           "H2OOral"               "H2ONasal"             
#> [10] "WVNose"                "TotalH2OTurnover"      "UrinaryH2OLoss"       
#> [13] "WVUrine"               "Urea"                  "d18Oairtakenup"       
#> [16] "Digestibility"         "EEE"                   "foodcarbenergy"       
#> [19] "foodcarbcontent"       "Ocarb"                 "Hcarb"                
#> [22] "foodproteinenergy"     "Oprotein"              "Hprotein"             
#> [25] "foodfatenergy"         "Ofat"                  "Hfat"                 
#> [28] "foodproteincontent"    "foodfatcontent"        "freeH20food"          
#> [31] "airtemp"               "MAT"                   "Humidity"             
#> [34] "WVinLungs"             "WV"                    "d18Osw"               
#> [37] "dairH2O"               "dairH2OSW"             "d18OleafH2O"          
#> [40] "d18Oleafcellulose"     "dfoodO2SW"             "dfoodH2Osw"           
#> [43] "FoodMassIngested"      "dryOinflux"            "dryHinflux"           
#> [46] "FreeH2Oinfood"         "WaterinFood"           "DrinkingH2OIngested"  
#> [49] "DrinkingWater"         "DryFecalOutput"        "FecalH20Loss"         
#> [52] "WVFecal"               "WaterHeatLoss"         "Sweating"             
#> [55] "WVSweat"               "Panting"               "WVMouth"              
#> [58] "UreaProduced"          "WVCO2"                 "d18Obw"               
#> [61] "d18Ophos"              "d18Ocarb"
str(d18o_out, max.level = 1)
#> 'data.frame':    1 obs. of  62 variables:
#>  $ Bodymass             : num 70
#>  $ EnergyExp            : num 20006
#>  $ WEI                  : num 0.4
#>  $ TranscutaneousH2OLoss: num 24.5
#>  $ WVSkin               : num 12.2
#>  $ MolesO2Air           : num 43.2
#>  $ O2FluxLungs          : num 23047
#>  $ H2OOral              : num 34.6
#>  $ H2ONasal             : num 17.3
#>  $ WVNose               : num 8.64
#>  $ TotalH2OTurnover     : num 445
#>  $ UrinaryH2OLoss       : num 111
#>  $ WVUrine              : num 55.6
#>  $ Urea                 : num 0.2
#>  $ d18Oairtakenup       : num 14.8
#>  $ Digestibility        : num 0.8
#>  $ EEE                  : num 0.9
#>  $ foodcarbenergy       : num 17300
#>  $ foodcarbcontent      : num 0.5
#>  $ Ocarb                : num 15.4
#>  $ Hcarb                : num 30.9
#>  $ foodproteinenergy    : num 20100
#>  $ Oprotein             : num 3
#>  $ Hprotein             : num 11
#>  $ foodfatenergy        : num 39700
#>  $ Ofat                 : num 2
#>  $ Hfat                 : num 60
#>  $ foodproteincontent   : num 0.2
#>  $ foodfatcontent       : num 0.3
#>  $ freeH20food          : num 0.7
#>  $ airtemp              : num 20
#>  $ MAT                  : num 293
#>  $ Humidity             : num 0.6
#>  $ WVinLungs            : num 7.35
#>  $ WV                   : num 3.68
#>  $ d18Osw               : num -5
#>  $ dairH2O              : num -14.6
#>  $ dairH2OSW            : num -9.57
#>  $ d18OleafH2O          : num 5.23
#>  $ d18Oleafcellulose    : num 32.2
#>  $ dfoodO2SW            : num 37.2
#>  $ dfoodH2Osw           : num 5.11
#>  $ FoodMassIngested     : num 1.13
#>  $ dryOinflux           : num 7.24
#>  $ dryHinflux           : num 29
#>  $ FreeH2Oinfood        : num 147
#>  $ WaterinFood          : num 73.3
#>  $ DrinkingH2OIngested  : num 262
#>  $ DrinkingWater        : num 131
#>  $ DryFecalOutput       : num 0.226
#>  $ FecalH20Loss         : num 18.8
#>  $ WVFecal              : num 9.42
#>  $ WaterHeatLoss        : num 238
#>  $ Sweating             : num 179
#>  $ WVSweat              : num 0
#>  $ Panting              : num 119
#>  $ WVMouth              : num 76.8
#>  $ UreaProduced         : num 0.488
#>  $ WVCO2                : num 35.5
#>  $ d18Obw               : num -0.996
#>  $ d18Ophos             : num 16.5
#>  $ d18Ocarb             : num 25
```

## Session info

``` r

sessionInfo()
#> R version 4.6.1 (2026-06-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] oxyproxy_0.1.0
#> 
#> loaded via a namespace (and not attached):
#>  [1] digest_0.6.39     desc_1.4.3        R6_2.6.1          fastmap_1.2.0    
#>  [5] xfun_0.60         cachem_1.1.0      knitr_1.51        htmltools_0.5.9  
#>  [9] rmarkdown_2.31    lifecycle_1.0.5   cli_3.6.6         sass_0.4.10      
#> [13] pkgdown_2.2.1     textshaping_1.0.5 jquerylib_0.1.4   systemfonts_1.3.2
#> [17] compiler_4.6.1    tools_4.6.1       ragg_1.5.2        bslib_0.11.0     
#> [21] evaluate_1.0.5    yaml_2.3.12       otel_0.2.0        jsonlite_2.0.0   
#> [25] rlang_1.3.0       fs_2.1.0          htmlwidgets_1.6.4
```
