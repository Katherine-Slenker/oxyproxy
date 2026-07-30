# Plots estimated values of relative humidity converted from measurements of d18Oenamel-carbonate.

This function combines the RH_Estimation_d18O, Species, Food,
RH_Estimation_Environment, RH_Estimation_Inputs, and Outputs functions
to generate plots of estimates of relative humidity against measurements
of d18Oenamel-carbonate (converted to d18Obodywater) and variables input
by user.

## Usage

``` r
humidity_oxy_proxy(
  sampled_d18Ocarbonate = 0,
  model_air_temperature = 0,
  model_d18O_Surfacewater = 0,
  model_Digestibility_of_food = 0,
  model_Carbohydrate_Content = 0,
  model_Protein_Content = 0,
  model_Fat_Content = 0,
  model_Free_Water_Content_Food = 0,
  model_Body_mass = 0,
  model_WaterEconomyIndex = 0,
  changeConstant = FALSE,
  sweating_species = FALSE,
  PlotRange = TRUE,
  printinfo = FALSE
)
```

## Arguments

- sampled_d18Ocarbonate:

  Numeric. Measured d18O of enamel carbonate (per mil VSMOW).

- model_air_temperature:

  Numeric. Air temperature in deg C. Enter 0 to have the model
  substitute a range of simulated values.

- model_d18O_Surfacewater:

  Numeric. d18O of local surface water (per mil VSMOW). Enter 0 to
  substitute simulated values.

- model_Digestibility_of_food:

  Numeric. Digestible organic matter as a proportion of ingested matter.
  Enter 0 to substitute simulated values.

- model_Carbohydrate_Content:

  Numeric. Proportion of carbohydrate in the diet.

- model_Protein_Content:

  Numeric. Proportion of protein in the diet.

- model_Fat_Content:

  Numeric. Proportion of fat in the diet.

- model_Free_Water_Content_Food:

  Numeric. Proportion of free water in food.

- model_Body_mass:

  Numeric. Body mass in kg.

- model_WaterEconomyIndex:

  Numeric. Water economy index (ml/kJ).

- changeConstant:

  Logical. If TRUE, prompts for values overriding the model constants.
  Defaults to FALSE.

- sweating_species:

  Logical. Whether the species sweats. Defaults to FALSE.

- PlotRange:

  Logical. If TRUE, plots relative humidity against any argument given
  more than one value. Defaults to TRUE.

- printinfo:

  Logical. If TRUE, prints the computed humidity values.

## Value

Plots of estimates of relative humidity versus d18Obodywater values and
user-input variables.

## Examples

``` r
# Estimate relative humidity from a measured enamel carbonate value
humidity_oxy_proxy(
  sampled_d18Ocarbonate = 20,
  model_air_temperature = 4,
  model_d18O_Surfacewater = -8,
  model_Digestibility_of_food = 0.6,
  model_Carbohydrate_Content = 0.8,
  model_Protein_Content = 0.15,
  model_Fat_Content = 0.05,
  model_Free_Water_Content_Food = 0.5,
  model_Body_mass = 500,
  model_WaterEconomyIndex = 0.4,
  PlotRange = FALSE
)
#> WARNING : If you are missing information about species, food or environment and you struggle to fill the arguments values,
#>          oxyproxy package can try a wide range of simulated values for you. Enter 0 -zero- in the argument you want the model to inject simulated values
#> CAUTION !!! Carbohydrate_Content, Protein_Content and Fat_Content arguments must sum to 1
#> Energy Extraction Efficiency, fractions (O, H, energy) of carbohydrate, protein and fat are standardized constants extracted from Kohn models and litterature,
#>          but it can be modified by user by modifying the argument changeConstant to TRUE
#> Energy Extraction Efficiency standardized to EEE = 0.9 (%)
#> OCF, Zfactor, d18Oairtakenup, and Urea are standardized constants,
#>          but can be modified by user by inputing changeConstant == TRUE
#> Using non-sweating species model (WVSweat = 0)
#>   Bodymass EnergyExp WEI TranscutaneousH2OLoss   WVSkin MolesO2Air O2FluxLungs
#> 1      500  84040.88 0.4              90.90243 45.45121   181.5283     96815.1
#>    H2OOral H2ONasal   WVNose TotalH2OTurnover UrinaryH2OLoss  WVUrine Urea
#> 1 145.2226 72.61132 36.30566         1867.575       466.8938 233.4469  0.2
#>   d18Oairtakenup Digestibility EEE foodcarbenergy foodcarbcontent Ocarb Hcarb
#> 1           14.8           0.6 0.9          17300             0.8  15.4  30.9
#>   foodproteinenergy Oprotein Hprotein foodfatenergy Ofat Hfat
#> 1             20100        3       11         39700    2   60
#>   foodproteincontent foodfatcontent freeH20food airtemp MAT d18Osw   dairH2O
#> 1               0.15           0.05         0.5       4 277     -8 -19.06243
#>   dairH2OSW FoodMassIngested dryOinflux dryHinflux FreeH2Oinfood WaterinFood
#> 1 -11.06243         8.260683   57.41009   131.0128      458.9635    229.4818
#>   DryFecalOutput FecalH20Loss  WVFecal WaterHeatLoss Sweating WVSweat  Panting
#> 1       3.304273     275.3781 137.6891      816.5669 612.4252       0 408.2834
#>   WVMouth UreaProduced    WVCO2 d18Ocarbonate d18Ophosphate d18Obodywater
#> 1 276.753     2.007346 171.4247            20          11.5     -5.952511
#>    Humidity WVinLungs       WV d18OleafH2O d18Oleafcellulose dfoodO2SW
#> 1 0.8417159  3.815273 1.907636   -3.716447          23.28355  31.28355
#>   dfoodH2Osw DrinkingH2OIngested DrinkingWater
#> 1   2.141777            1273.784      636.8918
```
