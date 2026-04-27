#' Calculate all variables of oxygen input from physiology, diet, and environment.
#'
#' This function combines the Species, Food, and RH_Estimation Environment functions to calculate
#' oxygen inputs to generate estimates of relative humidity.
#'
#' @param Species Data frame containing species physiological parameters.
#'   Must include: EnergyExp, TotalH2OTurnover, WVinLungs
#' @param Food Data frame containing food composition data.
#'   Must include: Digestibility, EEE, foodcarbcontent, foodcarbenergy, Ocarb,
#'   Hcarb, foodproteincontent, foodproteinenergy, Oprotein, Hprotein,
#'   foodfatcontent, foodfatenergy, Ofat, Hfat,  and freeH20food.
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
#'   TotalH2OTurnover = 1000,
#'   WVinLungs = 50
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
#' environment_data <- data.frame(
#'   Temperature = 25,
#' )
#'
#' result <- input_function(
#'   species = species_data,
#'   food = food_data,
#'   environment = environment_data
#' )
#'
#' @export
###SET INPUT FUNCTION
inverse_input_function <- function(Species=0,Food=0,RH_Estimation_EnvironmentFunction=0)
{
  ## 0. PREPPING DATAFRAME FOR OUTPUTS ===========================================
  # Width = number of variables
  # Length = number of combination of results
  # Dataframe size is determined by Species x Food x Environment dataframe
  DF_outputs <- matrix(data = 0, nrow = nrow(Species)*nrow(Food)*nrow(Environment), ncol = ncol(Species)+ncol(Food)+ncol(Environment)+5)
  colnames(DF_outputs) <- c(colnames(Species), colnames(Food), colnames(Environment),
                            "FoodMassIngested", "dryOinflux", "dryHinflux", "FreeH2Oinfood",
                            "WaterinFood")
  DF_outputs <- as.data.frame(DF_outputs)

  ## 1. FILLING IT WITH PREVIOUS DATA COMING FROM FOOD SPECIES AND ENVIRONMENT FUNCTION
  ### THIS FOLLOWING ALGORITHM IS MADE TO FIND ALL COMBINATION OF VALUES TO COMPUTE THE INPUTS VALUES IN THE NEXT STEPS
  DF_outputs[,colnames(Species)] <- Species

  DF_outputs_Food_temp <- c()
  for(i in 1:nrow(Food)){
    for(j in 1:(nrow(DF_outputs)/nrow(Food))){
      DF_outputs_Food_temp <- rbind(DF_outputs_Food_temp, Food[i,])}} ## the dataframe is split in X part for X unique rows of Food
  DF_outputs[,colnames(Food)] <- DF_outputs_Food_temp

  DF_outputs_Environment_temp <- c()
  for(i in 1:nrow(Environment)){
    for(j in 1:(nrow(DF_outputs)/nrow(Environment)/nrow(Food))){
      DF_outputs_Environment_temp <- rbind(DF_outputs_Environment_temp, Environment[i,])}} ## the dataframe is split in X part for X unique rows of Environment divided by number of row of Food
  if(nrow(Food) > 1)
  {
    DF_outputs[,colnames(Environment)] <- DF_outputs_Environment_temp[rep(1:nrow(DF_outputs_Environment_temp), times = (nrow(DF_outputs)/nrow(Food))),] ## temporary dataframe is replicated based on Food/Species ratio
  }
  if(nrow(Food) == 1)
  {
    DF_outputs[,colnames(Environment)] <-  DF_outputs_Environment_temp
  }


  #Check if this step is working correctly
  if(isTRUE(duplicated(DF_outputs)) == TRUE){stop}


  ## 2. COMPUTATION OF INPUT VARIABLES

  #Food Mass Ingested = (Energy Exp)/ (Digestibility*EEE*(foodcarbcontent * foodcarbernergy + foodproteincontent * foodproteinenergy + foodfatcontent * foodfatenergy))
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$FoodMassIngested[i] = (DF_outputs$EnergyExp[i]) / (DF_outputs$Digestibility[i]*DF_outputs$EEE[i]*(DF_outputs$foodcarbcontent[i] * DF_outputs$foodcarbenergy[i] + DF_outputs$foodproteincontent[i] * DF_outputs$foodproteinenergy[i] + DF_outputs$foodfatcontent[i] * DF_outputs$foodfatenergy[i]))

    # dry O influx = Digestibility * EEE * FoodMassIngested * (foodcarbcontent *Ocarb + foodproteincontent * Oprotein + foodfatcontent * Ofat)
    DF_outputs$dryOinflux[i] = DF_outputs$Digestibility[i] * DF_outputs$EEE[i] * DF_outputs$FoodMassIngested[i] * (DF_outputs$foodcarbcontent[i] * DF_outputs$Ocarb[i] + DF_outputs$foodproteincontent[i] * DF_outputs$Oprotein[i] + DF_outputs$foodfatcontent[i] * DF_outputs$Ofat[i])

    #dry H influx = Digestibility * EEE * FoodMassIngested * (foodcarbcontent *Hcarb + foodproteincontent * Hprotein + foodfatcontent * Hfat)
    DF_outputs$dryHinflux[i] <- DF_outputs$Digestibility[i] * DF_outputs$EEE[i] * DF_outputs$FoodMassIngested[i] * (DF_outputs$foodcarbcontent[i] * DF_outputs$Hcarb[i] + DF_outputs$foodproteincontent[i] * DF_outputs$Hprotein[i] + DF_outputs$foodfatcontent[i] * DF_outputs$Hfat[i])

    #Free H2O in food = Food Mass Ingested * 55.56 * (Free H2O of food/(1-free H20 of food))
    DF_outputs$FreeH2Oinfood[i] <- DF_outputs$FoodMassIngested[i]*55.56*(DF_outputs$freeH20food[i]/(1-DF_outputs$freeH20food[i]))

    #Water in Food = Free Water in Food / 2
    DF_outputs$WaterinFood[i] <- DF_outputs$FreeH2Oinfood[i]/2


  }

  return(DF_outputs)
}
