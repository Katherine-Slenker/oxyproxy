# Calculates all variables of oxygen input from physiology, diet, and environment.

This function combines the Species, Food, and Environment functions to
calculate oxygen inputs such as mass of food ingested, dry oxygen influx
from diet, dry hydrogen influx from diet, free water content in food,
water vapor in food, amount of exogenous water consumed, and water vapor
from ingested waters.

## Usage

``` r
input_function(species = 0, food = 0, environment = 0)
```

## Arguments

- species:

  Data frame containing species physiological parameters. Must include:
  EnergyExp, TotalH2OTurnover, WVinLungs

- food:

  Data frame containing food composition data. Must include:
  Digestibility, EEE, foodcarbcontent, foodcarbenergy, Ocarb, Hcarb,
  foodproteincontent, foodproteinenergy, Oprotein, Hprotein,
  foodfatcontent, foodfatenergy, Ofat, Hfat, and freeH20food.

- environment:

  Data frame containing environmental conditions Must include: WVinLungs

## Value

Data frame with all input combinations and calculated physiological
variables:

- dryOinflux - Dry oxygen influx from food (moles O2)

- dryHinflux - Dry hydrogen influx from food (moles H2)

- FreeH2Oinfood - Free water content in food (moles H2O)

- WaterinFood - Water vapor from food (half of free water) (moles H2O)

- DrinkingH2OIngested - Exogenous water consumed (moles H2O)

- DrinkingWater - Drinking water vapor (half of ingested) (moles H2O)

## Examples

``` r
species_data <- species_function(body_mass = 600, water_economy_index = 0.4)
#> OCF, Zfactor, d18Oairtakenup, and Urea are standardized constants,
#>          but can be modified by user by inputing changeConstant == TRUE
food_data <- food_function(
  digestibility_of_food = 0.6, Carbohydrate_Content = 0.8,
  Protein_Content = 0.1, Fat_Content = 0.1, Free_Water_Content_Food = 0.4
)
#> CAUTION !!! Carbohydrate_Content, Protein_Content and Fat_Content arguments must sum to 1
#> Energy Extraction Efficiency, fractions (O, H, energy) of carbohydrate, protein and fat are standardized constants extracted from Kohn models and litterature,
#>          but it can be modified by user by modifying the argument changeConstant to TRUE
#> Energy Extraction Efficiency standardized to EEE = 0.9 (%)
environment_data <- environment_function(
  air_temperature = 20, relative_humidity = 0.6, d18O_surface_water = -5
)

input_function(
  species = species_data, food = food_data, environment = environment_data
)
#>   Bodymass EnergyExp WEI TranscutaneousH2OLoss  WVSkin MolesO2Air O2FluxLungs
#> 1      600  96004.79 0.4              102.6572 51.3286   207.3704    110597.5
#>    H2OOral H2ONasal   WVNose TotalH2OTurnover UrinaryH2OLoss WVUrine Urea
#> 1 165.8963 82.94814 41.47407          2133.44         533.36  266.68  0.2
#>   d18Oairtakenup Digestibility EEE foodcarbenergy foodcarbcontent Ocarb Hcarb
#> 1           14.8           0.6 0.9          17300             0.8  15.4  30.9
#>   foodproteinenergy Oprotein Hprotein foodfatenergy Ofat Hfat
#> 1             20100        3       11         39700    2   60
#>   foodproteincontent foodfatcontent freeH20food airtemp MAT Humidity WVinLungs
#> 1                0.1            0.1         0.4      20 293      0.6  7.353792
#>         WV d18Osw  dairH2O dairH2OSW d18OleafH2O d18Oleafcellulose dfoodO2SW
#> 1 3.676896     -5 -14.5706 -9.570604    5.228241          32.22824  37.22824
#>   dfoodH2Osw FoodMassIngested dryOinflux dryHinflux FreeH2Oinfood WaterinFood
#> 1   5.114121         8.970063   62.09795   154.1308      332.2511    166.1256
#>   DrinkingH2OIngested DrinkingWater
#> 1            1639.704      819.8521
```
