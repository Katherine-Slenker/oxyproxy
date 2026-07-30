# Calculates water and oxygen fluxes as affected by species physiology.

Given an animal's body mass and water economy index, computes values for
energy expenditure, transcutaneous water loss, water vapor loss via skin
(WVSkin), moles of oxygen respired from air (MolesO2Air), oxygen flux
through lungs (O2FluxLungs), water exhaled orally (H2OOral), water
exhaled nasally (H2ONasal), water vapor loss via nose (WVNose), total
water turnover,urinary water loss, and water vapor loss via urine
(WVUrine).

## Usage

``` r
species_function(
  body_mass = numeric(0),
  water_economy_index = numeric(0),
  changeConstant = FALSE
)
```

## Arguments

- body_mass:

  Numeric. Animal body mass (kg). Must be \>0

- water_economy_index:

  Numeric. Mass-independent measurement of water flux. Ratio of
  water (ml) per day to energy metabolized (kJ) per day. Must be between
  0.05 and 0.6.

- changeConstant:

  Boolean. Default is FALSE. If changed to TRUE, user can modify
  constants injected in calculus (e.g. OCF, Zfactor, d18Oairtakenup)

## Value

Data frame with all calculated physiological variables:

- EnergyExpenditure - Energy utilized for physiological functions,
  scaled to body mass (kJ)

- TranscutaneousH2OLoss - Water loss via evaporation from the skin's
  surface (kg/((m^2)\*h))

- WVSkin - Water vapor loss via skin (kg/((m^2)\*h)

- MolesO2Air - Moles of atmospheric oxygen \* energy expenditure (moles)

- O2FluxLungs - Oxygen flux via respiration (L)

- H2OOral - Water exhaled orally (moles H2O)

- H2ONasal - Water exhaled nasally (moles H2O)

- WVNose - Water vapor loss via nasal respiration (moles H2O)

- TotalH2OTurnover - Volume of water moving through body, reflecting
  intake and loss (moles H2O)

- UrinaryH2OLoss - Water lost as urine (moles H2O)

- WVUrine - Water vapor loss via urine (moles H2O)

## Examples

``` r
# Example for a plains bison (Bison bison bison)
result <- species_function(
  body_mass = 600, water_economy_index = 0.45, changeConstant = FALSE
)
#> OCF, Zfactor, d18Oairtakenup, and Urea are standardized constants,
#>          but can be modified by user by inputing changeConstant == TRUE
str(result)
#> 'data.frame':    1 obs. of  15 variables:
#>  $ Bodymass             : num 600
#>  $ EnergyExp            : num 96005
#>  $ WEI                  : num 0.45
#>  $ TranscutaneousH2OLoss: num 103
#>  $ WVSkin               : num 51.3
#>  $ MolesO2Air           : num 207
#>  $ O2FluxLungs          : num 110598
#>  $ H2OOral              : num 166
#>  $ H2ONasal             : num 82.9
#>  $ WVNose               : num 41.5
#>  $ TotalH2OTurnover     : num 2400
#>  $ UrinaryH2OLoss       : num 600
#>  $ WVUrine              : num 300
#>  $ Urea                 : num 0.2
#>  $ d18Oairtakenup       : num 14.8
```
