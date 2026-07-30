#' Calculates all variables of oxygen input from physiology and diet.
#'
#' This function combines the Species, Food, and Inputs functions to calculate oxygen outputs
#' such as dry fecal mass, water loss from feces, water vapor losses through feces,sweat, respiration (CO2), and panting,
#' and losses through metabolic functions, like urea production.
#'
#' @param inputs A data frame containing the following required columns:
#'   \describe{
#'     \item{FoodMassIngested}{Numeric. Mass of food consumed (kg)}
#'     \item{Digestibility}{Numeric. Fraction of food digested (0-1)}
#'     \item{TotalH2OTurnover}{Numeric. Total daily water turnover (moles H2O)}
#'     \item{H2OOral}{Numeric. Oral water loss (moles H2O)}
#'     \item{H2ONasal}{Numeric. Nasal water loss (moles H2O)}
#'     \item{TranscutaneousH2OLoss}{Numeric. Transcutaneous water loss (kg/((m^2)*h)}
#'     \item{UrinaryH2OLoss}{Numeric. Urinary water loss (moles H2O)}
#'     \item{Oprotein}{Numeric. Oxygen consumption for protein metabolism}
#'     \item{foodproteincontent}{Numeric. Protein content of food (0-1)}
#'     \item{EEE}{Numeric. Energy extraction efficiency (0-1)}
#'     \item{MolesO2Air}{Numeric. Moles of oxygen from air (moles)}
#'     \item{dryHinflux}{Numeric. Dry hydrogen influx (moles H2)}
#'     \item{dryOinflux}{Numeric. Dry oxygen influx (moles O2)}
#'   }
#' @param sweating_species Logical. Indicates whether the species is capable of
#'   sweating. If TRUE, water vapor loss from sweating is calculated as 75% of
#'   water heat loss. If FALSE (default), sweating water vapor loss is set to
#'   zero.
#'
#' @return A data frame containing all original input columns plus the following
#'   calculated output columns:
#'   \describe{
#'     \item{DryFecalOutput}{Numeric. Dry mass of fecal output (kg)}
#'     \item{FecalH20Loss}{Numeric. Water loss through feces (moles H2O)}
#'     \item{WVFecal}{Numeric. Water vapor from fecal loss (moles H2O)}
#'     \item{WaterHeatLoss}{Numeric. Water used for thermoregulation (moles H2O)}
#'     \item{Sweating}{Numeric. Water loss through sweat (moles H2O)}
#'     \item{WVSweat}{Numeric. Water vapor from sweating (moles H2O, species-dependent)}
#'     \item{Panting}{Numeric. Water loss through panting (moles H2O)}
#'     \item{WVMouth}{Numeric. Water vapor from oral routes (moles H2O)}
#'     \item{UreaProduced}{Numeric. Urea production from protein metabolism}
#'     \item{WVCO2}{Numeric. Water vapor associated with CO2 exchange}
#'   }
#'
#' @details
#' The function performs calculations in a specific sequence to handle dependencies:
#' \enumerate{
#'   \item Calculates dry fecal output based on food intake and digestibility
#'   \item Computes fecal water loss using standard conversion factors
#'   \item Determines water available for heat loss by subtracting all other losses
#'   \item Calculates sweating-related outputs (species-dependent)
#'   \item Computes respiratory water losses
#'   \item Determines metabolic outputs including urea production
#' }
#'
#' @note
#' All water-related inputs and outputs should use consistent units (typically moles H2O).
#' Digestibility and efficiency values should be between 0 and 1.
#' For non-sweating species, set sweating_species = FALSE (default).
#'
#' @examples
#' # Example for a small mammal
#' mouse_data <- data.frame(
#'   FoodMassIngested = 5.2,
#'   Digestibility = 0.85,
#'   TotalH2OTurnover = 8.5,
#'   H2OOral = 1.2,
#'   H2ONasal = 0.8,
#'   TranscutaneousH2OLoss = 2.1,
#'   UrinaryH2OLoss = 3.2,
#'   Oprotein = 0.12,
#'   foodproteincontent = 0.18,
#'   EEE = 0.88,
#'   MolesO2Air = 0.42,
#'   dryHinflux = 0.15,
#'   dryOinflux = 0.08
#' )
#'
#' # Calculate outputs for non-sweating species (default)
#' mouse_outputs <- outputs_function(mouse_data)
#'
#' # Calculate outputs for a sweating species
#' sweating_outputs <- outputs_function(mouse_data, sweating_species = TRUE)
#'
#' # Multiple animals
#' multi_animal_data <- data.frame(
#'   FoodMassIngested = c(100, 150, 200),
#'   Digestibility = c(0.8, 0.75, 0.85),
#'   TotalH2OTurnover = c(1000, 1200, 1400),
#'   H2OOral = c(50, 60, 70),
#'   H2ONasal = c(20, 25, 30),
#'   TranscutaneousH2OLoss = c(80, 90, 100),
#'   UrinaryH2OLoss = c(150, 180, 200),
#'   Oprotein = c(0.1, 0.12, 0.08),
#'   foodproteincontent = c(0.2, 0.18, 0.22),
#'   EEE = c(0.9, 0.85, 0.92),
#'   MolesO2Air = c(10, 12, 8),
#'   dryHinflux = c(4, 5, 3),
#'   dryOinflux = c(2, 2.5, 1.5)
#' )
#' multi_outputs <- outputs_function(multi_animal_data, sweating_species = FALSE)
#'
#' @export
outputs_function <- function(inputs = 0, sweating_species = FALSE) {
  if (!sweating_species) {
    message("Using non-sweating species model (WVSweat = 0)")
  }

  validate_inputs(inputs)

  sweat_function <- ifelse(sweating_species,
    calculate_wv_sweating,
    calculate_wv_not_sweating
  )

  prepare_outputs_dataframe(inputs) |>
    with_column("DryFecalOutput", calculate_dry_fecal_output) |>
    with_column("FecalH20Loss", calculate_fecal_water_loss) |>
    with_column("WVFecal", calculate_wv_fecal) |>
    with_column("WaterHeatLoss", calculate_water_heat_loss) |>
    with_column("Sweating", calculate_sweating) |>
    with_column("WVSweat", sweat_function) |>
    with_column("Panting", calculate_panting) |>
    with_column("WVMouth", calculate_wv_mouth) |>
    with_column("UreaProduced", calculate_urea_produced) |>
    with_column("WVCO2", calculate_wv_co2)
}

#' Validate required input columns and data types
#' @param inputs Input data frame to validate
#' @keywords internal
validate_inputs <- function(inputs) {
  required_cols <- c(
    "FoodMassIngested", "Digestibility", "TotalH2OTurnover",
    "H2OOral", "H2ONasal", "TranscutaneousH2OLoss", "UrinaryH2OLoss",
    "Oprotein", "foodproteincontent", "EEE", "MolesO2Air",
    "dryHinflux", "dryOinflux"
  )

  missing_cols <- setdiff(required_cols, names(inputs))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  if (nrow(inputs) == 0) {
    stop("Input data frame is empty")
  }

  # Check for negative values where they don't make biological sense
  non_negative_cols <- c(
    "FoodMassIngested", "TotalH2OTurnover", "H2OOral",
    "H2ONasal", "TranscutaneousH2OLoss", "UrinaryH2OLoss"
  )

  for (col in non_negative_cols) {
    if (any(inputs[[col]] < 0, na.rm = TRUE)) {
      warning(sprintf("Negative values found in %s column", col))
    }
  }

  # Check digestibility is between 0 and 1
  if (any(inputs$Digestibility < 0 | inputs$Digestibility > 1, na.rm = TRUE)) {
    warning("Digestibility values should be between 0 and 1")
  }
}

fecal_water_multiplier <- 55.56
FECAL_WATER_CONTENT <- 0.6
WATER_VAPOR_FRACTION <- 0.5
SWEAT_HEAT_FRACTION <- 0.75
PANTING_HEAT_FRACTION <- 0.5

#' Calculate dry fecal output
#' @param df Data frame containing values from Food (Digestibility) and Inputs (FoodMassIngested) functions
#' @return Numeric vector of dry fecal output values (kg)
#' @keywords internal
calculate_dry_fecal_output <- function(df) {
  df$FoodMassIngested * (1 - df$Digestibility)
}

#' Calculate fecal water loss
#' @param df Calculated DryFecalOutput value(s)
#' @return Numeric vector of fecal water loss values (moles H2O)
#' @keywords internal
calculate_fecal_water_loss <- function(df) {
  fecal_water_ratio <- FECAL_WATER_CONTENT / (1 - FECAL_WATER_CONTENT)
  df$DryFecalOutput * fecal_water_multiplier * fecal_water_ratio
}

#' Calculate water vapor from fecal loss
#' @param df Calculated FecalH20Loss value(s)
#' @return Numeric vector of fecal water vapor values (moles H2O)
#' @keywords internal
calculate_wv_fecal <- function(df) {
  df$FecalH20Loss / 2
}

#' Calculate water used for heat loss
#' @param df Data frame containing values from Species function (TotalH2OTurnover, TranscutaneousH2OLoss, H2OOral, H2ONasal, UrinaryH2O) and calculated FecalH2OLoss
#' @return Numeric vector of water heat loss values (moles H2O)
#' @keywords internal
calculate_water_heat_loss <- function(df) {
  df$TotalH2OTurnover - df$H2OOral - df$H2ONasal -
    df$TranscutaneousH2OLoss - df$UrinaryH2OLoss - df$FecalH20Loss
}

#' Calculate panting water loss
#' @param df Calculated WaterHeatLoss value(s)
#' @return Numeric vector of panting values (moles H2O)
#' @keywords internal
calculate_panting <- function(df) {
  PANTING_HEAT_FRACTION * df$WaterHeatLoss
}

#' Calculate water vapor from mouth
#' @param df Data frame containing values from Species function (H2OOral) and calculated Panting value(s)
#' @return Numeric vector of mouth water vapor values moles H2O
#' @keywords internal
calculate_wv_mouth <- function(df) {
  df$H2OOral * WATER_VAPOR_FRACTION +
    df$Panting * WATER_VAPOR_FRACTION
}

#' Calculate urea production
#' @param df Data frame containing values from Food (Oprotein, foodproteincontent, EEE, Digestibility) and Inputs function (FoodMassIngested)
#' @return Numeric vector of urea production values
#' @keywords internal
calculate_urea_produced <- function(df) {
  df$Oprotein * df$foodproteincontent * df$EEE *
    df$Digestibility * df$FoodMassIngested
}

#' Calculate water vapor from CO2
#' @param df Data frame containing values from Species (MolesO2Air) and Inputs (dryHinflux,dryOinflux), and calculated value(s) of Ureaproduced
#' @return Numeric vector of CO2 water vapor values (moles H2O)
#' @keywords internal
calculate_wv_co2 <- function(df) {
  df$MolesO2Air - df$UreaProduced -
    (df$dryHinflux * WATER_VAPOR_FRACTION - df$dryOinflux)
}

#' Calculate water loss from sweating
#' @param df Calculated value(s) of WaterHeatLoss
#' @return Numeric vector of sweating (moles H2O)
#' @keywords internal
calculate_sweating <- function(df) {
  SWEAT_HEAT_FRACTION * df$WaterHeatLoss
}

#' Calculate water vapor from sweating
#' @param df Calculated value(s) of Sweating
#' @return Numeric vector of sweat water vapor values
#' @keywords internal
calculate_wv_sweating <- function(df) {
  df$Sweating / 2
}

#' Calculate water vapor for non-sweating species
#' @param df Data frame (parameter ignored)
#' @return Numeric vector of zeros
#' @keywords internal
calculate_wv_not_sweating <- function(df) {
  rep(0, nrow(df))
}


#' Prepare outputs dataframe with initialized calculation columns
#'
#' @param inputs A dataframe containing inputs for calculations
#' @return A dataframe with original inputs and new columns. Initialized to 0
#' @keywords internal
prepare_outputs_dataframe <- function(inputs) {
  data.frame(
    inputs,
    DryFecalOutput = 0,
    FecalH20Loss = 0,
    WVFecal = 0,
    WaterHeatLoss = 0,
    Sweating = 0,
    WVSweat = 0,
    Panting = 0,
    WVMouth = 0,
    UreaProduced = 0,
    WVCO2 = 0,
    row.names = NULL
  )
}
