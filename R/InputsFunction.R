#' Calculates all variables of oxygen input from physiology, diet, and environment.
#'
#' This function combines the Species, Food, and Environment functions to calculate
#' oxygen inputs such as mass of food ingested, dry oxygen influx from diet,
#' dry hydrogen influx from diet, free water content in food, water vapor in food,
#' amount of exogenous water consumed, and water vapor from ingested waters.
#'
#'
#' @param species Data frame containing species physiological parameters.
#'   Must include: EnergyExp, TotalH2OTurnover, WVinLungs
#' @param food Data frame containing food composition data.
#'   Must include: Digestibility, EEE, foodcarbcontent, foodcarbenergy, Ocarb,
#'   Hcarb, foodproteincontent, foodproteinenergy, Oprotein, Hprotein,
#'   foodfatcontent, foodfatenergy, Ofat, Hfat,  and freeH20food.
#' @param environment Data frame containing environmental conditions
#'  Must include: WVinLungs
#' @return Data frame with all input combinations and calculated physiological
#'         variables:
#'   \itemize{
#'     \item dryOinflux - Dry oxygen influx from food (moles O2)
#'     \item dryHinflux - Dry hydrogen influx from food (moles H2)
#'     \item FreeH2Oinfood - Free water content in food (moles H2O)
#'     \item WaterinFood - Water vapor from food (half of free water) (moles H2O)
#'     \item DrinkingH2OIngested - Exogenous  water consumed (moles H2O)
#'     \item DrinkingWater - Drinking water vapor (half of ingested) (moles H2O)
#'   }
#' @examples
#' species_data <- species_function(body_mass = 600, water_economy_index = 0.4)
#' food_data <- food_function(
#'   digestibility_of_food = 0.6, Carbohydrate_Content = 0.8,
#'   Protein_Content = 0.1, Fat_Content = 0.1, Free_Water_Content_Food = 0.4
#' )
#' environment_data <- environment_function(
#'   air_temperature = 20, relative_humidity = 0.6, d18O_surface_water = -5
#' )
#'
#' input_function(
#'   species = species_data, food = food_data, environment = environment_data
#' )
#'
#' @export
input_function <- function(species = 0, food = 0, environment = 0) {
  if (identical(species, 0) || identical(food, 0) || identical(environment, 0)) {
    stop("All three arguments (Species, Food, Environment) must be provided as data frames")
  }

  if (!is.data.frame(species) || !is.data.frame(food) || !is.data.frame(environment)) {
    stop("Species, Food, and Environment must be data frames")
  }

  if (nrow(species) == 0 || nrow(food) == 0 || nrow(environment) == 0) {
    stop("Arguments cannot be empty")
  }

  combine_inputs(species, food, environment) |>
    with_column("FoodMassIngested", calculate_food_mass) |>
    with_column("dryOinflux", calculate_dry_oxygen_influx) |>
    with_column("dryHinflux", calculate_dry_hydrogen_influx) |>
    with_column("FreeH2Oinfood", calculate_free_water_in_food) |>
    with_column("WaterinFood", calculate_water_in_food) |>
    with_column("DrinkingH2OIngested", calculate_drinking_water_ingested) |>
    with_column("DrinkingWater", calculate_drinking_water)
}

#' Calculate effective food mass for metabolic processes
#' @param df Data frame containing FoodMassIngested, Digestibility, and EEE
#' @return Numeric vector of effective food mass (FoodMassIngested * Digestibility * EEE)
#' @keywords internal
calculate_effective_food_mass <- function(df) {
  df$FoodMassIngested * df$Digestibility * df$EEE
}

#' Calculate energy density of food
#' @param df Data frame containing values from Food function (macronutrient content in diet, energy content of macronutrient)
#' @return Numeric vector of energy densities (kJ/kg)
#' @keywords internal
calculate_energy_density <- function(df) {
  df$foodcarbcontent * df$foodcarbenergy +
    df$foodproteincontent * df$foodproteinenergy +
    df$foodfatcontent * df$foodfatenergy
}

#' Calculate food mass ingested
#' @param df Data frame containing values from Food function (Digestibility, EEE, energy density)
#' @return Numeric vector of food mass ingested (kg)
#' @keywords internal
calculate_food_mass <- function(df) {
  df$EnergyExp / (df$Digestibility * df$EEE * calculate_energy_density(df))
}

#' Calculate dry oxygen influx
#' @param df Data frame containing values from Food function (Digestibility, EEE, oxygen composition per macronutrient unit)
#' and
#' @return Numeric vector of dry oxygen influx (moles O2)
#' @keywords internal
calculate_dry_oxygen_influx <- function(df) {
  o_composition <- df$foodcarbcontent * df$Ocarb +
    df$foodproteincontent * df$Oprotein +
    df$foodfatcontent * df$Ofat
  calculate_effective_food_mass(df) * o_composition
}

#' Calculate dry hydrogen influx
#' @param df Data frame containing values from Food  function (Digestibility, EEE, hydrogen composition per macronutrient unit)
#' @return Numeric vector of dry hydrogen influx (moles H2)
#' @keywords internal
calculate_dry_hydrogen_influx <- function(df) {
  h_composition <- df$foodcarbcontent * df$Hcarb +
    df$foodproteincontent * df$Hprotein +
    df$foodfatcontent * df$Hfat

  calculate_effective_food_mass(df) * h_composition
}

#' Calculate free water in food
#' @param df Data frame containing values from Food function (freeH20food)
#' @return Numeric vector of free water in food (moles H2O)
#' @keywords internal
calculate_free_water_in_food <- function(df) {
  mole_water <- 55.56
  df$FoodMassIngested * mole_water * (df$freeH20food / (1 - df$freeH20food))
}

#' Calculate water in food (vapor)
#' @param df Data frame containing FreeH2Oinfood
#' @return Numeric vector of water vapor from food (moles H2O)
#' @keywords internal
calculate_water_in_food <- function(df) {
  df$FreeH2Oinfood / 2
}

#' Calculate drinking water ingested
#' @param df Data frame containing values from Species (TotalH2OTurnover) and Environment (WVinLungs) functions
#' combined with previously calculated values in Inputs function (FreeH2Oinfood, dryHinflux)
#' @return Numeric vector of exogenous water ingested (moles H2O)
#' @keywords internal
calculate_drinking_water_ingested <- function(df) {
  df$TotalH2OTurnover - df$FreeH2Oinfood - df$dryHinflux - df$WVinLungs
}

#' Calculate drinking water (vapor)
#' @param df Data frame containing DrinkingH2OIngested
#' @return Numeric vector of drinking water vapor (moles H2O)
#' @keywords internal
calculate_drinking_water <- function(df) {
  df$DrinkingH2OIngested / 2
}
