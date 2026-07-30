# Plots estimates of oxygen-18 enrichment of animal bodywater based on flux of oxygen input and outputs against variables input by user.

This function combines the Species, Food, Environment, Inputs, and
Ouputs, and d18Obodywater functions to generate plots of estimates of
oxygen-18 enrichment of animal bodywater against variables input by
user.

## Usage

``` r
oxy_proxy_function(
  model_bodymass = 0,
  model_WaterEconomyIndex = 0,
  model_Digestibility_of_food = 0,
  model_Carbohydrate_Content = 0,
  model_Protein_Content = 0,
  model_Fat_Content = 0,
  model_Free_Water_Content_Food = 0,
  model_air_temperature = 0,
  model_Relative_Humidity = 0,
  model_d18O_surfacewater = 0,
  changeConstant = FALSE,
  sweating_species = FALSE,
  PlotRange = TRUE
)
```

## Arguments

- model_bodymass:

  Numeric. Body mass in kg. Must be greater than 0.

- model_WaterEconomyIndex:

  Numeric. Water economy index (ml/kJ).

- model_Digestibility_of_food:

  Numeric. Digestible organic matter as a proportion of ingested matter,
  between 0 and 1.

- model_Carbohydrate_Content:

  Numeric. Proportion of carbohydrate in the diet. Carbohydrate,
  protein, and fat content must sum to 1.

- model_Protein_Content:

  Numeric. Proportion of protein in the diet.

- model_Fat_Content:

  Numeric. Proportion of fat in the diet.

- model_Free_Water_Content_Food:

  Numeric. Proportion of free water in food.

- model_air_temperature:

  Numeric. Air temperature in deg C. Zero and negative values are valid.

- model_Relative_Humidity:

  Numeric. Relative humidity as a proportion between 0 and 1.

- model_d18O_surfacewater:

  Numeric. d18O of local surface water (per mil VSMOW). Zero and
  negative values are valid.

- changeConstant:

  Logical. If TRUE, prompts for values overriding the model constants.
  Defaults to FALSE.

- sweating_species:

  Logical. Whether the species sweats. Defaults to FALSE.

- PlotRange:

  Logical. If TRUE, plots d18Obw against any argument given more than
  one value. Defaults to TRUE.

## Value

Data frame of d18Obw, d18Ophos, and d18Ocarb estimates for every
combination of the supplied arguments.

## Examples

``` r
# Single set of parameters for a herbivore
oxy_proxy_function(
  model_bodymass = 600,
  model_WaterEconomyIndex = 0.4,
  model_Digestibility_of_food = 0.6,
  model_Carbohydrate_Content = 0.8,
  model_Protein_Content = 0.1,
  model_Fat_Content = 0.1,
  model_Free_Water_Content_Food = 0.55,
  model_air_temperature = 4,
  model_Relative_Humidity = 0.67,
  model_d18O_surfacewater = -10,
  sweating_species = FALSE,
  PlotRange = FALSE
)
#> OCF, Zfactor, d18Oairtakenup, and Urea are standardized constants,
#>          but can be modified by user by inputing changeConstant == TRUE
#> CAUTION !!! Carbohydrate_Content, Protein_Content and Fat_Content arguments must sum to 1
#> Energy Extraction Efficiency, fractions (O, H, energy) of carbohydrate, protein and fat are standardized constants extracted from Kohn models and litterature,
#>          but it can be modified by user by modifying the argument changeConstant to TRUE
#> Energy Extraction Efficiency standardized to EEE = 0.9 (%)
#> Using non-sweating species model (WVSweat = 0)
#>      d18Obw d18Ophos d18Ocarb
#> 1 -6.848713  10.6038  19.1038
#>   Bodymass EnergyExp WEI TranscutaneousH2OLoss  WVSkin MolesO2Air O2FluxLungs
#> 1      600  96004.79 0.4              102.6572 51.3286   207.3704    110597.5
#>    H2OOral H2ONasal   WVNose TotalH2OTurnover UrinaryH2OLoss WVUrine Urea
#> 1 165.8963 82.94814 41.47407          2133.44         533.36  266.68  0.2
#>   d18Oairtakenup Digestibility EEE foodcarbenergy foodcarbcontent Ocarb Hcarb
#> 1           14.8           0.6 0.9          17300             0.8  15.4  30.9
#>   foodproteinenergy Oprotein Hprotein foodfatenergy Ofat Hfat
#> 1             20100        3       11         39700    2   60
#>   foodproteincontent foodfatcontent freeH20food airtemp MAT Humidity WVinLungs
#> 1                0.1            0.1        0.55       4 277     0.67  3.036931
#>         WV d18Osw   dairH2O dairH2OSW d18OleafH2O d18Oleafcellulose dfoodO2SW
#> 1 1.518465    -10 -21.06243 -11.06243   -1.069397           25.9306   35.9306
#>   dfoodH2Osw FoodMassIngested dryOinflux dryHinflux FreeH2Oinfood WaterinFood
#> 1   4.465302         8.970063   62.09795   154.1308      609.1271    304.5636
#>   DrinkingH2OIngested DrinkingWater DryFecalOutput FecalH20Loss WVFecal
#> 1            1367.145      683.5725       3.588025      299.026 149.513
#>   WaterHeatLoss Sweating WVSweat  Panting  WVMouth UreaProduced    WVCO2
#> 1      949.5523 712.1642       0 474.7761 320.3362      1.45315 190.9498
#>      d18Obw d18Ophos d18Ocarb
#> 1 -6.848713  10.6038  19.1038
```
