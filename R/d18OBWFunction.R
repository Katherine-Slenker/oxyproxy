#' Calculate estimate of oxygen-18 enrichment of animal bodywater based on
#' flux of oxygen input and outputs.
#'
#' This function combines the Species, Inputs, and Outputs functions
#' to generate estimates of oxygen-18 enrichment of animal bodywater, enamel-phosphate,
#'  and enamel-carbonate.
#'
#' @param outputs Data frame of oxygen output data, as returned by
#'   [outputs_function()]. Must carry the columns listed below.
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


#' @return Data frame with estimated d18Obw, d18Oenamel-phosphate, and d18Oenamel-carbonate.
#'
#' @examples
#' # One row of oxygen fluxes, as outputs_function() would return
#' herbivore_data <- data.frame(
#'   MolesO2Air = 0.42, d18Oairtakenup = 12, WV = 3, dairH2OSW = 2,
#'   dfoodO2SW = 10, dryOinflux = 0.08, dfoodH2Osw = 5, WaterinFood = 1,
#'   DrinkingWater = 2, WVCO2 = 0.1, WVNose = 0.3, WVMouth = 0.5,
#'   WVSkin = 1.5, WVSweat = 0, WVUrine = 1.6, WVFecal = 0.4,
#'   Urea = 0.2, d18Osw = -8
#' )
#'
#' d18_obw_function(outputs = herbivore_data)
#'
#' @export
### SET d18OBODYWATER FUNCTION
d18_obw_function <- function(outputs = 0) {
  required_cols <- c(
    "MolesO2Air", "d18Oairtakenup", "WV", "dairH2OSW", "dfoodO2SW", "dryOinflux",
    "dfoodH2Osw", "WaterinFood", "DrinkingWater", "WVCO2", "WVMouth", "WVNose",
    "WVSkin", "WVSweat", "WVUrine", "WVFecal", "Urea", "d18Osw"
  )
  check_required_columns(outputs, required_cols)

  if (nrow(outputs) == 0) {
    stop("outputs cannot be empty")
  }

  ## 0. PREPPING DATAFRAME FOR OUTPUTS ===========================================
  # Width = number of variables from  OUTPUTS dataframe + the three d180 computed here
  # Length = number of rows from OUTPUTS dataframe
  DF_outputs <- outputs


  enriched_inputs <- DF_outputs$MolesO2Air * DF_outputs$d18Oairtakenup +
    DF_outputs$WV * DF_outputs$dairH2OSW +
    DF_outputs$dfoodO2SW * DF_outputs$dryOinflux +
    DF_outputs$dfoodH2Osw * DF_outputs$WaterinFood +
    DF_outputs$DrinkingWater * 0

  fractional_outputs <- calculate_fractional_outputs(DF_outputs)
  total_outputs <- calculate_total_outputs(DF_outputs)

  surface_water_inputs <- DF_outputs$DrinkingWater * DF_outputs$d18Osw +
    DF_outputs$WV * DF_outputs$d18Osw +
    DF_outputs$WaterinFood * DF_outputs$d18Osw +
    DF_outputs$dryOinflux * DF_outputs$d18Osw

  DF_outputs$d18Obw <- (enriched_inputs - fractional_outputs) / total_outputs +
    surface_water_inputs / total_outputs

  # d18Ophosphate = d18Obw + 25.9 - 37 / 4.38
  DF_outputs$d18Ophos <- DF_outputs$d18Obw + PHOSPHATE_WATER_INTERCEPT - PHOSPHATE_WATER_OFFSET

  # d18Ocarbonate = d18Ophosphate + 8.5
  DF_outputs$d18Ocarb <- DF_outputs$d18Ophos + CARBONATE_PHOSPHATE_OFFSET

  # message("d18O body water, d180 phosphate, d180 carbonate : ")
  print(DF_outputs[, c("d18Obw", "d18Ophos", "d18Ocarb")])

  DF_outputs
}

# Enamel conversion constants. d18O_enamel() applies them in reverse.
# d18Ophosphate = d18Obw + 25.9 - 37 / 4.38
PHOSPHATE_WATER_INTERCEPT <- 25.9
PHOSPHATE_WATER_OFFSET <- 37 / 4.38
# d18Ocarbonate = d18Ophosphate + 8.5
CARBONATE_PHOSPHATE_OFFSET <- 8.5
