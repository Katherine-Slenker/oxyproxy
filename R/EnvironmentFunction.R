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
#'  Must be provided; 0 and negative values are valid and typical.
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

environment_function <- function(
  air_temperature = numeric(0),
  relative_humidity = numeric(0),
  d18O_surface_water = numeric(0)
) {
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

  if (any(relative_humidity < 0) || any(relative_humidity > 1)) {
    stop("Enter Relative Humidity value between 0 and 1 (%)")
  }

  n_air <- length(air_temperature)
  n_rh <- length(relative_humidity)
  n_sw <- length(d18O_surface_water)

  # FILLING DATAFRAME WITH ARGUMENTS VALUES
  # One row per combination: airtemp varies fastest, then d18Osw, then Humidity

  # air temperature (C)
  airtemp <- rep(air_temperature, times = n_sw * n_rh)

  # mean annual temperature (K)
  MAT <- airtemp + 273

  # Humidity
  Humidity <- rep(relative_humidity, each = n_air * n_sw)
  # d18Osurfacewater
  d18Osw <- rep(d18O_surface_water, each = n_air, times = n_rh)


  ### 1. CALCULATION WITH HUMIDITY AND AIR TEMPERATURE =========================

  # Water Vapor Taken in Lungs <- Humidity * 10^(0.686+0.027*airtemp) * 12400/(760*22.4)
  WVinLungs <- Humidity * (10^(0.686 + 0.027 * airtemp)) * 12400 / (760 * 22.4)

  # Water Vapor <- Water Vapor in Lungs / 2
  WV <- WVinLungs / 2

  ### 2. ADDING D18 SURFACE WATER TO CALCULATION ===============================

  # dairH2O <- d18Osw - 2.644 + 3206/MAT - 1.534 * 10^6 / MAT^2
  dairH2O <- d18Osw - 2.644 + 3206 / MAT - 1.534 * (10^6) / (MAT^2)

  # dairH2OSW <- dairH2O -d18Osw
  dairH2OSW <- dairH2O - d18Osw

  # d18OleafH2O <-d18Osw + (1-Humidity) * (d18Osw - dairH2O + 16)
  d18OleafH2O <- d18Osw + (1 - Humidity) * (d18Osw - dairH2O + 16)

  # d18Oleafcellulose <- d18OleafH2O + 27
  d18Oleafcellulose <- d18OleafH2O + 27

  # dfoodO2SW <-d18Oleafcellulose - d18Osw
  dfoodO2SW <- d18Oleafcellulose - d18Osw

  # dfoodH2Osw  <- (0.5 * d18OstemH2O + 0.5 * d18OleafH2O) -d18Osw
  # d18OstemH2O = d18Osw
  dfoodH2Osw <- (0.5 * d18Osw + 0.5 * d18OleafH2O) - d18Osw

  data.frame(
    airtemp, MAT, Humidity, WVinLungs, WV, d18Osw, dairH2O,
    dairH2OSW, d18OleafH2O, d18Oleafcellulose, dfoodO2SW, dfoodH2Osw,
    row.names = NULL
  )
}
