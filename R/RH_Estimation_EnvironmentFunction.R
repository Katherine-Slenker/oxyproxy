#' Calculates water and oxygen fluxes as affected by environmental conditions.
#'
#' Given values air temperature and oxygen-18 enrichment of surface waters, and
#' computes values for mean annual temperature (MAT), oxygen-18 enrichment
#' of inhaled air (dairH2O), and the difference in oxygen-18 enrichment between
#' air and source water (dairH2OSW).
#' @param air_temperature Numeric. Air temperature ( deg C) of environment. Must be
#' provided; 0 and negative values are valid.
#' @param d18O_surface_water Numeric. d18O values of local surface water (per mil VSMOW).
#'  Must be provided; 0 and negative values are valid.
#'
#' @return A data frame with all combinations of input values and 5 columns:
#' \itemize{
#'   \item airtemp - Air temperature ( deg C)
#'   \item MAT - Mean annual temperature ( deg K)
#'   \item d18Osw - d18O enrichment of surface water (per mil)
#'   \item dairH2O - d18O enirchment of inhaled air (per mil)
#'   \item dairH2OSW - Difference between air and surface water d18O enrichment (per mil)
#'   }
#'
#' @examples
#' # Example usage with vector inputs
#' rh_estimation_environment_function(
#'   air_temperature = c(10, 20),
#'   d18O_surface_water = c(-2, -5)
#' )
#'
#' @export
### SET FUNCTION FOR ENVIRONMENT

rh_estimation_environment_function <- function(air_temperature = numeric(0), d18O_surface_water = numeric(0)) {
  ## 0. VALIDATING ARGUMENTS =====================================================
  if (length(air_temperature) == 0) {
    stop("Enter Air Temperature value")
  }
  if (length(d18O_surface_water) == 0) {
    stop("Enter d18Osw value")
  }

  n_air <- length(air_temperature)
  n_sw <- length(d18O_surface_water)

  # FILLING DATAFRAME WITH ARGUMENTS VALUES
  # One row per combination: airtemp varies fastest, then d18Osw

  # air temperature (C)
  airtemp <- rep(air_temperature, times = n_sw)

  # mean annual temperature (K)
  MAT <- airtemp + 273

  # d18Osurfacewater
  d18Osw <- rep(d18O_surface_water, each = n_air)


  ### 1. ADDING D18O SURFACE WATER TO CALCULATION ===============================

  dairH2O <- calculate_dair_h2o(d18Osw, MAT)

  # dairH2OSW <- dairH2O -d18Osw
  dairH2OSW <- dairH2O - d18Osw

  data.frame(airtemp, MAT, d18Osw, dairH2O, dairH2OSW, row.names = NULL)
}
