#' Calculates water and oxygen fluxes as affected by species diet
#'
#' Given values of digestibility and macronutrient and water content of food,
#' computes values for food-related parameters (energy, oxygen, and hydrogen content).
#'
#' @param digestibility_of_food Numeric. Digestible organic matter as a
#' proportion of total ingested matter. High values indicate that large
#' amounts of nutrients are extracted. Must be greater than 0 and at most 1.
#' @param Carbohydrate_Content Numeric. Proportion of carbohydrate in the diet.
#'   Must be between 0 and 1, and should sum with protein and fat content
#'   to equal 1.
#' @param Protein_Content Numeric. Proportion of protein in the diet.
#'   Must be between 0 and 1, and should sum with carbohydrate and fat content
#'   to equal 1.
#' @param Fat_Content Numeric. Proportion of fat in the diet.
#'   Must be between 0 and 1, and should sum with carbohydrate and protein
#'   content to equal 1.
#' @param Free_Water_Content_Food Numeric. Proportion of free water in food.
#' Must be between 0 and 1.
#' @param changeConstant Logical. If TRUE, prompts for values overriding the
#'   model constants. Defaults to FALSE.
#'
#' @return Data frame with all calculated dietary variables:
#' \itemize{
#'   \item EEE - Energy extraction efficiency (standardized to 0.9, but must be set between 0-1)
#'   \item foodcarbenergy-Energy content of carbohydrates (17300 J/g)
#'   \item Ocarb - Oxygen atoms per carbohydrate unit (15.4)
#'   \item Hcarb - Hydrogen atoms per carbohydrate unit (30.9)
#'   \item foodproteinenergy - Energy content of proteins (20100 J/g)
#'   \item Oprotein - Oxygen atoms per protein unit (3)
#'   \item Hprotein - Hydrogen atoms per protein unit (11)
#'   \item foodfatenergy - Energy content of fats (39700 J/g)
#'   \item Ofat - Oxygen atoms per fat unit (2)
#'   \item Hfat - Hydrogen atoms per fat unit (60)
#' }
#' @examples
#' # Example parameters for a herbivore diet
#' herbivore_food <- food_function(
#'   digestibility_of_food = 0.6,
#'   Carbohydrate_Content = 0.8,
#'   Protein_Content = 0.1,
#'   Fat_Content = 0.1,
#'   Free_Water_Content_Food = 0.4
#' )
#'
#' # Example parameters for a carnivore diet
#' carnivore_food <- food_function(
#'   digestibility_of_food = 0.85,
#'   Carbohydrate_Content = 0.1,
#'   Protein_Content = 0.7,
#'   Fat_Content = 0.2,
#'   Free_Water_Content_Food = 0.7
#' )

#' @export

## SET FUNCTION FOR FOOD
food_function <- function(digestibility_of_food = numeric(0), Carbohydrate_Content = numeric(0),
                          Protein_Content = numeric(0), Fat_Content = numeric(0),
                          Free_Water_Content_Food = numeric(0), changeConstant = FALSE) {
  ## 0. VALIDATING ARGUMENTS =====================================================
  if (length(Free_Water_Content_Food) == 0) {
    stop("Enter Free Water Content of Food as Proportion Value (ex: 0.4)")
  }
  if (length(digestibility_of_food) == 0) {
    stop("Enter Digestibility value as % (0-1)")
  }
  if (any(digestibility_of_food <= 0) || any(digestibility_of_food > 1)) {
    stop("Enter Digestibility value as % (0-1) greater than 0")
  }
  if (length(Carbohydrate_Content) == 0) {
    stop("Enter Carbohydrate Content of Food as Proportion Value between 0 and 1 (ex: 0.8)")
  }
  if (length(Protein_Content) == 0) {
    stop("Enter Protein Content of Food as Proportion Value between 0 and 1 (ex: 0.8)")
  }
  if (length(Fat_Content) == 0) {
    stop("Enter Fat Content of Food as Proportion Value between 0 and 1 (ex: 0.8)")
  }

  # Proportions may be 0 (a zero-fat diet, or completely dry food) but never
  # negative, and never above 1.
  if (any(Carbohydrate_Content < 0) || any(Carbohydrate_Content > 1)) {
    stop("Enter Carbohydrate Content of Food as Proportion Value between 0 and 1 (ex: 0.8)")
  }
  if (any(Protein_Content < 0) || any(Protein_Content > 1)) {
    stop("Enter Protein Content of Food as Proportion Value between 0 and 1 (ex: 0.8)")
  }
  if (any(Fat_Content < 0) || any(Fat_Content > 1)) {
    stop("Enter Fat Content of Food as Proportion Value between 0 and 1 (ex: 0.8)")
  }
  if (any(Free_Water_Content_Food < 0) || any(Free_Water_Content_Food > 1)) {
    stop("Enter Free Water Content of Food as Proportion Value between 0 and 1 (ex: 0.4)")
  }

  ## 1. PREPPING DATAFRAME FOR OUTPUTS ===========================================
  # Width = number of variables
  # Length = number of combination of results
  DF_outputs <- matrix(
    data = 0, nrow = length(digestibility_of_food) * length(Carbohydrate_Content) * length(Protein_Content) * length(Fat_Content) * length(Free_Water_Content_Food),
    ncol = 15
  )
  colnames(DF_outputs) <- c(
    "Digestibility", "EEE", "foodcarbenergy", "foodcarbcontent",
    "Ocarb", "Hcarb", "foodproteinenergy",
    "Oprotein", "Hprotein", "foodfatenergy",
    "Ofat", "Hfat", "foodproteincontent", "foodfatcontent", "freeH20food"
  )
  DF_outputs <- as.data.frame(DF_outputs)

  # FILLING DATAFRAME WITH ARGUMENTS VALUES AND CONSTANTS

  message("CAUTION !!! Carbohydrate_Content, Protein_Content and Fat_Content arguments must sum to 1")

  message("Energy Extraction Efficiency, fractions (O, H, energy) of carbohydrate, protein and fat are standardized constants extracted from Kohn models and litterature,
         but it can be modified by user by modifying the argument changeConstant to TRUE")

  # free H2O content of food ===================================================
  freeH20food <- Free_Water_Content_Food

  DF_outputs$freeH20food <- freeH20food

  # Digestibility ===============================================================
  Digestibility <- digestibility_of_food
  DF_outputs$Digestibility <- Digestibility

  Col_Digestibility_temp <- c()
  for (i in seq_along(Digestibility)) {
    Col_Digestibility_temp <- c(Col_Digestibility_temp, rep(Digestibility[i], nrow(DF_outputs) / length(Digestibility)))
  } ## the dataframe is split in X part for X values of Digestibility
  DF_outputs$Digestibility <- Col_Digestibility_temp

  # Macronutrient Content ===============================================================
  foodcarbcontent <- Carbohydrate_Content
  foodproteincontent <- Protein_Content
  foodfatcontent <- Fat_Content

  ## 1. CONSTANTS ================================================================
  # energy extraction efficiency
  DF_outputs$EEE <- 0.9
  if (changeConstant == FALSE) {
    message("Energy Extraction Efficiency standardized to EEE = 0.9 (%)")
  }

  if (changeConstant == TRUE) {
    EEE_temp <- readline("Please enter a SINGLE value for Energy Extraction Efficiency between 0 and 1 (%), 0.9 is the default value : ")
    DF_outputs$EEE <- as.numeric(EEE_temp)
  }

  # food carbohydrate ==========================================================
  DF_outputs$foodcarbenergy <- 17300
  DF_outputs$Ocarb <- 15.4
  DF_outputs$Hcarb <- 30.9

  if (changeConstant == TRUE) {
    foodcarbenergy_temp <- readline("Please enter a SINGLE value for the energy coming from carbohydrate, 17300 J is the default value : ")
    DF_outputs$foodcarbenergy <- as.numeric(foodcarbenergy_temp)

    Ocarb_temp <- readline("Please enter a SINGLE value for the oxygen coming from carbohydrate, 15.4 is the default value : ")
    DF_outputs$Ocarb <- as.numeric(Ocarb_temp)

    Hcarb_temp <- readline("Please enter a SINGLE value for the hydrogen coming from carbohydrate, 30.9 is the default value : ")
    DF_outputs$Hcarb <- as.numeric(Hcarb_temp)
  }


  Col_foodcarbcontent_temp <- c()
  for (i in seq_along(foodcarbcontent)) {
    Col_foodcarbcontent_temp <- c(Col_foodcarbcontent_temp, rep(foodcarbcontent[i], nrow(DF_outputs) / length(Digestibility) / length(foodcarbcontent)))
  }
  Col_foodcarbcontent_temp <- rep(Col_foodcarbcontent_temp, length(Digestibility))
  DF_outputs$foodcarbcontent <- Col_foodcarbcontent_temp


  # food protein ===============================================================
  DF_outputs$foodproteinenergy <- 20100
  DF_outputs$Oprotein <- 3
  DF_outputs$Hprotein <- 11

  if (changeConstant == TRUE) {
    foodproteinenergy_temp <- readline("Please enter a SINGLE value for the energy coming from protein, 20100 J is the default value : ")
    DF_outputs$foodproteinenergy <- as.numeric(foodproteinenergy_temp)

    Opro_temp <- readline("Please enter a SINGLE value for the oxygen coming from protein, 3 is the default value : ")
    DF_outputs$Oprotein <- as.numeric(Opro_temp)

    Hpro_temp <- readline("Please enter a SINGLE value for the hydrogen coming from protein, 11 is the default value : ")
    DF_outputs$Hprotein <- as.numeric(Hpro_temp)
  }

  Col_foodproteincontent_temp <- c()
  for (i in seq_along(foodproteincontent)) {
    Col_foodproteincontent_temp <- c(
      Col_foodproteincontent_temp,
      rep(foodproteincontent[i], nrow(DF_outputs) / length(Digestibility) / length(foodproteincontent) / length(foodcarbcontent))
    )
  }
  Col_foodproteincontent_temp <- rep(Col_foodproteincontent_temp, (length(Digestibility) * length(foodcarbcontent)))
  DF_outputs$foodproteincontent <- Col_foodproteincontent_temp


  # e. food fat ================================================================
  DF_outputs$foodfatenergy <- 39700
  DF_outputs$Ofat <- 2
  DF_outputs$Hfat <- 60

  if (changeConstant == TRUE) {
    foodfatenergy_temp <- readline("Please enter a SINGLE value for the energy coming from fat, 39700 J is the default value : ")
    DF_outputs$foodfatenergy <- as.numeric(foodfatenergy_temp)

    Ofat_temp <- readline("Please enter a SINGLE value for the oxygen coming from fat, 2 is the default value : ")
    DF_outputs$Ofat <- as.numeric(Ofat_temp)

    Hfat_temp <- readline("Please enter a SINGLE value for the hydrogen coming from fat, 6 is the default value : ")
    DF_outputs$Hfat <- as.numeric(Hfat_temp)
  }

  Col_foodfatcontent_temp <- c()
  for (i in seq_along(foodfatcontent)) {
    Col_foodfatcontent_temp <- c(
      Col_foodfatcontent_temp,
      rep(foodfatcontent[i], nrow(DF_outputs) / length(Digestibility) / length(foodproteincontent) / length(foodcarbcontent) / length(foodfatcontent))
    )
  }
  Col_foodfatcontent_temp <- rep(Col_foodfatcontent_temp, (length(Digestibility) * length(foodcarbcontent) * length(foodproteincontent)))
  DF_outputs$foodfatcontent <- Col_foodfatcontent_temp


  return(DF_outputs)
}
