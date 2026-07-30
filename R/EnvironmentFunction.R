#' Calculates water and oxygen fluxes as affected by environmental conditions
#'
#' Given values air temperature, oxygen-18 enrichment of surface waters, and
#' relative humidity, computes values for mean annual temperature (MAT);
#' water vapor in the lungs; water vapor in  the atmosphere; oxygen-18 enrichment
#' of inhaled air (dairH2O), leaf water, and cellulose; and the difference in oxygen-18
#' enrichment between air and source water (dairH2OSW), oxygen in food and surface
#' waters (dfoodO2SW), water in food and surface waters (dfoodH2Osw). These
#' calculations assume that the oxygen-18 enrichment of stem water is equivalent
#' to that of surface waters.
#'
#' @param air_temperature Numeric. Air temperature ( deg C) of environment. Must be
#' provided; 0 and negative values are valid.
#' @param relative_humidity Numeric. Relative humidity of environment. Must be
#' between 0 and 1.
#' @param d18O_surface_water Numeric. d18O values of local surface water (per mil VSMOW).
#'  Must be provided.
#'
#' @return A data frame with all combinations of input values and 12 columns:
#' \itemize{
#'   \item airtemp - Air temperature ( deg C)
#'   \item MAT - Mean annual temperature ( deg K)
#'   \item Humidity - Relative humidity (proportion, 0-1)
#'   \item WVinLungs - Water vapor taken in lungs via respiration (mol)
#'   \item WV - Atmospheric water vapor (mol)
#'   \item d18Osw - d18O enrichment of surface water (per mil)
#'   \item dairH2O - d18O enirchment of inhaled air (per mil)
#'   \item dairH2OSW - Difference between air and surface water d18O enrichment (per mil)
#'   \item d18OleafH2O - d18O enrichment of leaf water (per mil)
#'   \item d18Oleafcellulose - d18O enrichment of leaf cellulose (per mil)
#'   \item dfoodO2SW - d18O enrichment of food oxygen relative to surface water (per mil)
#'   \item dfoodH2Osw - d18O enrichment of food water relative to surface water (per mil)
#' }
#'
#' @examples
#' # Example usage with vector inputs
#' environment_function(
#'   air_temperature = c(10, 20),
#'   relative_humidity = c(0.5, 0.75),
#'   d18O_surface_water = c(-2, -5)
#' )
#'
#' @export

### SET FUNCTION FOR ENVIRONMENT

environment_function <- function(air_temperature = numeric(0), relative_humidity = numeric(0), d18O_surface_water = numeric(0)) {
  ## 0. VALIDATING ARGUMENTS =====================================================
  if (length(air_temperature) == 0) {
    stop("Enter Air Temperature value (in  deg C)")
  }
  if (length(relative_humidity) == 0) {
    stop("Enter Relative Humidity value between 0 and 1 (%)")
  }
  if (length(d18O_surface_water) == 0) {
    stop("Enter d18Osw value per mil")
  }

  ## 1. PREPPING DATAFRAME FOR OUTPUTS ===========================================
  # Width = number of variables
  # Length = number of combination of results
  DF_outputs <- matrix(data = 0, nrow = length(air_temperature) * length(relative_humidity) * length(d18O_surface_water), ncol = 12)
  colnames(DF_outputs) <- c(
    "airtemp", "MAT", "Humidity", "WVinLungs", "WV", "d18Osw", "dairH2O",
    "dairH2OSW", "d18OleafH2O", "d18Oleafcellulose", "dfoodO2SW", "dfoodH2Osw"
  )
  DF_outputs <- as.data.frame(DF_outputs)

  # FILLING DATAFRAME WITH ARGUMENTS VALUES

  # air temperature (C)
  airtemp <- air_temperature
  DF_outputs$airtemp <- airtemp

  # mean annual temperature (K)OE
  MAT <- airtemp + 273
  DF_outputs$MAT <- MAT

  # Humidity
  Humidity <- relative_humidity
  DF_outputs_Humidity_temp <- c()
  for (i in seq_along(Humidity)) {
    DF_outputs_Humidity_temp <- c(DF_outputs_Humidity_temp, rep(Humidity[i], nrow(DF_outputs) / length(Humidity)))
  } ## the dataframe is split in X part for X values of humidity
  DF_outputs$Humidity <- DF_outputs_Humidity_temp

  # d18Osurfacewater
  d18Osw <- d18O_surface_water
  DF_outputs_d18Osw_temp <- c()
  for (i in seq_along(d18Osw)) {
    DF_outputs_d18Osw_temp <- c(DF_outputs_d18Osw_temp, rep(d18Osw[i], nrow(DF_outputs) / length(Humidity) / length(d18Osw)))
  }
  DF_outputs_d18Osw_temp <- rep(DF_outputs_d18Osw_temp, length(Humidity))
  DF_outputs$d18Osw <- DF_outputs_d18Osw_temp


  ### 1. CALCULATION WITH HUMIDITY AND AIR TEMPERATURE =========================

  # Water Vapor Taken in Lungs <- Humidity * 10^(0.686+0.027*airtemp) * 12400/(760*22.4)
  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$WVinLungs[i] <- DF_outputs$Humidity[i] * (10^(0.686 + 0.027 * DF_outputs$airtemp[i])) * 12400 / (760 * 22.4)
  }

  # Water Vapor <- Water Vapor in Lungs / 2
  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$WV[i] <- DF_outputs$WVinLungs[i] / 2
  }

  ### 2. ADDING D18 SURFACE WATER TO CALCULATION ===============================

  # dairH2O <- d18Osw - 2.644 + 3206/MAT - 1.534 * 10^6 / MAT^2
  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$dairH2O[i] <- DF_outputs$d18Osw[i] - 2.644 + 3206 / DF_outputs$MAT[i] - 1.534 * (10^6) / (DF_outputs$MAT[i]^2)
  }

  # dairH2OSW <- dairH2O -d18Osw
  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$dairH2OSW[i] <- DF_outputs$dairH2O[i] - DF_outputs$d18Osw[i]
  }

  # d18OleafH2O <-d18Osw + (1-Humidity) * (d18Osw - dairH2O + 16)
  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$d18OleafH2O[i] <- DF_outputs$d18Osw[i] + (1 - DF_outputs$Humidity[i]) * (DF_outputs$d18Osw[i] - DF_outputs$dairH2O[i] + 16)
  }

  # d18Oleafcellulose <- d18OleafH2O + 27
  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$d18Oleafcellulose[i] <- DF_outputs$d18OleafH2O[i] + 27
  }

  # dfoodO2SW <-d18Oleafcellulose - d18Osw
  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$dfoodO2SW[i] <- DF_outputs$d18Oleafcellulose[i] - DF_outputs$d18Osw[i]
  }

  # dfoodH2Osw  <- (0.5 * d18OstemH2O + 0.5 * d18OleafH2O) -d18Osw
  # d18OstemH2O = d18Osw
  for (i in seq_len(nrow(DF_outputs))) {
    DF_outputs$dfoodH2Osw[i] <- (0.5 * DF_outputs$d18Osw[i] + 0.5 * DF_outputs$d18OleafH2O[i]) - DF_outputs$d18Osw[i]
  }

  return(DF_outputs)
}
