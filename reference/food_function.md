# Calculates water and oxygen fluxes as affected by species diet

Given values of digestibility and macronutrient and water content of
food, computes values for food-related parameters (energy, oxygen, and
hydrogen content).

## Usage

``` r
food_function(
  digestibility_of_food = numeric(0),
  Carbohydrate_Content = numeric(0),
  Protein_Content = numeric(0),
  Fat_Content = numeric(0),
  Free_Water_Content_Food = numeric(0),
  changeConstant = FALSE
)
```

## Arguments

- digestibility_of_food:

  Numeric. Digestible organic matter as a percentage of total ingested
  matter. High values indicate that large amounts of nutrients are
  extracted. Must be between 0 and 1.

- Carbohydrate_Content:

  The percentage of carbohydrates in the diet. Must be between 0 and 1.
  This value should sum with protein and fat content to equal 1.

- Protein_Content:

  The percentage of proteins in the diet. Must be between 0 and 1. This
  value should sum with protein and fat content to equal 1.

- Fat_Content:

  The percentage of fats in the diet. Must be between 0 and 1. This
  value should sum with protein and fat content to equal 1.

- Free_Water_Content_Food:

  The percentage of free water of food. Must be between 0 and 1.

- changeConstant:

  Logical. If TRUE, prompts for values overriding the model constants.
  Defaults to FALSE.

## Value

Data frame with all calculated dietary variables:

- EEE - Energy extraction efficiency (standardized to 0.9, but must be
  set between 0-1)

- foodcarbenergy-Energy content of carbohydrates (17300 J/g)

- Ocarb - Oxygen atoms per carbohydrate unit (15.4)

- Hcarb - Hydrogen atoms per carbohydrate unit (30.9)

- foodproteinenergy - Energy content of proteins (20100 J/g)

- Oprotein - Oxygen atoms per protein unit (3)

- Hprotein - Hydrogen atoms per protein unit (11)

- foodfatenergy - Energy content of fats (39700 J/g)

- Ofat - Oxygen atoms per fat unit (2)

- Hfat - Hydrogen atoms per fat unit (60)

## Examples

``` r
# Example parameters for a herbivore diet
herbivore_food <- food_function(
  digestibility_of_food = 0.6,
  Carbohydrate_Content = 0.8,
  Protein_Content = 0.1,
  Fat_Content = 0.1,
  Free_Water_Content_Food = 0.4
)
#> CAUTION !!! Carbohydrate_Content, Protein_Content and Fat_Content arguments must sum to 1
#> Energy Extraction Efficiency, fractions (O, H, energy) of carbohydrate, protein and fat are standardized constants extracted from Kohn models and litterature,
#>          but it can be modified by user by modifying the argument changeConstant to TRUE
#> Energy Extraction Efficiency standardized to EEE = 0.9 (%)

# Example parameters for a carnivore diet
carnivore_food <- food_function(
  digestibility_of_food = 0.85,
  Carbohydrate_Content = 0.1,
  Protein_Content = 0.7,
  Fat_Content = 0.2,
  Free_Water_Content_Food = 0.7
)
#> CAUTION !!! Carbohydrate_Content, Protein_Content and Fat_Content arguments must sum to 1
#> Energy Extraction Efficiency, fractions (O, H, energy) of carbohydrate, protein and fat are standardized constants extracted from Kohn models and litterature,
#>          but it can be modified by user by modifying the argument changeConstant to TRUE
#> Energy Extraction Efficiency standardized to EEE = 0.9 (%)
```
