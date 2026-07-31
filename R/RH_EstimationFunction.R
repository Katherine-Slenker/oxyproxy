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
rh_function <- function(rh_estimation_d18O = 0, outputs = 0, printinfo = FALSE) {
  DF_outputs <- merge(outputs, rh_estimation_d18O)
  if (nrow(DF_outputs) == 0) {
    stop("rh_estimation_d18O and outputs cannot be empty")
  }
  DF_outputs_temp <- matrix(data = 0, nrow = nrow(DF_outputs), ncol = 9)
  colnames(DF_outputs_temp) <- c(
    "Humidity", "WVinLungs", "WV",
    "d18OleafH2O", "d18Oleafcellulose", "dfoodO2SW",
    "dfoodH2Osw", "DrinkingH2OIngested", "DrinkingWater"
  )
  DF_outputs_temp <- as.data.frame(DF_outputs_temp)
  DF_outputs <- cbind(DF_outputs, DF_outputs_temp)

  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$Humidity[i] <- (DF_outputs$d18Obodywater[i] * (DF_outputs$WVCO2[i] + DF_outputs$WVMouth[i] + DF_outputs$WVNose[i] +
      DF_outputs$WVSkin[i] + DF_outputs$WVSweat[i] + DF_outputs$WVUrine[i] +
      DF_outputs$WVFecal[i] + DF_outputs$Urea[i]) -
      (DF_outputs$MolesO2Air[i] * DF_outputs$d18Oairtakenup[i] - (DF_outputs$WVCO2[i] * 38.6 + DF_outputs$WVMouth[i] * -8.2 + DF_outputs$WVNose[i] * -17 + DF_outputs$WVSkin[i] * -18 + DF_outputs$WVSweat[i] * 0 + DF_outputs$WVUrine[i] * 0 + DF_outputs$WVFecal[i] * 0)) -
      ((DF_outputs$d18Osw[i] - DF_outputs$dairH2O[i] + 43) * DF_outputs$dryOinflux[i]) -
      (0.5 * (DF_outputs$d18Osw[i] - DF_outputs$dairH2O[i] + 16) * DF_outputs$WaterinFood[i]) -
      ((0.5 * (DF_outputs$TotalH2OTurnover[i] - DF_outputs$FreeH2Oinfood[i] - DF_outputs$dryHinflux[i]) * DF_outputs$d18Osw[i])) -
      (DF_outputs$WaterinFood[i] * DF_outputs$d18Osw[i]) -
      (DF_outputs$dryOinflux[i] * DF_outputs$d18Osw[i])) /
      (((10^(0.686 + 0.027 * DF_outputs$airtemp[i])) * (12400 / (760 * 22.4)) * (DF_outputs$dairH2OSW[i] / 2)) - ((DF_outputs$d18Osw[i] - DF_outputs$dairH2O[i] + 16) * DF_outputs$dryOinflux[i]) - (0.5 * (DF_outputs$d18Osw[i] - DF_outputs$dairH2O[i] + 16) * DF_outputs$WaterinFood[i]))
  }

  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$WVinLungs[i] <- DF_outputs$Humidity[i] * (10^(0.686 + 0.027 * DF_outputs$airtemp[i])) * 12400 / (760 * 22.4)
  }

  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$WV[i] <- DF_outputs$WVinLungs[i] / 2
  }

  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$d18OleafH2O[i] <- DF_outputs$d18Osw[i] + (1 - DF_outputs$Humidity[i]) * (DF_outputs$d18Osw[i] - DF_outputs$dairH2O[i] + 16)
  }

  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$d18Oleafcellulose[i] <- DF_outputs$d18OleafH2O[i] + 27
  }

  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$dfoodO2SW[i] <- DF_outputs$d18Oleafcellulose[i] - DF_outputs$d18Osw[i]
  }

  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$dfoodH2Osw[i] <- (0.5 * DF_outputs$d18Osw[i] + 0.5 * DF_outputs$d18OleafH2O[i]) - DF_outputs$d18Osw[i]
  }

  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$DrinkingH2OIngested[i] <- DF_outputs$TotalH2OTurnover[i] - DF_outputs$FreeH2Oinfood[i] - DF_outputs$dryHinflux[i] - DF_outputs$WVinLungs[i]
  }

  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$DrinkingWater[i] <- DF_outputs$DrinkingH2OIngested[i] / 2
  }

  if (printinfo == TRUE) {
    message("Humidity: ")
    print(paste(round(DF_outputs[, c("Humidity")] * 100), "%"))
  }

  return(DF_outputs)
}
