#' Calculates water and oxygen fluxes as affected by species physiology.
#'
#' Given an animal's body mass and water economy index, computes values for
#' energy expenditure, transcutaneous water loss, water vapor loss via skin (WVSkin),
#' moles of oxygen respired from air (MolesO2Air), oxygen flux through lungs (O2FluxLungs),
#' water exhaled orally (H2OOral), water exhaled nasally (H2ONasal), water vapor loss via nose (WVNose),
#' total water turnover,urinary water loss, and water vapor loss via urine (WVUrine).
#'
#' @param body_mass Numeric. Animal body mass (kg). Must be >0
#' @param water_economy_index Numeric. Mass-independent measurement of water flux.
#' Ratio of water (ml) per day to energy metabolized (kJ) per day.
#' Must be greater than 0; values between 0.05 and 0.6 are typical.
#' @return Data frame with all calculated physiological variables:
#'   \itemize{
#'     \item EnergyExpenditure - Energy utilized for physiological functions, scaled to body mass (kJ)
#'     \item TranscutaneousH2OLoss - Water loss via evaporation from the skin's surface (kg/((m^2)*h))
#'     \item WVSkin - Water vapor loss via skin (kg/((m^2)*h)
#'     \item MolesO2Air - Moles of atmospheric oxygen * energy expenditure (moles)
#'     \item O2FluxLungs - Oxygen flux via respiration (L)
#'     \item H2OOral - Water exhaled orally (moles H2O)
#'     \item H2ONasal - Water exhaled nasally (moles H2O)
#'     \item WVNose - Water vapor loss via nasal respiration (moles H2O)
#'     \item TotalH2OTurnover - Volume of water moving through body, reflecting intake and loss (moles H2O)
#'     \item UrinaryH2OLoss - Water lost as urine (moles H2O)
#'     \item WVUrine - Water vapor loss via urine (moles H2O)
#'     }

#' @param changeConstant Boolean. Default is FALSE. If changed to TRUE, user can modify constants injected in calculus (e.g. OCF, Zfactor, d18Oairtakenup)
#' @examples
#' # Example for a plains bison (Bison bison bison)
#' result <- species_function(
#'   body_mass = 600, water_economy_index = 0.45, changeConstant = FALSE
#' )
#' str(result)
#'
#' @export

## SET FUNCTION FOR SPECIES

species_function <- function(body_mass = numeric(0), water_economy_index = numeric(0), changeConstant = FALSE) {
  ## 0. VALIDATING ARGUMENTS =====================================================
  if (length(body_mass) == 0) {
    stop("Enter bodymass value in Kg")
  }
  if (any(body_mass <= 0)) {
    stop("Enter bodymass value in Kg greater than 0")
  }
  if (length(water_economy_index) == 0) {
    stop("Enter Water Economy Index value between 0 and 1")
  }
  if (any(water_economy_index <= 0)) {
    stop("Enter Water Economy Index value between 0 and 1")
  }

  ## 1. PREPPING DATAFRAME FOR OUTPUTS ===========================================
  # FILLING DATAFRAME WITH ARGUMENTS VALUES
  # One row per combination: Bodymass varies fastest, then WEI
  Bodymass <- rep(body_mass, times = length(water_economy_index))
  WEI <- rep(water_economy_index, each = length(body_mass))

  ## 1. CONSTANTS ================================================================
  # oxygen utilization factor
  ocf <- 0.2
  # Z-factor
  Zfactor <- 10.5
  # Urea
  Urea <- 0.2
  message("OCF, Zfactor, d18Oairtakenup, and Urea are standardized constants,
  but can be modified by user by inputing changeConstant == TRUE")

  if (changeConstant == TRUE) {
    ocf_temp <- readline("Please enter a SINGLE value for oxygen utilization factor, 0.2 is the default value : ")
    ocf <- as.numeric(ocf_temp)
    Zfactor_temp <- readline("Please enter a SINGLE value for Z-factor, 10.5 is the default value : ")
    Zfactor <- as.numeric(Zfactor_temp)
    Urea_temp <- readline("Please enter a SINGLE value for Urea, 0.2 is the default value : ")
    Urea <- as.numeric(Urea_temp)
  }

  # d18Oairtakenup = 23.2 - Zfactor * (1-oxygen utilization factor)
  d18Oairtakenup <- 23.2 - Zfactor * (1 - ocf)

  # 2. BODY MASS (kg) ============================================================

  # Energy Expenditure = 900 x BodyMass^0.73
  EnergyExp <- 900 * (Bodymass^0.73)

  # TranscutaneousH2OLoss <- 1.44 * bodymass * 0.667
  TranscutaneousH2OLoss <- 1.44 * (Bodymass^0.667)

  # Skin = Transcutaneous Water Loss /2
  WVSkin <- TranscutaneousH2OLoss / 2

  # MolesO2Air <- EnergyExp * 0.00216
  MolesO2Air <- EnergyExp * 0.00216

  # O2FluxLungs <- (22.4 * MolesO2Air)/(0.2*0.21)
  O2FluxLungs <- (22.4 * MolesO2Air) / (0.2 * 0.21)

  # H2O exhaled Orally <- O2FluxLungs * 0.5 * 0.003
  H2OOral <- O2FluxLungs * 0.5 * 0.003

  # H2O exhaled nasally <- O2FluxLungs * 0.5 * 0.5 * 0.003
  H2ONasal <- O2FluxLungs * 0.5 * 0.5 * 0.003

  # Nose = Water Exhaled Nasally/2
  WVNose <- H2ONasal / 2

  # 3. WATER ECONOMY INDEX (WEI) ====================================================

  # TotalH2OTurnover = WEI * (EnergyExp/18)
  TotalH2OTurnover <- WEI * (EnergyExp / 18)


  # Urinary H2O Loss <- WEI loss as urine (0.25) * TotalH2OTurnover
  UrinaryH2OLoss <- 0.25 * TotalH2OTurnover


  # Urine = Urinary H2O loss /2
  WVUrine <- UrinaryH2OLoss / 2

  data.frame(
    Bodymass, EnergyExp, WEI, TranscutaneousH2OLoss, WVSkin, MolesO2Air, O2FluxLungs,
    H2OOral, H2ONasal, WVNose, TotalH2OTurnover, UrinaryH2OLoss, WVUrine, Urea,
    d18Oairtakenup,
    row.names = NULL
  )
}
