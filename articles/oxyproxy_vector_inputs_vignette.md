# OxyProxy: Vectorized Inputs Workflow

## Overview

This vignette demonstrates how to run oxyproxy using **vector inputs**
to explore multiple scenarios at once.

Common use cases: - Sensitivity to air temperature and humidity -
Differences in surface water δ18O across sites - Comparing diets or
species masses across populations

## Load the package

``` r

library(oxyproxy)
```

## Step 1 — Provide vector environmental inputs

[`environment_function()`](https://katherine-slenker.github.io/oxyproxy/reference/environment_function.md)
accepts vectors and returns a **full factorial** design.

``` r

env_grid <- environment_function(
  air_temperature = c(10, 20),
  relative_humidity = c(0.50, 0.75),
  d18O_surface_water = c(-2, -5)
)

env_grid
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
nrow(env_grid)
#> [1] 8
```

### What to expect

The number of rows equals:

`length(air_temperature) * length(relative_humidity) * length(d18O_surface_water)`

In this example: `2 * 2 * 2 = 8` rows.

## Step 2 — Hold species and food constant, vary environment via the wrapper

This is a typical sensitivity analysis: one species + one diet, many
environments, run in a single call to
[`oxy_proxy_function()`](https://katherine-slenker.github.io/oxyproxy/reference/oxy_proxy_function.md).

``` r

oxyproxy_many <- oxy_proxy_function(
  model_bodymass = 70,
  model_WaterEconomyIndex = 0.40,
  model_Digestibility_of_food = 0.8,
  model_Carbohydrate_Content = 0.5,
  model_Protein_Content = 0.2,
  model_Fat_Content = 0.3,
  model_Free_Water_Content_Food = 0.7,
  model_air_temperature = c(10, 20),
  model_Relative_Humidity = c(0.50, 0.75),
  model_d18O_surfacewater = c(-2, -5),
  changeConstant = FALSE,
  sweating_species = FALSE,
  PlotRange = FALSE # set TRUE if you want a plot for visualization
)
#>       d18Obw d18Ophos d18Ocarb
#> 1  3.0109105 20.46342 28.96342
#> 2  2.8505638 20.30308 28.80308
#> 3 -0.2406579 17.21185 25.71185
#> 4 -0.4010046 17.05151 25.55151
#> 5  1.5038310 18.95634 27.45634
#> 6  1.3626761 18.81519 27.31519
#> 7 -1.7477373 15.70477 24.20477
#> 8 -1.8888922 15.56362 24.06362

oxyproxy_many
#>   Bodymass EnergyExp WEI TranscutaneousH2OLoss   WVSkin MolesO2Air O2FluxLungs
#> 1       70  20006.18 0.4              24.49305 12.24653   43.21334    23047.11
#> 2       70  20006.18 0.4              24.49305 12.24653   43.21334    23047.11
#> 3       70  20006.18 0.4              24.49305 12.24653   43.21334    23047.11
#> 4       70  20006.18 0.4              24.49305 12.24653   43.21334    23047.11
#> 5       70  20006.18 0.4              24.49305 12.24653   43.21334    23047.11
#> 6       70  20006.18 0.4              24.49305 12.24653   43.21334    23047.11
#> 7       70  20006.18 0.4              24.49305 12.24653   43.21334    23047.11
#> 8       70  20006.18 0.4              24.49305 12.24653   43.21334    23047.11
#>    H2OOral H2ONasal   WVNose TotalH2OTurnover UrinaryH2OLoss  WVUrine Urea
#> 1 34.57067 17.28534 8.642668         444.5817       111.1454 55.57271  0.2
#> 2 34.57067 17.28534 8.642668         444.5817       111.1454 55.57271  0.2
#> 3 34.57067 17.28534 8.642668         444.5817       111.1454 55.57271  0.2
#> 4 34.57067 17.28534 8.642668         444.5817       111.1454 55.57271  0.2
#> 5 34.57067 17.28534 8.642668         444.5817       111.1454 55.57271  0.2
#> 6 34.57067 17.28534 8.642668         444.5817       111.1454 55.57271  0.2
#> 7 34.57067 17.28534 8.642668         444.5817       111.1454 55.57271  0.2
#> 8 34.57067 17.28534 8.642668         444.5817       111.1454 55.57271  0.2
#>   d18Oairtakenup Digestibility EEE foodcarbenergy foodcarbcontent Ocarb Hcarb
#> 1           14.8           0.8 0.9          17300             0.5  15.4  30.9
#> 2           14.8           0.8 0.9          17300             0.5  15.4  30.9
#> 3           14.8           0.8 0.9          17300             0.5  15.4  30.9
#> 4           14.8           0.8 0.9          17300             0.5  15.4  30.9
#> 5           14.8           0.8 0.9          17300             0.5  15.4  30.9
#> 6           14.8           0.8 0.9          17300             0.5  15.4  30.9
#> 7           14.8           0.8 0.9          17300             0.5  15.4  30.9
#> 8           14.8           0.8 0.9          17300             0.5  15.4  30.9
#>   foodproteinenergy Oprotein Hprotein foodfatenergy Ofat Hfat
#> 1             20100        3       11         39700    2   60
#> 2             20100        3       11         39700    2   60
#> 3             20100        3       11         39700    2   60
#> 4             20100        3       11         39700    2   60
#> 5             20100        3       11         39700    2   60
#> 6             20100        3       11         39700    2   60
#> 7             20100        3       11         39700    2   60
#> 8             20100        3       11         39700    2   60
#>   foodproteincontent foodfatcontent freeH20food airtemp MAT Humidity WVinLungs
#> 1                0.2            0.3         0.7      10 283     0.50  3.291017
#> 2                0.2            0.3         0.7      20 293     0.50  6.128160
#> 3                0.2            0.3         0.7      10 283     0.50  3.291017
#> 4                0.2            0.3         0.7      20 293     0.50  6.128160
#> 5                0.2            0.3         0.7      10 283     0.75  4.936525
#> 6                0.2            0.3         0.7      20 293     0.75  9.192240
#> 7                0.2            0.3         0.7      10 283     0.75  4.936525
#> 8                0.2            0.3         0.7      20 293     0.75  9.192240
#>         WV d18Osw   dairH2O  dairH2OSW d18OleafH2O d18Oleafcellulose dfoodO2SW
#> 1 1.645508     -2 -12.46907 -10.469070   11.234535          38.23453  40.23453
#> 2 3.064080     -2 -11.57060  -9.570604   10.785302          37.78530  39.78530
#> 3 1.645508     -5 -15.46907 -10.469070    8.234535          35.23453  40.23453
#> 4 3.064080     -5 -14.57060  -9.570604    7.785302          34.78530  39.78530
#> 5 2.468262     -2 -12.46907 -10.469070    4.617267          31.61727  33.61727
#> 6 4.596120     -2 -11.57060  -9.570604    4.392651          31.39265  33.39265
#> 7 2.468262     -5 -15.46907 -10.469070    1.617267          28.61727  33.61727
#> 8 4.596120     -5 -14.57060  -9.570604    1.392651          28.39265  33.39265
#>   dfoodH2Osw FoodMassIngested dryOinflux dryHinflux FreeH2Oinfood WaterinFood
#> 1   6.617267         1.130446   7.243896   29.01628       146.551    73.27549
#> 2   6.392651         1.130446   7.243896   29.01628       146.551    73.27549
#> 3   6.617267         1.130446   7.243896   29.01628       146.551    73.27549
#> 4   6.392651         1.130446   7.243896   29.01628       146.551    73.27549
#> 5   3.308634         1.130446   7.243896   29.01628       146.551    73.27549
#> 6   3.196325         1.130446   7.243896   29.01628       146.551    73.27549
#> 7   3.308634         1.130446   7.243896   29.01628       146.551    73.27549
#> 8   3.196325         1.130446   7.243896   29.01628       146.551    73.27549
#>   DrinkingH2OIngested DrinkingWater DryFecalOutput FecalH20Loss  WVFecal
#> 1            265.7234      132.8617      0.2260891     18.84227 9.421134
#> 2            262.8863      131.4431      0.2260891     18.84227 9.421134
#> 3            265.7234      132.8617      0.2260891     18.84227 9.421134
#> 4            262.8863      131.4431      0.2260891     18.84227 9.421134
#> 5            264.0779      132.0389      0.2260891     18.84227 9.421134
#> 6            259.8222      129.9111      0.2260891     18.84227 9.421134
#> 7            264.0779      132.0389      0.2260891     18.84227 9.421134
#> 8            259.8222      129.9111      0.2260891     18.84227 9.421134
#>   WaterHeatLoss Sweating WVSweat  Panting  WVMouth UreaProduced    WVCO2
#> 1      238.2449 178.6837       0 119.1225 76.84657    0.4883525 35.46074
#> 2      238.2449 178.6837       0 119.1225 76.84657    0.4883525 35.46074
#> 3      238.2449 178.6837       0 119.1225 76.84657    0.4883525 35.46074
#> 4      238.2449 178.6837       0 119.1225 76.84657    0.4883525 35.46074
#> 5      238.2449 178.6837       0 119.1225 76.84657    0.4883525 35.46074
#> 6      238.2449 178.6837       0 119.1225 76.84657    0.4883525 35.46074
#> 7      238.2449 178.6837       0 119.1225 76.84657    0.4883525 35.46074
#> 8      238.2449 178.6837       0 119.1225 76.84657    0.4883525 35.46074
#>       d18Obw d18Ophos d18Ocarb
#> 1  3.0109105 20.46342 28.96342
#> 2  2.8505638 20.30308 28.80308
#> 3 -0.2406579 17.21185 25.71185
#> 4 -0.4010046 17.05151 25.55151
#> 5  1.5038310 18.95634 27.45634
#> 6  1.3626761 18.81519 27.31519
#> 7 -1.7477373 15.70477 24.20477
#> 8 -1.8888922 15.56362 24.06362
```

## Step 3 — Explicit scenario design across species, diet, environment

If you want to vary *everything* (e.g., body mass AND temperature AND
diet), build a scenario table and run row-wise using the individual
pipeline functions.

``` r

scenarios <- expand.grid(
  body_mass = c(20, 70),
  air_temperature = c(10, 20),
  relative_humidity = c(0.50, 0.75),
  d18O_surface_water = c(-2, -5),
  stringsAsFactors = FALSE
)

head(scenarios)
#>   body_mass air_temperature relative_humidity d18O_surface_water
#> 1        20              10              0.50                 -2
#> 2        70              10              0.50                 -2
#> 3        20              20              0.50                 -2
#> 4        70              20              0.50                 -2
#> 5        20              10              0.75                 -2
#> 6        70              10              0.75                 -2
nrow(scenarios)
#> [1] 16
```

### Execute scenarios

``` r

run_scenario <- function(row) {
  sp <- species_function(body_mass = row$body_mass, water_economy_index = 0.1)

  fd <- food_function(
    digestibility_of_food = 0.1,
    Carbohydrate_Content = 0.1,
    Protein_Content = 0.2,
    Fat_Content = 0.7,
    Free_Water_Content_Food = 0.1,
    changeConstant = FALSE
  )

  env <- environment_function(
    air_temperature = row$air_temperature,
    relative_humidity = row$relative_humidity,
    d18O_surface_water = row$d18O_surface_water
  )

  inputs_out <- input_function(species = sp, food = fd, environment = env)
  outputs_out <- outputs_function(inputs = inputs_out, sweating_species = FALSE)
  d18_obw_function(outputs = outputs_out)
}

outs <- lapply(seq_len(nrow(scenarios)), function(i) run_scenario(scenarios[i, , drop = FALSE]))
#>      d18Obw d18Ophos d18Ocarb
#> 1 -4.492249 12.96026 21.46026
#>      d18Obw d18Ophos d18Ocarb
#> 1 -4.453131 12.99938 21.49938
#>      d18Obw d18Ophos d18Ocarb
#> 1 -4.662447 12.79006 21.29006
#>      d18Obw d18Ophos d18Ocarb
#> 1 -4.537476 12.91504 21.41504
#>      d18Obw d18Ophos d18Ocarb
#> 1 -4.983544 12.46897 20.96897
#>      d18Obw d18Ophos d18Ocarb
#> 1 -4.884721 12.56779 21.06779
#>      d18Obw d18Ophos d18Ocarb
#> 1 -5.212439 12.24007 20.74007
#>      d18Obw d18Ophos d18Ocarb
#> 1 -4.984734 12.46778 20.96778
#>      d18Obw d18Ophos d18Ocarb
#> 1 -5.114934 12.33758 20.83758
#>      d18Obw d18Ophos d18Ocarb
#> 1 -5.078203 12.37431 20.87431
#>      d18Obw d18Ophos d18Ocarb
#> 1 -5.285132 12.16738 20.66738
#>      d18Obw d18Ophos d18Ocarb
#> 1 -5.162548 12.28996 20.78996
#>      d18Obw d18Ophos d18Ocarb
#> 1 -5.606229 11.84628 20.34628
#>      d18Obw d18Ophos d18Ocarb
#> 1 -5.509793 11.94272 20.44272
#>      d18Obw d18Ophos d18Ocarb
#> 1 -5.835124 11.61739 20.11739
#>      d18Obw d18Ophos d18Ocarb
#> 1 -5.609807  11.8427  20.3427
length(outs)
#> [1] 16
```

## Summarize results into a data frame

``` r

extract_one <- function(out) {
  data.frame(d18Obw = out$d18Obw, stringsAsFactors = FALSE)
}

results_df <- do.call(rbind, lapply(outs, extract_one))
results_df <- cbind(scenarios, results_df)

head(results_df)
#>   body_mass air_temperature relative_humidity d18O_surface_water    d18Obw
#> 1        20              10              0.50                 -2 -4.492249
#> 2        70              10              0.50                 -2 -4.453131
#> 3        20              20              0.50                 -2 -4.662447
#> 4        70              20              0.50                 -2 -4.537476
#> 5        20              10              0.75                 -2 -4.983544
#> 6        70              10              0.75                 -2 -4.884721
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
