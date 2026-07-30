#'Calculates water and oxygen fluxes as affected by environmental conditions.
#'
#'Given values air temperature and oxygen-18 enrichment of surface waters, and
#'computes values for mean annual temperature (MAT), oxygen-18 enrichment
#'of inhaled air (dairH2O), and the difference in oxygen-18 enrichment between
#'air and source water (dairH2OSW).
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
###SET FUNCTION FOR ENVIRONMENT

rh_estimation_environment_function <- function(air_temperature=numeric(0), d18O_surface_water=numeric(0)) {

  ## 0. VALIDATING ARGUMENTS =====================================================
  if(length(air_temperature)==0)
  {
    stop("Enter Air Temperature value")
  }
  if(length(d18O_surface_water)==0)
  {
    stop("Enter d18Osw value")
  }

  ## 1. PREPPING DATAFRAME FOR OUTPUTS ===========================================
  # Width = number of variables
  # Length = number of combination of results
  DF_outputs <- matrix(data = 0, nrow = length(air_temperature)*length(d18O_surface_water), ncol = 5)
  colnames(DF_outputs) <- c("airtemp", "MAT", "d18Osw", "dairH2O",
                            "dairH2OSW")
  DF_outputs <- as.data.frame(DF_outputs)

  #FILLING DATAFRAME WITH ARGUMENTS VALUES

  # air temperature (C)
  airtemp <- air_temperature
  DF_outputs$airtemp <- airtemp

  # mean annual temperature (K)OE
  MAT <- airtemp +273
  DF_outputs$MAT <- MAT

  # d18Osurfacewater
  d18Osw <- d18O_surface_water
  DF_outputs_d18Osw_temp <- c()
  for(i in 1:length(d18Osw)){
    DF_outputs_d18Osw_temp <- c(DF_outputs_d18Osw_temp, rep(d18Osw[i], nrow(DF_outputs)/length(d18Osw)))}
  DF_outputs$d18Osw <- DF_outputs_d18Osw_temp


  ### 1. ADDING D18O SURFACE WATER TO CALCULATION ===============================

  #dairH2O <- d18Osw - 2.644 + 3206/MAT - 1.534 * 10^6 / MAT^2
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$dairH2O[i] <- DF_outputs$d18Osw[i] - 2.644 + 3206/DF_outputs$MAT[i] - 1.534 * (10^6) / (DF_outputs$MAT[i]^2)}

  #dairH2OSW <- dairH2O -d18Osw
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$dairH2OSW[i] <- DF_outputs$dairH2O[i] - DF_outputs$d18Osw[i]}

  return(DF_outputs)
}
