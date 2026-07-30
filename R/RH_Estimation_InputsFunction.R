#' Calculate all variables of oxygen input from physiology, diet, and environment.
#'
#' This function combines the Species, Food, and RH_Estimation Environment functions to calculate
#' oxygen inputs to generate estimates of relative humidity.
#'
#' @param species Data frame containing species physiological parameters.
#'   Must include: EnergyExp, TotalH2OTurnover
#' @param food Data frame containing food composition data.
#'   Must include: Digestibility, EEE, foodcarbcontent, foodcarbenergy, Ocarb,
#'   Hcarb, foodproteincontent, foodproteinenergy, Oprotein, Hprotein,
#'   foodfatcontent, foodfatenergy, Ofat, Hfat,  and freeH20food.
#' @param environment Data frame from rh_estimation_environment_function(),
#'   i.e. environmental parameters excluding relative humidity and everything
#'   derived from it.
#' @return Data frame with all input combinations and calculated physiological
#'         variables:
#'   \itemize{
#'     \item FoodMassIngested - Mass of food consumed (kg)
#'     \item dryOinflux - Dry oxygen influx from food (moles O2)
#'     \item dryHinflux - Dry hydrogen influx from food (moles H2)
#'     \item FreeH2Oinfood - Free water content in food (moles H2O)
#'     \item WaterinFood - Water vapor from food (half of free water) (moles H2O)
#'   }
#' @examples
#' # Create example data
#' species_data <- data.frame(
#'   EnergyExp = 5000,
#'   TotalH2OTurnover = 1000
#' )
#'
#' food_data <- data.frame(
#'   Digestibility = 0.85,
#'   EEE = 0.95,
#'   foodcarbcontent = 0.6, foodcarbenergy = 17,
#'   foodproteincontent = 0.25, foodproteinenergy = 23,
#'   foodfatcontent = 0.05, foodfatenergy = 39,
#'   Ocarb = 1.33, Oprotein = 1.41, Ofat = 2.9,
#'   Hcarb = 1.51, Hprotein = 1.29, Hfat = 1.94,
#'   freeH20food = 0.75
#' )
#'
#' # As returned by rh_estimation_environment_function()
#' environment_data <- rh_estimation_environment_function(
#'   air_temperature = 25,
#'   d18O_surface_water = -5
#' )
#'
#' result <- inverse_input_function(
#'   species = species_data,
#'   food = food_data,
#'   environment = environment_data
#' )
#'
#' @export
###SET INPUT FUNCTION
inverse_input_function <- function(species=0, food=0, environment=0)
{
  ## 0. PREPPING DATAFRAME FOR OUTPUTS ===========================================
  # Width = number of variables
  # Length = number of combination of results
  # Dataframe size is determined by Species x Food x Environment dataframe
  n_species <- nrow(species)
  n_food    <- nrow(food)
  n_env     <- nrow(environment)
  n_rows    <- n_species * n_food * n_env

  DF_outputs <- matrix(data = 0, nrow = n_rows, ncol = ncol(species)+ncol(food)+ncol(environment)+5)
  colnames(DF_outputs) <- c(colnames(species), colnames(food), colnames(environment),
                            "FoodMassIngested", "dryOinflux", "dryHinflux", "FreeH2Oinfood",
                            "WaterinFood")
  DF_outputs <- as.data.frame(DF_outputs)

  ## 1. FILLING IT WITH PREVIOUS DATA COMING FROM FOOD SPECIES AND ENVIRONMENT FUNCTION
  ### THIS FOLLOWING ALGORITHM IS MADE TO FIND ALL COMBINATION OF VALUES TO COMPUTE THE INPUTS VALUES IN THE NEXT STEPS
  # Full factorial: species cycles fastest, food is blocked slowest, environment
  # sits between the two. Indexing once per source frame keeps this linear in
  # n_rows -- growing the frame a row at a time made large grids unusable.
  DF_outputs[,colnames(species)] <- species[rep(seq_len(n_species), length.out = n_rows), , drop = FALSE]
  DF_outputs[,colnames(food)]    <- food[rep(seq_len(n_food), each = n_rows/n_food), , drop = FALSE]

  env_block <- rep(seq_len(n_env), each = n_rows/n_env/n_food)
  DF_outputs[,colnames(environment)] <-
    environment[env_block[rep(seq_along(env_block), length.out = n_rows)], , drop = FALSE]

  ## 2. COMPUTATION OF INPUT VARIABLES

  #Food Mass Ingested = (Energy Exp)/ (Digestibility*EEE*(foodcarbcontent * foodcarbernergy + foodproteincontent * foodproteinenergy + foodfatcontent * foodfatenergy))
  DF_outputs$FoodMassIngested <- DF_outputs$EnergyExp /
    (DF_outputs$Digestibility * DF_outputs$EEE *
       (DF_outputs$foodcarbcontent * DF_outputs$foodcarbenergy +
          DF_outputs$foodproteincontent * DF_outputs$foodproteinenergy +
          DF_outputs$foodfatcontent * DF_outputs$foodfatenergy))

  # dry O influx = Digestibility * EEE * FoodMassIngested * (foodcarbcontent *Ocarb + foodproteincontent * Oprotein + foodfatcontent * Ofat)
  DF_outputs$dryOinflux <- DF_outputs$Digestibility * DF_outputs$EEE * DF_outputs$FoodMassIngested *
    (DF_outputs$foodcarbcontent * DF_outputs$Ocarb +
       DF_outputs$foodproteincontent * DF_outputs$Oprotein +
       DF_outputs$foodfatcontent * DF_outputs$Ofat)

  #dry H influx = Digestibility * EEE * FoodMassIngested * (foodcarbcontent *Hcarb + foodproteincontent * Hprotein + foodfatcontent * Hfat)
  DF_outputs$dryHinflux <- DF_outputs$Digestibility * DF_outputs$EEE * DF_outputs$FoodMassIngested *
    (DF_outputs$foodcarbcontent * DF_outputs$Hcarb +
       DF_outputs$foodproteincontent * DF_outputs$Hprotein +
       DF_outputs$foodfatcontent * DF_outputs$Hfat)

  #Free H2O in food = Food Mass Ingested * 55.56 * (Free H2O of food/(1-free H20 of food))
  DF_outputs$FreeH2Oinfood <- DF_outputs$FoodMassIngested * 55.56 *
    (DF_outputs$freeH20food / (1 - DF_outputs$freeH20food))

  #Water in Food = Free Water in Food / 2
  DF_outputs$WaterinFood <- DF_outputs$FreeH2Oinfood / 2

  return(DF_outputs)
}
