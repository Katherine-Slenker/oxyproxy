#' Calculates water and oxygen fluxes as affected by species physiology.
#'
#'Given an animal’s body mass and water economy index, computes values for
#'energy expenditure, transcutaneous water loss, water vapor loss via skin (WVSkin),
#'moles of oxygen respired from air (MolesO2Air), oxygen flux through lungs (O2FluxLungs),
#'water exhaled orally (H2OOral), water exhaled nasally (H2ONasal), water vapor loss via nose (WVNose),
#'total water turnover,urinary water loss, and water vapor loss via urine (WVUrine).
#'
#' @param body_mass Numeric. Animal body mass (kg). Must be >0
#' @param water_economy_index Numeric. Mass-independent measurement of water flux.
#' Ratio of water (ml) per day to energy metabolized (kJ) per day.
#'   Must be between 0.05 and 0.6.
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
#'   result <- species_function(body_mass = 600, water_economy_index = 0.45, changeConstant = FALSE)
#'   str(out)
#'
#' @export

## SET FUNCTION FOR SPECIES

species_function <- function(body_mass=numeric(0), water_economy_index=numeric(0), changeConstant = FALSE)
{

  ## 0. VALIDATING ARGUMENTS =====================================================
  if(length(body_mass)==0)
  {
    stop("Enter bodymass value in Kg")
  }
  if(any(body_mass <= 0))
  {
    stop("Enter bodymass value in Kg greater than 0")
  }
  if(length(water_economy_index)==0)
  {
    stop("Enter Water Economy Index value between 0 and 1")
  }
  if(any(water_economy_index <= 0))
  {
    stop("Enter Water Economy Index value between 0 and 1")
  }

  ## 1. PREPPING DATAFRAME FOR OUTPUTS ===========================================
  # Width = number of variables
  # Length = number of combination of results
  DF_outputs <- matrix(data = 0, nrow = length(body_mass)*length(water_economy_index), ncol = 15)
  colnames(DF_outputs) <- c("Bodymass", "EnergyExp", "WEI", "TranscutaneousH2OLoss", "WVSkin", "MolesO2Air", "O2FluxLungs",
                            "H2OOral", "H2ONasal", "WVNose", "TotalH2OTurnover", "UrinaryH2OLoss", "WVUrine", "Urea", "d18Oairtakenup")
  DF_outputs <- as.data.frame(DF_outputs)

  #FILLING DATAFRAME WITH ARGUMENTS VALUES
  bodymass <- body_mass
  DF_outputs$Bodymass <- body_mass

  WEI <- water_economy_index
  DF_outputs_WEI_temp <- c()
  for(i in 1:length(WEI)){
    DF_outputs_WEI_temp <- c(DF_outputs_WEI_temp, rep(WEI[i], nrow(DF_outputs)/length(WEI)))}
  DF_outputs$WEI <- DF_outputs_WEI_temp

  ## 1. CONSTANTS ================================================================
  #oxygen utilization factor
  ocf <- 0.2
  #Z-factor
  Zfactor <- 10.5
  #Urea
  Urea <- 0.2
  message("OCF, Zfactor, d18Oairtakenup, and Urea are standardized constants,
         but can be modified by user by inputing changeConstant == TRUE")

  if(changeConstant == TRUE){
    ocf_temp <- readline("Please enter a SINGLE value for oxygen utilization factor, 0.2 is the default value : ")
    ocf <- as.numeric(ocf_temp)
    Zfactor_temp <- readline("Please enter a SINGLE value for Z-factor, 10.5 is the default value : ")
    Zfactor <- as.numeric(Zfactor_temp)
    Urea_temp <- readline("Please enter a SINGLE value for Urea, 0.2 is the default value : ")
    Urea <- as.numeric(Urea_temp)
  }

  #d18Oairtakenup = 23.2 - Zfactor * (1-oxygen utilization factor)
  d18Oairtakenup <- 23.2 - Zfactor * (1-ocf)
  DF_outputs$d18Oairtakenup <- d18Oairtakenup
  DF_outputs$Urea <- Urea

  # 2. BODY MASS (kg) ============================================================

  #Energy Expenditure = 900 x BodyMass^0.73
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$EnergyExp[i] <- 900 * (DF_outputs$Bodymass[i]^0.73)}

  #TranscutaneousH2OLoss <- 1.44 * bodymass * 0.667
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$TranscutaneousH2OLoss[i] <- 1.44 * (DF_outputs$Bodymass[i]^0.667)}

  #Skin = Transcutaneous Water Loss /2
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$WVSkin[i] <- DF_outputs$TranscutaneousH2OLoss[i]/2}

  #MolesO2Air <- EnergyExp * 0.00216
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$MolesO2Air[i] <- DF_outputs$EnergyExp[i] * 0.00216}

  #O2FluxLungs <- (22.4 * MolesO2Air)/(0.2*0.21)
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$O2FluxLungs[i] <- (22.4 * DF_outputs$MolesO2Air[i])/(0.2*0.21)}

  #H2O exhaled Orally <- O2FluxLungs * 0.5 * 0.003
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$H2OOral[i] <- (DF_outputs$O2FluxLungs[i] * 0.5 * 0.003)}

  #H2O exhaled nasally <- O2FluxLungs * 0.5 * 0.5 * 0.003
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$H2ONasal[i] <- (DF_outputs$O2FluxLungs[i] * 0.5 * 0.5 * 0.003)}

  #Nose = Water Exhaled Nasally/2
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$WVNose[i] <- (DF_outputs$H2ONasal[i]/2)}

  # 3. WATER ECONOMY INDEX (WEI) ====================================================

  #TotalH2OTurnover = WEI * (EnergyExp/18)
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$TotalH2OTurnover[i] <- (DF_outputs$WEI[i] * (DF_outputs$EnergyExp[i]/18))}

  #Urinary H2O Loss <- WEI loss as urine (0.25) * TotalH2OTurnover
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$UrinaryH2OLoss[i] <- ((0.25) * DF_outputs$TotalH2OTurnover[i])}

  #Urine = Urinary H2O loss /2
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$WVUrine[i] <- (DF_outputs$UrinaryH2OLoss[i]/2)}

  return(DF_outputs)
}
