#' Calculates estimates of relative humidity and variables that are dependent
#' on values of relative humidity that are needed to calculate oxygen-18 enrichment
#' of animal body water.
#'
#' This function combines the rh_estimation_d18O, Species, Food,
#' RH_Estimation_Environment, RH_Estimation_Inputs, and Outputs functions to calculate
#' estimates of relative humidity and variables that are dependent upon relative
#' humidity values, including water vapor in the lungs, water vapor in  the
#' atmosphere, oxygen-18 enrichment of  leaf water and cellulose, the difference
#' in oxygen-18 enrichment between oxygen in food and surface waters (dfoodO2SW),
#' water in food and surface waters (dfoodH2Osw), and drinking water ingested
#' (DrinkingH2OIngested) and drinking water vapor (DrinkingWater) These
#' calculations assume that the oxygen-18 enrichment of stem water is equivalent
#' to that of surface waters.
#'
#' @param rh_estimation_d18O Data frame containing d18Obodywater values, as
#'   returned by [d18O_enamel()].
#' @param outputs Data frame of oxygen output data, as returned by
#'   [outputs_function()].
#' @param printinfo Logical. If TRUE, prints the computed Humidity values.
#'
#' @return Data frame relative humidity estimates and values of dependent variables.
#'
#' @examples
#' # herbivore_d18OBW <- rh_function(df)
#'
#' @export
### SET VARIABLE-OF-INTEREST FUNCTION (EX:RELATIVE HUMIDITY)
rh_function <- function(rh_estimation_d18O = 0, outputs = 0, printinfo = FALSE) {
  ### PREPPING DATASET =========================================================
  DF_outputs <- merge(outputs, rh_estimation_d18O)
  if (nrow(DF_outputs) == 0) {
    stop("rh_estimation_d18O and outputs cannot be empty")
  }

  ### HUMIDITY COMPUTATION FROM Outputs
  fractional_outputs <- calculate_fractional_outputs(DF_outputs)
  total_outputs <- calculate_total_outputs(DF_outputs)

  # Leaf-water offset, and its cellulose equivalent (43 = 16 + 27)
  leaf_offset <- calculate_leaf_offset(DF_outputs$d18Osw, DF_outputs$dairH2O)
  cellulose_offset <- DF_outputs$d18Osw - DF_outputs$dairH2O + 43

  saturation_vapor_pressure <- calculate_saturation_vapor_pressure(DF_outputs$airtemp)

  humidity_numerator <- DF_outputs$d18Obodywater * total_outputs -
    (DF_outputs$MolesO2Air * DF_outputs$d18Oairtakenup - fractional_outputs) -
    cellulose_offset * DF_outputs$dryOinflux -
    0.5 * leaf_offset * DF_outputs$WaterinFood -
    0.5 * (DF_outputs$TotalH2OTurnover - DF_outputs$FreeH2Oinfood - DF_outputs$dryHinflux) *
      DF_outputs$d18Osw -
    DF_outputs$WaterinFood * DF_outputs$d18Osw -
    DF_outputs$dryOinflux * DF_outputs$d18Osw

  humidity_denominator <- saturation_vapor_pressure * (12400 / (760 * 22.4)) *
    (DF_outputs$dairH2OSW / 2) -
    leaf_offset * DF_outputs$dryOinflux -
    0.5 * leaf_offset * DF_outputs$WaterinFood

  DF_outputs$Humidity <- humidity_numerator / humidity_denominator

  DF_outputs$WVinLungs <- calculate_wv_in_lungs(DF_outputs$Humidity, DF_outputs$airtemp)

  # Water Vapor <- Water Vapor in Lungs / 2
  DF_outputs$WV <- DF_outputs$WVinLungs / 2

  # d18OleafH2O, d18Oleafcellulose, dfoodO2SW, dfoodH2Osw
  leaf_and_food <- calculate_leaf_and_food_d18O(DF_outputs$d18Osw, DF_outputs$dairH2O, DF_outputs$Humidity)
  DF_outputs[names(leaf_and_food)] <- leaf_and_food

  # Drinking H2O Ingested = Total H2O Turnover - free H2O in food - dry food H influx - water vapor in lungs
  DF_outputs$DrinkingH2OIngested <- calculate_drinking_water_ingested(DF_outputs)

  DF_outputs$DrinkingWater <- calculate_drinking_water(DF_outputs)

  if (printinfo == TRUE) {
    message("Humidity: ")
    print(paste(round(DF_outputs$Humidity * 100), "%"))
  }

  DF_outputs
}
