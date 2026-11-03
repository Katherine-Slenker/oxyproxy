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
food_function <- function(digestibility_of_food = numeric(0),
                          Carbohydrate_Content = numeric(0),
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

  n_dig <- length(digestibility_of_food)
  n_carb <- length(Carbohydrate_Content)
  n_prot <- length(Protein_Content)
  n_fat <- length(Fat_Content)
  n_water <- length(Free_Water_Content_Food)

  # FILLING DATAFRAME WITH ARGUMENTS VALUES AND CONSTANTS
  # One row per combination: freeH20food varies fastest, then fat, protein, carbohydrate,and Digestibility

  message("CAUTION !!! Carbohydrate_Content, Protein_Content and Fat_Content arguments must
  sum to 1")

  message("Energy Extraction Efficiency, fractions (O, H, energy) of carbohydrate, protein
  and fat are standardized constants extracted from Kohn models and litterature,
           but it can be modified by user by modifying the argument changeConstant to TRUE")

  # free H2O content of food ===================================================
  freeH20food <- rep(Free_Water_Content_Food, times = n_dig * n_carb * n_prot * n_fat)

  # Digestibility ===============================================================
  ## the dataframe is split in X part for X values of Digestibility
  Digestibility <- rep(digestibility_of_food, each = n_carb * n_prot * n_fat * n_water)

  ## 1. CONSTANTS ================================================================
  # energy extraction efficiency
  EEE <- 0.9
  if (changeConstant == FALSE) {
    message("Energy Extraction Efficiency standardized to EEE = 0.9 (%)")
  }

  if (changeConstant == TRUE) {
    EEE_temp <- readline("Please enter a SINGLE value for Energy Extraction Efficiency
  between 0 and 1 (%), 0.9 is the default value : ")
    EEE <- as.numeric(EEE_temp)
  }

  # food carbohydrate ==========================================================
  foodcarbenergy <- 17300
  Ocarb <- 15.4
  Hcarb <- 30.9

  if (changeConstant == TRUE) {
    foodcarbenergy_temp <- readline("Please enter a SINGLE value for the energy coming from
  carbohydrate, 17300 J is the default value : ")
    foodcarbenergy <- as.numeric(foodcarbenergy_temp)

    Ocarb_temp <- readline("Please enter a SINGLE value for the oxygen coming from
  carbohydrate, 15.4 is the default value : ")
    Ocarb <- as.numeric(Ocarb_temp)

    Hcarb_temp <- readline("Please enter a SINGLE value for the hydrogen coming from
  carbohydrate, 30.9 is the default value : ")
    Hcarb <- as.numeric(Hcarb_temp)
  }

  foodcarbcontent <- rep(Carbohydrate_Content,
    each = n_prot * n_fat * n_water, times =
      n_dig
  )


  # food protein ===============================================================
  foodproteinenergy <- 20100
  Oprotein <- 3
  Hprotein <- 11

  if (changeConstant == TRUE) {
    foodproteinenergy_temp <- readline("Please enter a SINGLE value for the energy coming
  from protein, 20100 J is the default value : ")
    foodproteinenergy <- as.numeric(foodproteinenergy_temp)

    Opro_temp <- readline("Please enter a SINGLE value for the oxygen coming from protein, 3
  is the default value : ")
    Oprotein <- as.numeric(Opro_temp)

    Hpro_temp <- readline("Please enter a SINGLE value for the hydrogen coming from protein,
  11 is the default value : ")
    Hprotein <- as.numeric(Hpro_temp)
  }

  foodproteincontent <- rep(Protein_Content, each = n_fat * n_water, times = n_dig * n_carb)


  # e. food fat ================================================================
  foodfatenergy <- 39700
  Ofat <- 2
  Hfat <- 60

  if (changeConstant == TRUE) {
    foodfatenergy_temp <- readline("Please enter a SINGLE value for the energy coming from
  fat, 39700 J is the default value : ")
    foodfatenergy <- as.numeric(foodfatenergy_temp)

    Ofat_temp <- readline("Please enter a SINGLE value for the oxygen coming from fat, 2 is
  the default value : ")
    Ofat <- as.numeric(Ofat_temp)

    Hfat_temp <- readline("Please enter a SINGLE value for the hydrogen coming from fat, 6
  is the default value : ")
    Hfat <- as.numeric(Hfat_temp)
  }

  foodfatcontent <- rep(Fat_Content, each = n_water, times = n_dig * n_carb * n_prot)


  data.frame(
    Digestibility, EEE, foodcarbenergy, foodcarbcontent,
    Ocarb, Hcarb, foodproteinenergy,
    Oprotein, Hprotein, foodfatenergy,
    Ofat, Hfat, foodproteincontent, foodfatcontent, freeH20food,
    row.names = NULL
  )
}
