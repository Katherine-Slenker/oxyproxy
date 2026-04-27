#' Calculate estimate of oxygen-18 enrichment of animal bodywater based on
#' flux of oxygen input and outputs.
#'
#' This function combines the Species, Inputs, and Outputs functions to generate estimates of oxygen-18 enrichment of animal bodywater, enamel-phosphate,
#'  and enamel-carbonate.
#'
#' @param Species Data frame containing species physiological parameters.
#' @param Inputs Data frame containing oxygen input data.
#' @param Outputs Data frame containing oxygen output data.
#'    \describe{
#'    \item{MolesO2Air}{Numeric. Moles of oxygen from air}
#'     \item{d18Oairtakenup}{Numeric. }
#'     \item{WV}{Numeric. Water vapor in the atmosphere.}
#'     \item{dairH2OSW}{Numeric. }
#'     \item{dfoodO2SW}{Numeric. }
#'     \item{dryOinflux}{Numeric. Dry oxygen influx}
#'     \item{dfoodH2Osw}{Numeric.}
#'     \item{WaterinFood}{Numeric.}
#'     \item{DrinkingWater}{Numeric.}
#'     \item{WVCO2}{Numeric.}
#'     \item{WVNose}{Numeric.}
#'     \item{WVMouth}{Numeric.}
#'     \item{WVSkin}{Numeric.}
#'     \item{WVSweat}{Numeric.}
#'     \item{WVUrine}{Numeric.}
#'     \item{WVFecal}{Numeric.}
#'     \item{Urea}{Numeric.}
#'     \item{d18Osw}{Numeric.}
#'     }


#' @return Data frame with estimated δ¹⁸Obw, δ¹⁸Oenamel-phosphate, and δ¹⁸Oenamel-carbonate.
#'
#' @examples
#' # Example for a herbivore
#' herbivore_data <- data.frame(
#'   MolesO2Air =
#'   d18Oairtakenup =
#'   WV =
#'   dairH2OSW =
#'   dfoodO2SW =
#'   dryOinflux =
#'   dfoodH2Osw =
#'   WaterinFood =
#'   DrinkingWater =
#'   WVCO2 =
#'   WVNose =
#'   WVMouth =
#'   WVSkin =
#'   WVSweat =
#'   WVUrine =
#'   WVFecal =
#'   Urea =
#'   d18Osw =
#' )
#'
#'# Calculate outputs for non-sweating species (default)
#' herbivore_d18OBW <- d18_obw_functionn(herbivore_data)
#'
#'
#' @export
###SET d18OBODYWATER FUNCTION
d18_obw_function <- function(outputs=0)
{

  ## 0. PREPPING DATAFRAME FOR OUTPUTS ===========================================
  # Width = number of variables from  OUTPUTS dataframe + the three d180 computed here
  # Length = number of rows from OUTPUTS dataframe
  DF_outputs <- outputs
  DF_outputs_temp <- matrix(data = 0, nrow = nrow(outputs), ncol = 3)
  colnames(DF_outputs_temp) <- c("d18Obw", "d18Ophos", "d18Ocarb")
  DF_outputs_temp <- as.data.frame(DF_outputs_temp)
  DF_outputs <- cbind(DF_outputs, DF_outputs_temp)


  #d18Obw <- ((MolesO2Air * d18Oairtakenup + WV * dairH2OSW + dfoodO2SW * dryOinflux + dfoodH2Osw * WaterinFood + DrinkingWater * 0) - (WVCO2 * 38.6 + WVMouth * -8.2 + WVNose * -17 + WVSkin * -18 + WVSweat * 0 + WVUrine * 0 + WVFecal * 0)) / (((WVCO2 + WVMouth + WVNose + WVSkin + WVSweat + WVUrine + WVFecal + Urea)+(DrinkingWater *d18Osw + WV * d18Osw + WaterinFood * d18Osw + dryOinflux * d18Osw))/(WVCO2 + WVMouth + WVNose + WVSkin + WVSweat + WVUrine + WVFecal + 0.2))
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$d18Obw[i] <- ((DF_outputs$MolesO2Air[i] * DF_outputs$d18Oairtakenup[i] + DF_outputs$WV[i] * DF_outputs$dairH2OSW[i] + DF_outputs$dfoodO2SW[i] * DF_outputs$dryOinflux[i] + DF_outputs$dfoodH2Osw[i] * DF_outputs$WaterinFood[i] + DF_outputs$DrinkingWater[i] * 0) - (DF_outputs$WVCO2[i] * 38.6 + DF_outputs$WVMouth[i] * -8.2 + DF_outputs$WVNose[i] * -17 + DF_outputs$WVSkin[i] * -18 + DF_outputs$WVSweat[i] * 0 + DF_outputs$WVUrine[i] * 0 + DF_outputs$WVFecal[i] * 0)) / (DF_outputs$WVCO2[i] + DF_outputs$WVMouth[i] + DF_outputs$WVNose[i] + DF_outputs$WVSkin[i] + DF_outputs$WVSweat[i] + DF_outputs$WVUrine[i] + DF_outputs$WVFecal[i] + DF_outputs$Urea[i]) + (DF_outputs$DrinkingWater[i] *  DF_outputs$d18Osw[i] + DF_outputs$WV[i] *  DF_outputs$d18Osw[i] + DF_outputs$WaterinFood[i] *  DF_outputs$d18Osw[i] + DF_outputs$dryOinflux[i] *  DF_outputs$d18Osw[i]) / (DF_outputs$WVCO2[i] + DF_outputs$WVMouth[i] + DF_outputs$WVNose[i] + DF_outputs$WVSkin[i] + DF_outputs$WVSweat[i] + DF_outputs$WVUrine[i] + DF_outputs$WVFecal[i] + DF_outputs$Urea[i])

    #d18Ophosphate = d18Obw + 25.9 - 37 / 4.38
    DF_outputs$d18Ophos[i] <- DF_outputs$d18Obw[i] + 25.9 - 37 / 4.38

    #d18Ocarbonate = d18Ophosphate + 8.5
    DF_outputs$d18Ocarb[i] <- DF_outputs$d18Ophos[i] + 8.5

  }

  #message("d18O body water, d180 phosphate, d180 carbonate : ")
  print(DF_outputs[,c("d18Obw", "d18Ophos", "d18Ocarb")])

  return(DF_outputs)
}
