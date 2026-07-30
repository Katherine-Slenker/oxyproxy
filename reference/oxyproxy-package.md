# oxyproxy: Steady-State Mass Balance Model of Oxygen Flux in Animal Body Water

Generates a predicted value of oxygen-18 enrichment in animal bodywater
and tooth enamel given all oxygen inputs (atmospheric oxygen, air water
vapor, bound oxygen in food, free water in food, and drinking water),
oxygen outputs (exhaled CO2, urea, fecal water, urine, respiratory water
vapor, transcutaneous water vapor, and sweat), and species-specific
values (body mass, water economy index) relative to environmental values
(temperature, oxygen-18 enrichment of surface water, and relative
humidity).

## Details

oxyproxy implements the steady-state mass balance model of oxygen flux
in animal body water from Kohn (1996), and runs it in both directions.

**Forward: physiology and environment to d18Obw.** Given body mass,
water economy index, diet composition, air temperature, relative
humidity, and d18O of surface water, estimate the oxygen-18 enrichment
of body water, enamel phosphate, and enamel carbonate. Use
[`oxy_proxy_function()`](https://katherine-slenker.github.io/oxyproxy/reference/oxy_proxy_function.md),
or call the stages individually via
[`species_function()`](https://katherine-slenker.github.io/oxyproxy/reference/species_function.md),
[`food_function()`](https://katherine-slenker.github.io/oxyproxy/reference/food_function.md),
[`environment_function()`](https://katherine-slenker.github.io/oxyproxy/reference/environment_function.md),
[`input_function()`](https://katherine-slenker.github.io/oxyproxy/reference/input_function.md),
[`outputs_function()`](https://katherine-slenker.github.io/oxyproxy/reference/outputs_function.md)
and
[`d18_obw_function()`](https://katherine-slenker.github.io/oxyproxy/reference/d18_obw_function.md).

**Inverse: measured enamel to relative humidity.** Given a measured d18O
of enamel carbonate plus the same physiological and dietary parameters,
recover the relative humidity consistent with it. Use
[`humidity_oxy_proxy()`](https://katherine-slenker.github.io/oxyproxy/reference/humidity_oxy_proxy.md),
or the stages
[`d18O_enamel()`](https://katherine-slenker.github.io/oxyproxy/reference/d18O_enamel.md),
[`rh_estimation_environment_function()`](https://katherine-slenker.github.io/oxyproxy/reference/rh_estimation_environment_function.md),
[`inverse_input_function()`](https://katherine-slenker.github.io/oxyproxy/reference/inverse_input_function.md)
and
[`rh_function()`](https://katherine-slenker.github.io/oxyproxy/reference/rh_function.md).

Any argument accepts a vector, in which case the model is evaluated over
every combination of the supplied values.

## See also

Useful links:

- <https://katherine-slenker.github.io/oxyproxy/>

- <https://github.com/Katherine-Slenker/oxyproxy>

- Report bugs at <https://github.com/Katherine-Slenker/oxyproxy/issues>

## Author

**Maintainer**: Katherine Slenker <kslenker3@gatech.edu>

Authors:

- Katherine Slenker <kslenker3@gatech.edu>

- Corentin Gibert Bret

## Examples

``` r
# Forward: estimate d18O body water for a herbivore
oxy_proxy_function(
  model_bodymass = 30, model_WaterEconomyIndex = 0.25,
  model_Carbohydrate_Content = 0.85, model_Protein_Content = 0.1,
  model_Fat_Content = 0.05, model_Digestibility_of_food = 0.7,
  model_Free_Water_Content_Food = 0.65, model_air_temperature = 15,
  model_Relative_Humidity = 0.75, model_d18O_surfacewater = -3.25,
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
#> 1 0.1011262 17.55364 26.05364
#>   Bodymass EnergyExp  WEI TranscutaneousH2OLoss   WVSkin MolesO2Air O2FluxLungs
#> 1       30  10778.07 0.25              13.91882 6.959409   23.28063    12416.34
#>    H2OOral H2ONasal   WVNose TotalH2OTurnover UrinaryH2OLoss  WVUrine Urea
#> 1 18.62451 9.312253 4.656127         149.6954       37.42386 18.71193  0.2
#>   d18Oairtakenup Digestibility EEE foodcarbenergy foodcarbcontent Ocarb Hcarb
#> 1           14.8           0.7 0.9          17300            0.85  15.4  30.9
#>   foodproteinenergy Oprotein Hprotein foodfatenergy Ofat Hfat
#> 1             20100        3       11         39700    2   60
#>   foodproteincontent foodfatcontent freeH20food airtemp MAT Humidity WVinLungs
#> 1                0.1           0.05        0.65      15 288     0.75  6.736299
#>         WV d18Osw   dairH2O dairH2OSW d18OleafH2O d18Oleafcellulose dfoodO2SW
#> 1 3.368149  -3.25 -13.25646 -10.00646    3.251615          30.25162  33.50162
#>   dfoodH2Osw FoodMassIngested dryOinflux dryHinflux FreeH2Oinfood WaterinFood
#> 1   3.250808        0.9148689   7.775196    17.5014      94.39879    47.19939
#>   DrinkingH2OIngested DrinkingWater DryFecalOutput FecalH20Loss  WVFecal
#> 1            31.05894      15.52947      0.2744607     22.87355 11.43678
#>   WaterHeatLoss Sweating WVSweat  Panting  WVMouth UreaProduced    WVCO2
#> 1      47.54244 35.65683       0 23.77122 21.19786    0.1729102 22.13222
#>      d18Obw d18Ophos d18Ocarb
#> 1 0.1011262 17.55364 26.05364

# Inverse: recover relative humidity from the enamel carbonate value
humidity_oxy_proxy(
  sampled_d18Ocarbonate = 26.053638,
  model_air_temperature = 15, model_d18O_Surfacewater = -3.25,
  model_Digestibility_of_food = 0.7, model_Carbohydrate_Content = 0.85,
  model_Protein_Content = 0.1, model_Fat_Content = 0.05,
  model_Free_Water_Content_Food = 0.65, model_Body_mass = 30,
  model_WaterEconomyIndex = 0.25, PlotRange = FALSE
)
#> NOTE : If you are missing information about species, food or environment, enter 0 -zero- for that argument
#>          and oxyproxy will substitute the corresponding Herbivore Standard value.
#> CAUTION !!! Carbohydrate_Content, Protein_Content and Fat_Content arguments must sum to 1
#> Energy Extraction Efficiency, fractions (O, H, energy) of carbohydrate, protein and fat are standardized constants extracted from Kohn models and litterature,
#>          but it can be modified by user by modifying the argument changeConstant to TRUE
#> Energy Extraction Efficiency standardized to EEE = 0.9 (%)
#> OCF, Zfactor, d18Oairtakenup, and Urea are standardized constants,
#>          but can be modified by user by inputing changeConstant == TRUE
#> Using non-sweating species model (WVSweat = 0)
#>   Bodymass EnergyExp  WEI TranscutaneousH2OLoss   WVSkin MolesO2Air O2FluxLungs
#> 1       30  10778.07 0.25              13.91882 6.959409   23.28063    12416.34
#>    H2OOral H2ONasal   WVNose TotalH2OTurnover UrinaryH2OLoss  WVUrine Urea
#> 1 18.62451 9.312253 4.656127         149.6954       37.42386 18.71193  0.2
#>   d18Oairtakenup Digestibility EEE foodcarbenergy foodcarbcontent Ocarb Hcarb
#> 1           14.8           0.7 0.9          17300            0.85  15.4  30.9
#>   foodproteinenergy Oprotein Hprotein foodfatenergy Ofat Hfat
#> 1             20100        3       11         39700    2   60
#>   foodproteincontent foodfatcontent freeH20food airtemp MAT d18Osw   dairH2O
#> 1                0.1           0.05        0.65      15 288  -3.25 -13.25646
#>   dairH2OSW FoodMassIngested dryOinflux dryHinflux FreeH2Oinfood WaterinFood
#> 1 -10.00646        0.9148689   7.775196    17.5014      94.39879    47.19939
#>   DryFecalOutput FecalH20Loss  WVFecal WaterHeatLoss Sweating WVSweat  Panting
#> 1      0.2744607     22.87355 11.43678      47.54244 35.65683       0 23.77122
#>    WVMouth UreaProduced    WVCO2 d18Ocarbonate d18Ophosphate d18Obodywater
#> 1 21.19786    0.1729102 22.13222      26.05364      17.55364     0.1011266
#>   Humidity WVinLungs       WV d18OleafH2O d18Oleafcellulose dfoodO2SW
#> 1     0.75  6.736298 3.368149    3.251616          30.25162  33.50162
#>   dfoodH2Osw DrinkingH2OIngested DrinkingWater
#> 1   3.250808            31.05894      15.52947
```
